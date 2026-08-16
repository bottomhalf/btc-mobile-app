import 'package:get/get.dart';
import '../team/service/chat_service.dart';
import '../../models/conversation.dart';

class TeamSearchController extends GetxController {
  final RxString query = ''.obs;
  final RxList<Conversation> results = <Conversation>[].obs;

  @override
  void onInit() {
    super.onInit();
    ever(query, (_) => _performSearch());
    ever(ChatService.instance.conversations, (_) => _performSearch());
    _performSearch();
  }

  void _performSearch() {
    final q = query.value.trim().toLowerCase();
    final allConversations = ChatService.instance.conversations;

    if (q.isEmpty) {
      results.value = allConversations;
      return;
    }

    results.value = allConversations.where((c) {
      final title = c.title.toLowerCase();
      final lastMsg = (c.lastMessage ?? '').toLowerCase();
      
      final participantMatch = c.members.any((p) {
        final fullName = p.firstName.toLowerCase();
        return fullName.contains(q);
      });

      return title.contains(q) || lastMsg.contains(q) || participantMatch;
    }).toList();
  }
}
