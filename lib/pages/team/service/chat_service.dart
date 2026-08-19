import 'dart:async';
import 'package:conference/models/conversation.dart';
import 'package:conference/models/user_model.dart';
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

  final List<StreamSubscription> _subscriptions = [];

  @override
  void onClose() {
    _cancelSubscriptions();
    super.onClose();
  }

  void _cancelSubscriptions() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  void initConnection() {
    var user = UserModel.instance;
    try {
      isLoading.value = true;
      if (user.userId.isNotEmpty) {
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

        // Subscribe to websocket message channel
        _subscriptions.add(
          ws.incomingMessage$.listen((Message event) {
            debugPrint('[ChatService] New message received: $event');
            
            final openConversationId = ws.currentConversationId.value;
            if (openConversationId == event.conversationId) {
              // Channel is open. Bind/integrate the message into the channel.
              _updateConversationLastMessage(event);
            } else {
              // Channel is closed. Highlight and show notification symbol.
              unreadCounts[event.conversationId] = (unreadCounts[event.conversationId] ?? 0) + 1;
              _updateConversationLastMessage(event);
            }
          })
        );

        _subscriptions.add(
          ws.initUserList$.listen((Map<String, dynamic> payload) {
            debugPrint('[ChatService] Initialization user list: $payload');
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
