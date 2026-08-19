import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../models/conversation.dart';
import '../../models/global_search_response.dart';
import '../../models/participant.dart';
import '../../models/user_model.dart';
import '../../services/http_service.dart';
import '../../core/storage/storage.dart';
import '../team/service/chat_service.dart';
import '../team/team_controller.dart';

class TeamSearchController extends GetxController {
  final RxString query = ''.obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
  final Rxn<GlobalSearchResponse> searchResponse = Rxn<GlobalSearchResponse>();
  final RxList<Conversation> results = <Conversation>[].obs;
  final RxList<String> searchHistory = <String>[].obs;
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadSearchHistory();
    searchCtrl.addListener(() {
      query.value = searchCtrl.text;
    });
    // Debounce typeahead searches by 350ms to avoid spamming the backend
    debounce(query, (_) => _performSearch(), time: const Duration(milliseconds: 350));
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  void selectHistoryItem(String val) {
    searchCtrl.text = val;
    searchCtrl.selection = TextSelection.fromPosition(TextPosition(offset: val.length));
    query.value = val;
    _performSearch();
  }

  void loadSearchHistory() {
    try {
      final raw = StorageService.instance.getValue<List<dynamic>>('search_history');
      if (raw != null) {
        searchHistory.value = raw.map((e) => e.toString()).toList();
      }
    } catch (e) {
      debugPrint('Error loading search history: $e');
    }
  }

  void addToSearchHistory(String val) {
    final cleaned = val.trim();
    if (cleaned.isEmpty) return;

    // Remove existing duplicates (case-insensitive)
    searchHistory.removeWhere((item) => item.toLowerCase() == cleaned.toLowerCase());
    
    // Insert at the top of the history list
    searchHistory.insert(0, cleaned);

    // Keep only the last 10 entries
    if (searchHistory.length > 10) {
      searchHistory.removeRange(10, searchHistory.length);
    }

    // Persist to local storage
    StorageService.instance.setValue('search_history', searchHistory.toList());
  }

  void removeFromSearchHistory(String val) {
    searchHistory.remove(val);
    StorageService.instance.setValue('search_history', searchHistory.toList());
  }

  void clearSearchHistory() {
    searchHistory.clear();
    StorageService.instance.setValue('search_history', <String>[]);
  }

  Future<void> _performSearch() async {
    final q = query.value.trim();
    if (q.length < 3) {
      results.clear();
      searchResponse.value = null;
      error.value = null;
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      // Call GET /api/search/typeahead (mapped as search/typeahead)
      final apiResponse = await HttpService.instance.get(
        'search/typeahead',
        queryParams: {
          'q': q,
          'fs': 'true',
        },
      );

      if (apiResponse.responseBody != null) {
        final globalResponse = GlobalSearchResponse.fromJson(apiResponse.responseBody);
        searchResponse.value = globalResponse;
        
        // Populate results RxList for any legacy bindings
        if (globalResponse.results?.conversations != null) {
          results.value = globalResponse.results!.conversations!;
        } else {
          results.clear();
        }
      } else {
        searchResponse.value = null;
        results.clear();
      }
    } catch (e) {
      debugPrint('Error performing search: $e');
      error.value = 'Failed to load search results: $e';
      searchResponse.value = null;
      results.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchSubmitted(String val) {
    final cleanVal = val.trim();
    if (cleanVal.length >= 3) {
      addToSearchHistory(cleanVal);
      query.value = cleanVal;
      _performSearch();
    }
  }

  void openDirectMessageWithUser(Users user) {
    final currentUserId = UserModel.instance.userId;
    // Save current query to history as they tapped a result
    addToSearchHistory(query.value);

    final teamCtrl = Get.isRegistered<TeamController>()
        ? Get.find<TeamController>()
        : Get.put(TeamController());

    // Rearrange or add the conversation locally
    teamCtrl.addOrUpdateUserConversation(user);

    // Retrieve the updated conversation from list or fallback
    Conversation? targetConvo = ChatService.instance.conversations.firstWhereOrNull((c) {
      if (c.type.toLowerCase() != 'group') {
        return c.members.any((m) => m.userId == user.userId) &&
               c.members.any((m) => m.userId == currentUserId);
      }
      return false;
    });

    targetConvo ??= Conversation(
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

    Get.back(); // close search
    Get.toNamed('/chat-detail', arguments: targetConvo);
  }

  void openConversation(Conversation c) {
    addToSearchHistory(query.value);

    final teamCtrl = Get.isRegistered<TeamController>()
        ? Get.find<TeamController>()
        : Get.put(TeamController());

    // Rearrange or add conversation locally
    teamCtrl.addOrUpdateConversation(c);

    // Retrieve from list or fallback
    final targetConvo = ChatService.instance.conversations.firstWhereOrNull(
      (x) => x.conversationId == c.conversationId,
    ) ?? c;

    Get.back();
    Get.toNamed('/chat-detail', arguments: targetConvo);
  }

  void openConversationFromMessage(String conversationId) {
    addToSearchHistory(query.value);

    final teamCtrl = Get.isRegistered<TeamController>()
        ? Get.find<TeamController>()
        : Get.put(TeamController());

    // Rearrange or add conversation locally
    teamCtrl.addOrUpdateConversationById(conversationId);

    // Retrieve from list or fallback
    final targetConvo = ChatService.instance.conversations.firstWhereOrNull(
      (x) => x.conversationId == conversationId,
    ) ?? Conversation(
      conversationId: conversationId,
      title: 'Conversation',
      type: 'direct',
      memberCount: 2,
      members: [],
      lastMessage: 'Tap to chat',
      lastMessageAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    Get.back();
    Get.toNamed('/chat-detail', arguments: targetConvo);
  }
}
