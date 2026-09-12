import 'dart:async';
import 'package:conference/models/conversation.dart';
import 'package:conference/models/presence_status.dart';
import 'package:conference/models/participant.dart';
import 'package:conference/models/user_model.dart';
import 'package:conference/core/storage/storage.dart';
import 'package:conference_sdk/conference_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart';

/// Permanent, non-disposable service managing chat socket connections
/// and caching global conversation state across all controllers.
class ChatService extends GetxService {
  static ChatService get instance => Get.find<ChatService>();

  final ws = BtcMeetSocketService.instance;
  final config = AppConfig.instance;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Conversation> conversations = <Conversation>[].obs;
  final RxMap<String, int> unreadCounts = <String, int>{}.obs;
  final RxList<Message> activeMessages = <Message>[].obs;

  final List<StreamSubscription> _subscriptions = [];
  Timer? _messageSyncTimer;



  @override
  void onInit() {
    super.onInit();
    _loadUnreadCounts();
    _loadCachedConversations();
    // Auto-save whenever unreadCounts is mutated
    unreadCounts.listen((_) {
      _saveUnreadCounts();
    });
  }

  @override
  void onClose() {
    _cancelSubscriptions();
    super.onClose();
  }

  void _loadUnreadCounts() {
    try {
      final stored = StorageService.instance.getValue<Map>('unread_counts');
      if (stored != null) {
        unreadCounts.value = Map<String, int>.from(
          stored.map((key, value) => MapEntry(key.toString(), value as int)),
        );
        debugPrint('[ChatService] Loaded unread counts from storage: $unreadCounts');
      }
    } catch (e) {
      debugPrint('[ChatService] Error loading unread counts: $e');
    }
  }

  Future<void> _saveUnreadCounts() async {
    try {
      await StorageService.instance.setValue('unread_counts', Map<String, int>.from(unreadCounts));
      debugPrint('[ChatService] Saved unread counts to storage: $unreadCounts');
    } catch (e) {
      debugPrint('[ChatService] Error saving unread counts: $e');
    }
  }

  void _loadCachedConversations() {
    try {
      final storedMap = StorageService.instance.getValue<Map>('cached_conversations');
      if (storedMap != null) {
        final records = storedMap["conversations"];
        final parsedList = <Conversation>[];
        if (records != null) {
          for (var item in records) {
            parsedList.add(Conversation.fromJson(Map<String, dynamic>.from(item)));
          }
        }
        
        parsedList.sort((a, b) {
          final timeA = a.lastMessageAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final timeB = b.lastMessageAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return timeB.compareTo(timeA);
        });

        conversations.value = parsedList;
        debugPrint('[ChatService] Loaded ${conversations.length} conversations from Hive cache.');
      }
    } catch (e) {
      debugPrint('[ChatService] Error loading cached conversations: $e');
    }
  }

  Future<void> _saveCachedConversations(Map<String, dynamic> payload) async {
    try {
      await StorageService.instance.setValue('cached_conversations', payload);
      debugPrint('[ChatService] Saved conversations payload to Hive cache.');
    } catch (e) {
      debugPrint('[ChatService] Error saving conversations to Hive cache: $e');
    }
  }

