import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:conference_sdk/conference_sdk.dart' show Message;
import '../../theme/app_theme.dart';
import '../../models/conversation.dart';
import '../../models/user_model.dart';
import '../../models/participant.dart';
import '../../models/global_search_response.dart';
import '../team/service/chat_service.dart';
import 'team_search_controller.dart';

class TeamSearchPage extends GetView<TeamSearchController> {
  const TeamSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface(context),
      appBar: AppBar(
        backgroundColor: AppTheme.card(context),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppTheme.cardAlt(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller.searchCtrl,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => controller.onSearchSubmitted(value),
              style: TextStyle(
                color: AppTheme.textPrimary(context),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search people, chats, messages, files...',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary(context).withValues(alpha: 0.6),
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppTheme.textSecondary(context),
                  size: 18,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          Obx(() {
            if (controller.query.value.isEmpty) return const SizedBox();
            return IconButton(
              icon: Icon(Icons.clear_rounded, color: AppTheme.textSecondary(context)),
              onPressed: () {
                controller.searchCtrl.clear();
              },
            );
          }),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.accentPurple,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: AppTheme.divider(context).withValues(alpha: 0.3),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [Color(0xFF131224), Color(0xFF1B1A2E)]
                : const [Color(0xFFF3F5FA), Color(0xFFE8ECF5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
          final queryText = controller.query.value.trim();
          
          if (queryText.isEmpty) {
            return _buildSearchHistory(context);
          }

          if (queryText.length < 3) {
            return _buildTypeMorePrompt(context);
          }

          if (controller.isLoading.value) {
            return _buildLoadingState(context);
          }

          if (controller.error.value != null) {
            return _buildErrorState(context, controller.error.value!);
          }

          final response = controller.searchResponse.value;
          if (response == null || !response.hasResults) {
            return _buildEmptyState(context);
          }

          return _buildResultsTabs(context, response);
        }),
      ),
    );
  }

