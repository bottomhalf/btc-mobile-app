import 'package:conference/models/conversation.dart';
import 'package:conference/models/user_model.dart';
import 'package:conference/services/http_service.dart';
import 'package:conference/services/meeting_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/chat_message_model.dart';

class ChatDetailController extends GetxController {
  late final Conversation conversation;

  ChatDetailController({Conversation? conversation}) {
    this.conversation = conversation ?? Get.arguments as Conversation;
  }

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isJoining = false.obs;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final _http = HttpService.instance;
  final _user = UserModel.instance;

  int _currentPage = 1;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchMessages();
  }

  @override
  void onClose() {
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

  Future<void> fetchMessages() async {
    isLoading.value = true;
    _currentPage = 1;
    _hasMore = true;
    try {
      final response = await _http.get(
        'messages/get?id=${conversation.conversationId}&page=$_currentPage&limit=20',
      );

      if (response.responseBody != null) {
        final data = response.responseBody;
        if (data != null) {
          final chatResponse = ChatMessageResponse.fromJson(data['searchResult']);
          messages.value = chatResponse.messages;
          _hasMore = chatResponse.hasMore;
          _currentPage++;
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

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversation.conversationId,
      senderId: 'currentUser', // In a real app, get from Auth service
      type: 'text',
      body: text,
      createdAt: DateTime.now(),
    );

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
  }
}