  void _cancelSubscriptions() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _messageSyncTimer?.cancel();
    _messageSyncTimer = null;
  }

  /// Retrieves all cached messages from local storage (Hive), categorizes them,
  /// and prints them on the console.
  /// Category 1: Not Sent (Status <= 1 or null)
  /// Category 2: Sent/Pushed but not seen (Status == 2)
  void getUnSuccessMessages() {
    try {
      final List<Message> allMessages = ChatStorage.instance.getAllMessages();
      final currentUserId = UserModel.instance.userId;

      final List<Message> notSent = allMessages.where((msg) {
        if (msg.senderId != currentUserId) return false;
        final status = msg.status;
        return status == null || status <= 1;
      }).toList();

      debugPrint('═════════ OFFLINE/PENDING MESSAGES REPORT ═════════');
      debugPrint('[ChatService] Total cached messages in Hive: ${allMessages.length}');
      
      debugPrint('[ChatService] Category 1: Not Sent (Status <= 1 or null) [Total: ${notSent.length}]');
      for (var msg in notSent) {
        debugPrint('  → Message ID: ${msg.messageId} | Content: "${msg.content}" | Status: ${msg.status}');
      }
      debugPrint('═══════════════════════════════════════════════════');

      // Re-attempt to send notSent messages if WS is connected
      if (ws.isConnected && notSent.isNotEmpty) {
        debugPrint('[ChatService] WS is connected. Re-attempting to send ${notSent.length} unsent messages...');
        for (final msg in notSent) {
          final isInvalid = msg.messageId.isEmpty ||
              msg.conversationId.isEmpty ||
              msg.senderId.isEmpty ||
              msg.type.isEmpty ||
              msg.content.isEmpty ||
              msg.createdAt == null ||
              !msg.createdAt!.isUtc;

          if (isInvalid) {
            debugPrint('[ChatService] Deleting invalid message from local storage: ${msg.messageId}');
            ChatStorage.instance.deleteMessage(msg.messageId);
          } else {
            ws.sendMessage(msg);
          }
        }
      }
    } catch (e) {
      debugPrint('[ChatService] Error getting/displaying categorized messages: $e');
    }
  }

  /// Cleans up local Hive storage for chat messages based on two rules:
  /// 1. Deletes messages older than 10 days.
  /// 2. Manages a maximum of 50 messages per channel (deletes older ones if count exceeds 50).
  Future<void> cleanupLocalMessageStorage() async {
    try {
      final List<Message> allMessages = ChatStorage.instance.getAllMessages();
      final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));

      final List<Message> remainingMessages = [];

      // 1. Delete messages older than 10 days
      for (final msg in allMessages) {
        if (msg.createdAt != null && msg.createdAt!.isBefore(tenDaysAgo)) {
          debugPrint('[ChatService] Cleanup: Deleting message older than 10 days: ${msg.messageId}');
          await ChatStorage.instance.deleteMessage(msg.messageId);
        } else {
          remainingMessages.add(msg);
        }
      }

      // 2. Group remaining messages by channel (conversationId)
      final Map<String, List<Message>> channelMessages = {};
      for (final msg in remainingMessages) {
        channelMessages.putIfAbsent(msg.conversationId, () => []).add(msg);
      }

      // 3. For each channel, keep only the 50 newest messages
      for (final entry in channelMessages.entries) {
        final messages = entry.value;
        if (messages.length > 50) {
          // Sort descending (newest first)
          messages.sort((a, b) {
            final timeA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final timeB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return timeB.compareTo(timeA);
          });

          // Keep first 50, delete the rest
          final toDelete = messages.sublist(50);
          for (final msg in toDelete) {
            debugPrint('[ChatService] Cleanup: Deleting message exceeding 50 limit: ${msg.messageId}');
            await ChatStorage.instance.deleteMessage(msg.messageId);
          }
        }
      }
      debugPrint('[ChatService] Local Hive cleanup completed successfully.');
    } catch (e) {
      debugPrint('[ChatService] Error during local Hive cleanup: $e');
    }
  }

  void initConnection() {
    var user = UserModel.instance;
    try {
      isLoading.value = true;
      if (user.userId.isNotEmpty) {
        // Load unread counts from storage
        _loadUnreadCounts();

        // Load cached conversations from Hive
        _loadCachedConversations();

        // Fetch and print categorized messages on login / initialization
        getUnSuccessMessages();

        // Cleanup local Hive database (prune messages older than 10 days or exceeding 50 per channel)
        cleanupLocalMessageStorage();

        if (!ws.isConnected) {
          var userInfo = LocalUserInfo(
            email: user.email,
            fullName: "${user.firstName} ${user.lastName}",
            userId: user.userId,
            avatar: user.imageUrl,
          );

          ws.connect(config.wsBaseUrl, userInfo);
        }

        // Cancel previous subscriptions before subscribing again
        _cancelSubscriptions();

        // Start periodic sync/check timer every 30 seconds
        _messageSyncTimer?.cancel();
        _messageSyncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
          getUnSuccessMessages();
        });

        // Subscribe to websocket message channel
        _subscriptions.add(
          ws.incomingMessage$.listen((Message event) async {
            debugPrint('[ChatService] New message received: ${event.messageId}');
            
            // Persist the incoming message to Hive immediately
            await ChatStorage.instance.saveMessage(event);

            final openConversationId = ws.currentConversationId.value;
            final isCurrentConversation = openConversationId == event.conversationId;
            final isFromMe = event.senderId == user.userId;

            if (isCurrentConversation) {
              // Channel is open. Bind/integrate the message into the channel.
              await _updateConversationLastMessage(event);
            } else {
              // Channel is closed. Highlight and show notification symbol.
              if (!isFromMe) {
                unreadCounts[event.conversationId] = (unreadCounts[event.conversationId] ?? 0) + 1;
              }
              await _updateConversationLastMessage(event);
            }
          })
        );

        _subscriptions.add(
          ws.initUserList$.listen((Map<String, dynamic> payload) async {
            debugPrint('[ChatService] Initialization user list: $payload');
            
            // Persist the conversation list payload to Hive cache
            await _saveCachedConversations(payload);

            var records = payload["conversations"];

            final parsedList = <Conversation>[];
            if (records != null) {
              for (var item in records) {
                parsedList.add(Conversation.fromJson(item));
              }
            }

            // Sort based on last active usage (newest first)
            parsedList.sort((a, b) {
              final timeA = a.lastMessageAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final timeB = b.lastMessageAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return timeB.compareTo(timeA);
            });

            conversations.value = parsedList;
          })
        );

        _subscriptions.add(
            ws.userStatus$.listen((dynamic data) async {
              final payload = data as Map<String, dynamic>?;
              if (payload == null) return;
              debugPrint('[ChatService] User status update: $payload');

              final userId = payload['user_id'] as String? ?? payload['userId'] as String?;
              final rawStatus = payload['status'];
              if (userId == null || rawStatus == null) return;

              // Parse status safely (handles both String and int)
              int parsedStatus = 0;
              if (rawStatus is int) {
                parsedStatus = rawStatus;
              } else if (rawStatus is String) {
                parsedStatus = int.tryParse(rawStatus) ?? (rawStatus.toLowerCase() == 'online' ? 1 : 0);
              }

              // Update matching participant status across conversations
              bool updatedAny = false;
              final list = List<Conversation>.from(conversations);

              for (int i = 0; i < list.length; i++) {
                final convo = list[i];
                final memberIndex = convo.members.indexWhere((m) => m.userId == userId);

                if (memberIndex != -1) {
                  // Update member
                  final existingMember = convo.members[memberIndex];
                  final updatedMember = Participant(
                    userId: existingMember.userId,
                    firstName: existingMember.firstName,
                    lastName: existingMember.lastName,
                    email: existingMember.email,
                    avatar: existingMember.avatar,
                    role: existingMember.role,
                    status: parsedStatus,
                    lastSeen: parsedStatus == 1 ? DateTime.now() : existingMember.lastSeen,
                    joinedAt: existingMember.joinedAt,
                  );

                  final updatedMembers = List<Participant>.from(convo.members);
                  updatedMembers[memberIndex] = updatedMember;

                  // If it's a direct chat (non-group), update the conversation status and lastSeen too
                  final isDirectChat = convo.type.toLowerCase() != 'group';

                  final updatedConvo = Conversation(
                    conversationId: convo.conversationId,
                    title: convo.title,
                    lastMessageAt: convo.lastMessageAt,
                    lastMessage: convo.lastMessage,
                    memberCount: convo.memberCount,
                    members: updatedMembers,
                    type: convo.type,
                    status: isDirectChat ? PresenceStatus.fromValue(parsedStatus) : convo.status,
                    lastSeen: isDirectChat && parsedStatus != 1 ? DateTime.now() : convo.lastSeen,
                    createdAt: convo.createdAt,
                    createdBy: convo.createdBy,
                    avatar: convo.avatar,
                    description: convo.description,
                    isDeleted: convo.isDeleted,
                    lastMessageId: convo.lastMessageId,
                    settings: convo.settings,
                    searchableMemberInfo: convo.searchableMemberInfo,
                    participantIds: convo.participantIds,
                  );

                  list[i] = updatedConvo;
                  updatedAny = true;
                }
              }

              if (updatedAny) {
                conversations.value = list;
                // Save updated conversations list to Hive cache
                await _saveCachedConversations({
                  "conversations": list.map((c) => c.toJson()).toList(),
                });
              }
            })
        );

        // Request user list immediately if already connected
        if (ws.isConnected) {
          ws.getInitUser();
        }

        // Request user list on future successful connection/reconnection events
        _subscriptions.add(
          ws.isConnected$.listen((isConnected) {
            if (isConnected) {
              debugPrint('[ChatService] WS connected, requesting user list');
              ws.getInitUser();
            }
          })
        );
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
      debugPrint('[ChatService] Error initiating connection: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String getParticipantName(String conversationId, String userId) {
    var result = conversations
        .where((x) => x.conversationId == conversationId)
        .expand((x) => x.members)
        .where((x) => x.userId == userId)
        .toList();

    return result.isNotEmpty ? result.first.firstName : "Member";
  }

  String? getParticipantAvatar(String conversationId, String userId) {
    if (userId == UserModel.instance.userId && UserModel.instance.imageUrl.isNotEmpty) {
      return UserModel.instance.imageUrl;
    }
    var result = conversations
        .where((x) => x.conversationId == conversationId)
        .expand((x) => x.members)
        .where((x) => x.userId == userId)
        .toList();

    return result.isNotEmpty ? result.first.avatar : null;
  }

  Future<void> _updateConversationLastMessage(Message message) async {
    final currentUserId = UserModel.instance.userId;
    
    // Check if the message was sent by the current user
    if (message.senderId == currentUserId) {
      try {
        final localMsg = ChatStorage.instance.getMessage(message.messageId);
        if (localMsg != null) {
          final updatedMsg = Message(
            id: localMsg.id,
            messageId: localMsg.messageId,
            conversationId: localMsg.conversationId,
            senderId: localMsg.senderId,
            type: localMsg.type,
            content: localMsg.content,
            fileUrl: localMsg.fileUrl,
            replyTo: localMsg.replyTo,
            mentions: localMsg.mentions,
            reactions: localMsg.reactions,
            clientType: localMsg.clientType,
            createdAt: localMsg.createdAt,
            editedAt: localMsg.editedAt,
            status: 2, // Update status to 2 (Delivered)
            receivedId: localMsg.receivedId,
            isMentioned: localMsg.isMentioned,
            seenByUserIds: localMsg.seenByUserIds,
          );
          await ChatStorage.instance.updateMessage(updatedMsg);
          debugPrint('[ChatService] Updated local message ${message.messageId} status to 2');

          final activeMsgIdx = activeMessages.indexWhere((m) => m.messageId == message.messageId);
          if (activeMsgIdx != -1) {
            activeMessages[activeMsgIdx] = updatedMsg;
          }
        }
      } catch (e) {
        debugPrint('[ChatService] Error updating local message status: $e');
      }
    }

    final idx = conversations.indexWhere((c) => c.conversationId == message.conversationId);
    if (idx != -1) {
      final convo = conversations[idx];
      final updatedConvo = Conversation(
        conversationId: convo.conversationId,
        title: convo.title,
        lastMessageAt: message.createdAt,
        lastMessage: message.content,
        memberCount: convo.memberCount,
        members: convo.members,
        type: convo.type,
        createdAt: convo.createdAt,
        createdBy: convo.createdBy,
        avatar: convo.avatar,
        description: convo.description,
        isDeleted: convo.isDeleted,
        lastMessageId: convo.lastMessageId,
        settings: convo.settings,
        searchableMemberInfo: convo.searchableMemberInfo,
        participantIds: convo.participantIds,
      );

      conversations[idx] = updatedConvo;

      // Sort conversations so the one with the newest message is first
      conversations.sort((a, b) {
        final timeA = a.lastMessageAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final timeB = b.lastMessageAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return timeB.compareTo(timeA);
      });
    }
  }
}
