import 'package:conference/models/conversation.dart';
import 'package:conference/models/global_search_response.dart';
import 'package:conference/models/participant.dart';
import 'package:conference/models/user_model.dart';
import 'package:get/get.dart';
import 'service/chat_service.dart';

class TeamController extends GetxController {
  /// Currently selected conversation for desktop master-detail view.
  final Rx<Conversation?> selectedConversation = Rx<Conversation?>(null);

  // Getters delegating state to global ChatService
  RxBool get isLoading => ChatService.instance.isLoading;
  RxString get errorMessage => ChatService.instance.errorMessage;
  RxList<Conversation> get conversations => ChatService.instance.conversations;

  @override
  void onInit() {
    super.onInit();
    initConnection();
  }

  /// Delegated trigger to reconnect/initiate connection in ChatService.
  void initConnection() {
    ChatService.instance.initConnection();
  }

  /// Opens a conversation in a new route (used on mobile).
  void openTeam(Conversation meeting) {
    Get.toNamed('/chat-detail', arguments: meeting);
  }

  /// Selects a conversation inline (used on desktop master-detail).
  void selectConversation(Conversation meeting) {
    selectedConversation.value = meeting;
  }

  /// Rearranges or adds a conversation to the local list, ensuring it's sorted by time.
  void addOrUpdateConversation(Conversation conversation) {
    final list = ChatService.instance.conversations;
    final existingIndex = list.indexWhere((c) => c.conversationId == conversation.conversationId);

    if (existingIndex != -1) {
      // Conversation exists: update its last active time to now to bubble it up
      final existing = list[existingIndex];
      final updated = Conversation(
        conversationId: existing.conversationId,
        title: existing.title,
        type: existing.type,
        memberCount: existing.memberCount,
        members: existing.members,
        lastMessage: existing.lastMessage,
        lastMessageAt: DateTime.now(), // Update time to bubble it up
        createdAt: existing.createdAt,
        createdBy: existing.createdBy,
      );
      list[existingIndex] = updated;
    } else {
      // Conversation does not exist: create/add it with lastMessageAt = now
      final newConvo = Conversation(
        conversationId: conversation.conversationId,
        title: conversation.title,
        type: conversation.type,
        memberCount: conversation.memberCount,
        members: conversation.members,
        lastMessage: conversation.lastMessage ?? 'Tap to chat',
        lastMessageAt: DateTime.now(),
        createdAt: conversation.createdAt ?? DateTime.now(),
        createdBy: conversation.createdBy,
      );
      list.add(newConvo);
    }

    // Sort based on last active usage (newest first)
    list.sort((a, b) {
      final timeA = a.lastMessageAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeB = b.lastMessageAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return timeB.compareTo(timeA);
    });
  }

  /// Rearranges or adds a direct message conversation with a specific user.
  void addOrUpdateUserConversation(Users user) {
    final currentUserId = UserModel.instance.userId;
    
    // Check if we already have a DM conversation with this user
    Conversation? existingConvo;
    final list = ChatService.instance.conversations;
    for (final c in list) {
      if (c.type != 'group') {
        final hasTarget = c.members.any((m) => m.userId == user.userId);
        final hasMe = c.members.any((m) => m.userId == currentUserId);
        if (hasTarget && hasMe) {
          existingConvo = c;
          break;
        }
      }
    }

    if (existingConvo != null) {
      addOrUpdateConversation(existingConvo);
    } else {
      // Create transient DM conversation
      final tempConvo = Conversation(
        conversationId: user.userId,
        title: user.fullName,
        type: 'direct',
        memberCount: 2,
        members: [
          Participant(
            userId: user.userId,
            firstName: user.firstName,
            email: user.email,
            avatar: user.imageUrl,
            role: user.role ?? 'member',
            status: 1,
            lastSeen: DateTime.now(),
          ),
          Participant(
            userId: currentUserId,
            firstName: UserModel.instance.firstName,
            email: UserModel.instance.email,
            avatar: UserModel.instance.imageUrl,
            role: 'member',
            status: 1,
            lastSeen: DateTime.now(),
          ),
        ],
        lastMessage: 'Tap to chat',
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      addOrUpdateConversation(tempConvo);
    }
  }

  /// Rearranges or adds a conversation by ID (used for messages search results).
  void addOrUpdateConversationById(String conversationId) {
    final list = ChatService.instance.conversations;
    final existingIndex = list.indexWhere((c) => c.conversationId == conversationId);
    
    if (existingIndex != -1) {
      final existing = list[existingIndex];
      addOrUpdateConversation(existing);
    } else {
      // Create a skeleton conversation and add it
      final tempConvo = Conversation(
        conversationId: conversationId,
        title: 'Conversation',
        type: 'direct',
        memberCount: 2,
        members: [],
        lastMessage: 'Tap to chat',
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      addOrUpdateConversation(tempConvo);
    }
  }
}