  Widget _buildSearchHistory(BuildContext context) {
    return Obx(() {
      final history = controller.searchHistory;
      if (history.isEmpty) {
        return _buildLandingState(context);
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent searches',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              TextButton(
                onPressed: () => controller.clearSearchHistory(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Clear all',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Material(
            color: AppTheme.card(context).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: AppTheme.divider(context).withValues(alpha: 0.2),
              ),
              itemBuilder: (context, index) {
                final term = history[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.history_rounded,
                    color: AppTheme.textSecondary(context).withValues(alpha: 0.7),
                    size: 20,
                  ),
                  title: Text(
                    term,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppTheme.textSecondary(context).withValues(alpha: 0.5),
                      size: 16,
                    ),
                    onPressed: () => controller.removeFromSearchHistory(term),
                  ),
                  onTap: () => controller.selectHistoryItem(term),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLandingState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                size: 64,
                color: AppTheme.primaryIndigo.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Search in Confeet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find people, direct chats, group messages, and files instantly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary(context),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeMorePrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.keyboard_outlined,
            size: 48,
            color: AppTheme.textSecondary(context).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Keep typing...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter at least 3 characters to search.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPurple),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Searching...',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errMsg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Search Error',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errMsg,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppTheme.textSecondary(context).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No matches found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for another chat, message or file name.',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabEmptyState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppTheme.textSecondary(context).withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTabs(BuildContext context, GlobalSearchResponse response) {
    final results = response.results;
    final userCount = results?.userCount ?? 0;
    final conversationCount = results?.conversationCount ?? 0;
    final messageCount = results?.messageCount ?? 0;
    final fileCount = results?.fileCount ?? 0;

    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppTheme.accentPurple,
            labelColor: AppTheme.textPrimary(context),
            unselectedLabelColor: AppTheme.textSecondary(context),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
            dividerColor: AppTheme.divider(context).withValues(alpha: 0.3),
            tabs: [
              const Tab(text: 'All'),
              Tab(text: 'People ($userCount)'),
              Tab(text: 'Chats ($conversationCount)'),
              Tab(text: 'Messages ($messageCount)'),
              Tab(text: 'Files ($fileCount)'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAllTab(context, response),
                _buildPeopleTab(context, results?.users ?? []),
                _buildChatsTab(context, results?.conversations ?? []),
                _buildMessagesTab(context, results?.messages ?? []),
                _buildFilesTab(context, results?.files ?? []),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllTab(BuildContext context, GlobalSearchResponse response) {
    if (!response.hasResults) {
      return _buildEmptyState(context);
    }

    final results = response.results;
    final users = results?.users ?? [];
    final conversations = results?.conversations ?? [];
    final messages = results?.messages ?? [];
    final files = results?.files ?? [];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        if (users.isNotEmpty) ...[
          _buildSectionHeader(context, 'People', 1),
          ...users.take(3).map((u) => _buildUserTile(context, u)),
          const SizedBox(height: 12),
        ],
        if (conversations.isNotEmpty) ...[
          _buildSectionHeader(context, 'Chats', 2),
          ...conversations.take(3).map((c) => _buildSearchTile(context, c)),
          const SizedBox(height: 12),
        ],
        if (messages.isNotEmpty) ...[
          _buildSectionHeader(context, 'Messages', 3),
          ...messages.take(3).map((m) => _buildMessageTile(context, m)),
          const SizedBox(height: 12),
        ],
        if (files.isNotEmpty) ...[
          _buildSectionHeader(context, 'Files', 4),
          ...files.take(3).map((f) => _buildFileTile(context, f)),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int tabIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
            ),
          ),
          TextButton(
            onPressed: () {
              DefaultTabController.of(context).animateTo(tabIndex);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'See all',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.accentPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleTab(BuildContext context, List<Users> users) {
    if (users.isEmpty) {
      return _buildSubTabEmptyState(context, 'No people matches found');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: users.length,
      itemBuilder: (context, index) => _buildUserTile(context, users[index]),
    );
  }

  Widget _buildChatsTab(BuildContext context, List<Conversation> conversations) {
    if (conversations.isEmpty) {
      return _buildSubTabEmptyState(context, 'No chat matches found');
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: conversations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildSearchTile(context, conversations[index]),
    );
  }

  Widget _buildMessagesTab(BuildContext context, List<Message> messages) {
    if (messages.isEmpty) {
      return _buildSubTabEmptyState(context, 'No message matches found');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) => _buildMessageTile(context, messages[index]),
    );
  }

  Widget _buildFilesTab(BuildContext context, List<SearchResultItem> files) {
    if (files.isEmpty) {
      return _buildSubTabEmptyState(context, 'No file matches found');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: files.length,
      itemBuilder: (context, index) => _buildFileTile(context, files[index]),
    );
  }

  Widget _buildUserTile(BuildContext context, Users user) {
    String initials = '?';
    if (user.fullName.isNotEmpty) {
      final parts = user.fullName.split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = user.fullName[0].toUpperCase();
      }
    }

    final gradients = [
      const [Color(0xFF6C5CE7), Color(0xFF8E7CF3)],
      const [Color(0xFF2D7FF9), Color(0xFF18BFFF)],
      const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      const [Color(0xFF00B894), Color(0xFF55EFC4)],
      const [Color(0xFFE17055), Color(0xFFF8A5C2)],
    ];
    final nameKey = user.fullName.length >= 2 ? user.fullName.substring(0, 2).toLowerCase() : user.fullName.toLowerCase();
    final colorPair = gradients[nameKey.hashCode.abs() % gradients.length];

    final hasImage = user.imageUrl != null && user.imageUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: AppTheme.card(context).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: hasImage ? null : LinearGradient(colors: colorPair),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: hasImage
                  ? Image.network(
                      user.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          initials,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initials,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
            ),
          ),
          title: Text(
            user.fullName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
            ),
          ),
          subtitle: Text(
            user.email,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary(context),
            ),
          ),
          onTap: () => controller.openDirectMessageWithUser(user),
        ),
      ),
    );
  }

  Widget _buildMessageTile(BuildContext context, Message msg) {
    // Try to find the cached conversation title
    final convo = ChatService.instance.conversations.firstWhereOrNull(
      (c) => c.conversationId == msg.conversationId,
    );
    final chatTitle = convo?.title ?? 'Chat';

    // Formatted date snippet
    String dateStr = '';
    if (msg.createdAt != null) {
      final diff = DateTime.now().difference(msg.createdAt!);
      if (diff.inDays == 0) {
        dateStr = '${msg.createdAt!.hour.toString().padLeft(2, '0')}:${msg.createdAt!.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays < 7) {
        final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        dateStr = weekdays[msg.createdAt!.weekday - 1];
      } else {
        dateStr = '${msg.createdAt!.day}/${msg.createdAt!.month}';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: AppTheme.card(context).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigo.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryIndigo, size: 20),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  chatTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (dateStr.isNotEmpty)
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary(context).withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              msg.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary(context),
              ),
            ),
          ),
          onTap: () => controller.openConversationFromMessage(msg.conversationId),
        ),
      ),
    );
  }

  Widget _buildFileTile(BuildContext context, SearchResultItem file) {
    IconData iconData = Icons.insert_drive_file_rounded;
    Color iconColor = Colors.grey;

    final nameLower = file.name.toLowerCase();
    if (nameLower.endsWith('.pdf')) {
      iconData = Icons.picture_as_pdf_rounded;
      iconColor = Colors.redAccent;
    } else if (nameLower.endsWith('.doc') || nameLower.endsWith('.docx')) {
      iconData = Icons.description_rounded;
      iconColor = Colors.blueAccent;
    } else if (nameLower.endsWith('.xls') || nameLower.endsWith('.xlsx') || nameLower.endsWith('.csv')) {
      iconData = Icons.table_chart_rounded;
      iconColor = Colors.green;
    } else if (nameLower.endsWith('.zip') || nameLower.endsWith('.rar')) {
      iconData = Icons.folder_zip_rounded;
      iconColor = Colors.orange;
    } else if (nameLower.endsWith('.png') || nameLower.endsWith('.jpg') || nameLower.endsWith('.jpeg')) {
      iconData = Icons.image_rounded;
      iconColor = Colors.purple;
    }

    String subtitle = 'File';
    if (file.uploadedBy != null) {
      subtitle += ' • Uploaded by ${file.uploadedBy}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: AppTheme.card(context).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 22),
          ),
          title: Text(
            file.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary(context),
            ),
          ),
          onTap: () {
            if (file.url != null && file.url!.isNotEmpty) {
              Get.snackbar(
                'File Selected',
                file.name,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.primaryIndigo,
                colorText: Colors.white,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchTile(BuildContext context, Conversation c) {
    final isGroup = c.type == 'group';
    final currentUserId = UserModel.instance.userId;

    String title = c.title;
    if (title.isEmpty) {
      title = isGroup ? 'Group Chat' : 'Direct Message';
    }

    String initials = '?';
    if (title.isNotEmpty) {
      final parts = title.trim().split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = title[0].toUpperCase();
      }
    }

    final gradients = [
      const [Color(0xFF6C5CE7), Color(0xFF8E7CF3)],
      const [Color(0xFF2D7FF9), Color(0xFF18BFFF)],
      const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      const [Color(0xFF00B894), Color(0xFF55EFC4)],
      const [Color(0xFFE17055), Color(0xFFF8A5C2)],
    ];
    final nameKey = title.length >= 2 ? title.substring(0, 2).toLowerCase() : title.toLowerCase();
    final colorPair = gradients[nameKey.hashCode.abs() % gradients.length];

    Widget avatar;
    if (isGroup) {
      final otherMembers = c.members.where((m) => m.userId != currentUserId).toList();
      if (otherMembers.isNotEmpty) {
        avatar = SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            children: [
              for (int i = 0; i < otherMembers.take(2).length; i++)
                Positioned(
                  left: i * 14.0,
                  top: i * 6.0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.card(context),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: otherMembers[i].avatar != null && otherMembers[i].avatar!.isNotEmpty
                          ? Image.network(
                              otherMembers[i].avatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: colorPair[0],
                                child: Center(
                                  child: Text(
                                    otherMembers[i].firstName.isNotEmpty ? otherMembers[i].firstName[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: colorPair[0],
                              child: Center(
                                child: Text(
                                  otherMembers[i].firstName.isNotEmpty ? otherMembers[i].firstName[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
            ],
          ),
        );
      } else {
        avatar = Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colorPair),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        );
      }
    } else {
      final otherMember = c.members.firstWhere(
        (m) => m.userId != currentUserId,
        orElse: () => Participant(
          userId: '',
          firstName: title,
          email: '',
          role: '',
          status: 0,
          lastSeen: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );

      final hasImage = otherMember.avatar != null && otherMember.avatar!.isNotEmpty;
      avatar = Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: hasImage ? null : LinearGradient(colors: colorPair),
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: hasImage
              ? Image.network(
                  otherMember.avatar!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      initials,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    initials,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            controller.openConversation(c);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                avatar,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.lastMessage?.isNotEmpty == true ? c.lastMessage! : (isGroup ? 'Group Chat' : 'Tap to chat'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppTheme.textSecondary(context).withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
