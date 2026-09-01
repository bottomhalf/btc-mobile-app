import 'dart:async';
import 'package:conference/models/conversation.dart';
import 'package:conference/models/user_model.dart';
import 'package:conference/pages/team/service/chat_service.dart';
import 'package:conference/services/http_service.dart';
import 'package:conference/services/meeting_service.dart';
import 'package:conference_sdk/conference_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../models/chat_message_model.dart';

class ChatDetailController extends GetxController {
  late Conversation conversation;

  ChatDetailController({Conversation? conversation}) {
    this.conversation = conversation ?? Get.arguments as Conversation;
  }

  RxList<Message> get messages => _chatService.activeMessages;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isJoining = false.obs;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final _http = HttpService.instance;
  final _user = UserModel.instance;
  final _chatService = ChatService.instance;
  final List<StreamSubscription> _localSubscriptions = [];

  int _currentPage = 1;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatService.ws.currentConversationId.value = conversation.conversationId;
      _chatService.unreadCounts[conversation.conversationId] =
          0; // Clear unread badge
    });
    scrollController.addListener(_onScroll);
    
    // 1. Load local cached messages first
    _loadLocalCachedMessages();

    // 2. Fetch server messages in background
    fetchMessages();
    _setupSocketListeners();
  }

  @override
  void onClose() {
    _chatService.activeMessages.clear(); // Clear so next chat starts fresh
    _chatService.ws.currentConversationId.value = null; // Unbind
    for (final sub in _localSubscriptions) {
      sub.cancel();
    }
    _localSubscriptions.clear();
    scrollController.dispose();
    messageController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMoreMessages();
    }
  }

  /// Marks all incoming unread messages in the loaded list as seen,
  /// sending a markSeen WebSocket event and updating local database status.
  void markIncomingMessagesAsSeen(List<Message> loadedMessages) {
    try {
      final currentUserId = _user.userId;
      if (currentUserId.isEmpty) return;

      bool didUpdateAny = false;

      for (final msg in loadedMessages) {
        // Only mark messages sent by others that are not already marked seen (status == 3)
        if (msg.senderId != currentUserId && msg.status != 3) {
          debugPrint('[ChatDetailController] Marking message as seen: ${msg.messageId}');
          
          // 1. Send socket event to notify sender / server
          _chatService.ws.markSeen(
            msg.messageId,
            currentUserId,
            conversation.conversationId,
          );

          // 2. Create updated message with status = 3
          final updatedMsg = Message(
            id: msg.id,
            messageId: msg.messageId,
            conversationId: msg.conversationId,
            senderId: msg.senderId,
            type: msg.type,
            content: msg.content,
            fileUrl: msg.fileUrl,
            replyTo: msg.replyTo,
            mentions: msg.mentions,
            reactions: msg.reactions,
            clientType: msg.clientType,
            createdAt: msg.createdAt,
            editedAt: msg.editedAt,
            status: 3, // 3 = Seen
            receivedId: msg.receivedId,
            isMentioned: msg.isMentioned,
            seenByUserIds: msg.seenByUserIds != null
                ? {...msg.seenByUserIds!, currentUserId}.toList()
                : [currentUserId],
          );
          
          // 3. Save to local storage
          ChatStorage.instance.saveMessage(updatedMsg);

          // 4. Update the in-memory RxList to re-render in UI
          final idx = messages.indexWhere((m) => m.messageId == msg.messageId);
          if (idx != -1) {
            messages[idx] = updatedMsg;
            didUpdateAny = true;
          }
        }
      }
      
      if (didUpdateAny) {
        messages.refresh();
      }
    } catch (e) {
      debugPrint('[ChatDetailController] Error marking messages as seen: $e');
    }
  }

  /// Loads cached messages from Hive storage for immediate offline-first rendering.
  void _loadLocalCachedMessages() {
    try {
      final List<Message> cached = ChatStorage.instance
          .getAllMessages()
          .where((m) => m.conversationId == conversation.conversationId)
          .toList();

      if (cached.isNotEmpty) {
        // Sort descending by creation time (newest first)
        cached.sort((a, b) {
          final timeA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final timeB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return timeB.compareTo(timeA);
        });

        messages.value = cached;
        isLoading.value = false;
        debugPrint('[ChatDetailController] Loaded ${cached.length} messages from Hive.');

        // Mark local cached unread messages as seen
        markIncomingMessagesAsSeen(cached);
      } else {
        // Keep loading = true to show spinner until server responds
        isLoading.value = true;
        debugPrint('[ChatDetailController] No cached messages found. Waiting for server fetch.');
      }
    } catch (e) {
      debugPrint('[ChatDetailController] Error loading cached messages: $e');
    }
  }

  /// Fetches latest messages from server in the background and merges them with local cache.
  Future<void> fetchMessages() async {
    _currentPage = 1;
    _hasMore = true;
    try {
      final response = await _http.get(
        'messages/get?id=${conversation.conversationId}&page=$_currentPage&limit=20',
      );

      if (response.responseBody != null) {
        final data = response.responseBody;
        if (data != null) {
          final chatResponse = ChatMessageResponse.fromJson(
            data['searchResult'],
          );

          final List<Message> serverMessages = chatResponse.messages;

          // Load local cached messages to merge
          final List<Message> localCached = ChatStorage.instance
              .getAllMessages()
              .where((m) => m.conversationId == conversation.conversationId)
              .toList();

          final Map<String, Message> mergedMap = {};

          // Add all local cached messages first
          for (final msg in localCached) {
            mergedMap[msg.messageId] = msg;
          }

          // Add server messages, overwriting the matching local ones (taking server as source of truth)
          for (final msg in serverMessages) {
            mergedMap[msg.messageId] = msg;
          }

          final List<Message> mergedList = mergedMap.values.toList();

          // Sort merged list descending by creation time (newest first)
          mergedList.sort((a, b) {
            final timeA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final timeB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return timeB.compareTo(timeA);
          });

          messages.value = mergedList;
          _hasMore = chatResponse.hasMore;
          _currentPage++;

          // Mark fetched server unread messages as seen
          markIncomingMessagesAsSeen(serverMessages);
        }
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreMessages() async {
    if (isLoadingMore.value || !_hasMore) return;

    isLoadingMore.value = true;
    try {
      final response = await _http.get(
        'messages/get?id=${conversation.conversationId}&page=$_currentPage&limit=20',
      );

      if (response.responseBody != null &&
          response.responseBody['ResponseBody'] != null) {
        final data = response.responseBody['ResponseBody'];
        if (data['messages'] != null) {
          final chatResponse = ChatMessageResponse.fromJson(data);
          messages.addAll(chatResponse.messages);
          _hasMore = chatResponse.hasMore;
          _currentPage++;

          // Mark more loaded unread messages as seen
          markIncomingMessagesAsSeen(chatResponse.messages);
        }
      }
    } catch (e) {
      debugPrint('Error loading more messages: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Open a recent meeting → triggers the PiP overlay.
  Future<void> joinMeeting() async {
    isJoining.value = true;
    try {
      await MeetingService.instance.joinMeeting(
        roomId: conversation.conversationId,
        participantName: _user.fullName,
        meetingTitle: conversation.title,
      );
    } catch (e) {
      Get.snackbar(
        'Connection Failed',
        'Failed to join: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isJoining.value = false;
    }
  }

  String findOtherRecipientUserId() {
    var nextUser = conversation.members
        .where((x) => x.userId != _user.userId)
        .first;

    return nextUser.userId;
  }

  Future<String?> generateConversationId(
    String senderId,
    String recipientId,
  ) async {
    String? nextConversationId;

    try {
      final response = await _http.put(
        "conversations/create/$senderId/$recipientId",
      );
      if (response.responseBody != null) {
        final parsedConvo = Conversation.fromJson(
          response.responseBody as Map<String, dynamic>,
        );

        nextConversationId = parsedConvo.conversationId;
      }
    } catch (e) {
      debugPrint('Error generating conversation ID: $e');
    }

    return nextConversationId;
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    try {
      final String generatedMessageId = const Uuid().v4();
      var recipientUserId = findOtherRecipientUserId();
      var convId = await generateConversationId(_user.userId, recipientUserId);

      if (convId == null) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Failed to generate conversation ID.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFF6B6B),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }

      final newMessage = Message(
        conversationId: convId,
        messageId: generatedMessageId,
        senderId: _user.userId,
        type: 'text',
        replyTo: null,
        mentions: [],
        reactions: [],
        clientType: 'mobile',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch,
          isUtc: true,
        ),
        editedAt: null,
        status: 1,
        // 0 = pending/local storage
        content: text,
        fileUrl: null,
      );

      _chatService.ws.sendMessage(newMessage);
      await ChatStorage.instance.saveMessage(newMessage);

      // Insert at beginning because messages are latest-first
      messages.insert(0, newMessage);
      messageController.clear();

      // In a real app, this would call an API to send the message
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void _setupSocketListeners() {
    // 1. Listen for new incoming messages from other people
    _localSubscriptions.add(
      _chatService.ws.incomingMessage$.listen((Message message) {
        if (message.conversationId == conversation.conversationId) {
          final idx = messages.indexWhere(
            (m) => m.messageId == message.messageId,
          );
          
          final isMe = message.senderId == _user.userId;
          final resolvedMessage = isMe
              ? Message(
                  id: message.id,
                  messageId: message.messageId,
                  conversationId: message.conversationId,
                  senderId: message.senderId,
                  type: message.type,
                  content: message.content,
                  fileUrl: message.fileUrl,
                  replyTo: message.replyTo,
                  mentions: message.mentions,
                  reactions: message.reactions,
                  clientType: message.clientType,
                  createdAt: message.createdAt,
                  editedAt: message.editedAt,
                  status: 2, // Map to double check status when acknowledged/broadcasted back
                  receivedId: message.receivedId,
                  isMentioned: message.isMentioned,
                  seenByUserIds: message.seenByUserIds,
                )
              : message;

          if (idx == -1) {
            messages.insert(0, resolvedMessage);
          } else {
            messages[idx] = resolvedMessage;
          }
          // Mark real-time incoming messages as seen
          markIncomingMessagesAsSeen([resolvedMessage]);
        }
      }),
    );

    // 2. Listen for outgoing message acknowledgements (status 2 - double tick)
    _localSubscriptions.add(
      _chatService.ws.outgoingMessage$.listen((Message message) {
        if (message.conversationId == conversation.conversationId) {
          final idx = messages.indexWhere(
            (m) => m.messageId == message.messageId,
          );
          if (idx != -1) {
            final updatedMsg = Message(
              id: message.id,
              messageId: message.messageId,
              conversationId: message.conversationId,
              senderId: message.senderId,
              type: message.type,
              content: message.content,
              fileUrl: message.fileUrl,
              replyTo: message.replyTo,
              mentions: message.mentions,
              reactions: message.reactions,
              clientType: message.clientType,
              createdAt: message.createdAt,
              editedAt: message.editedAt,
              status: 2, // 2 = Pushed / Double check
            );
            messages[idx] = updatedMsg;
          }
        }
      }),
    );

    // 3. Listen for seen updates (status 3 - small avatar)
    _localSubscriptions.add(
      _chatService.ws.seen$.listen((MessageSeen seenEvent) {
        if (seenEvent.conversationId == conversation.conversationId) {
          final idx = messages.indexWhere(
            (m) => m.messageId == seenEvent.messageId,
          );
          if (idx != -1) {
            final oldMsg = messages[idx];
            final updatedMsg = Message(
              id: oldMsg.id,
              messageId: oldMsg.messageId,
              conversationId: oldMsg.conversationId,
              senderId: oldMsg.senderId,
              type: oldMsg.type,
              content: oldMsg.content,
              fileUrl: oldMsg.fileUrl,
              replyTo: oldMsg.replyTo,
              mentions: oldMsg.mentions,
              reactions: oldMsg.reactions,
              clientType: oldMsg.clientType,
              createdAt: oldMsg.createdAt,
              editedAt: oldMsg.editedAt,
              status: 3, // 3 = Seen / Small avatar
            );
            messages[idx] = updatedMsg;
          }
        }
      }),
    );
  }
}
