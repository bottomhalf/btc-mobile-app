import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../models/conversation.dart';
import '../../models/user_model.dart';
import '../../models/participant.dart';
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary(context),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: TextField(
          autofocus: true,
          style: TextStyle(
            color: AppTheme.textPrimary(context),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Search chats, members...',
            hintStyle: TextStyle(
              color: AppTheme.textSecondary(context).withValues(alpha: 0.6),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (value) {
            controller.query.value = value;
          },
        ),
        centerTitle: false,
        actions: [
          Obx(() {
            if (controller.query.value.isEmpty) return const SizedBox();
            return IconButton(
              icon: Icon(Icons.clear_rounded, color: AppTheme.textSecondary(context)),
              onPressed: () {
                controller.query.value = '';
              },
            );
          }),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: AppTheme.divider(context).withValues(alpha: 0.5),
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
          final results = controller.results;
          
          if (results.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: results.length,
            separatorBuilder: (context, index) => Divider(
              color: AppTheme.divider(context).withValues(alpha: 0.3),
              height: 1,
              indent: 66,
            ),
            itemBuilder: (context, index) {
              final chat = results[index];
              return _buildSearchTile(context, chat);
            },
          );
        }),
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
            'Try searching for another chat or member name.',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary(context),
            ),
          ),
        ],
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
            Get.back(); // close search
            Get.toNamed('/chat-detail', arguments: c); // open chat
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
