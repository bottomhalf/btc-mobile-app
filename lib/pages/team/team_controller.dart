import 'package:conference/models/conversation.dart';
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
}
