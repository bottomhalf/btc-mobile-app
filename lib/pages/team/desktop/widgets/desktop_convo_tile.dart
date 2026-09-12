import 'package:conference/models/conversation.dart';
import 'package:conference/models/presence_status.dart';
import 'package:conference/models/user_model.dart';
import 'package:conference/pages/team/service/chat_service.dart';
import 'package:conference/pages/team/team_controller.dart';
import 'package:conference/shared/widgets/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Conversation tile styled to match the team.png reference design.
///
/// Features:
/// - Distinct pastel avatar circles (green, salmon, peach, blue, grey)
/// - Status indicator badge on bottom-right (green checkmark for online, grey cross for offline)
/// - Bold title, last message / "No messages yet", and right-aligned timestamp
/// - Active selection state: blue vertical accent bar on left edge & light blue background tint
class DesktopConvoTile extends StatelessWidget {
  const DesktopConvoTile({
    super.key,
    required this.c,
    required this.controller,
  });

  final Conversation c;
  final TeamController controller;

  @override
  Widget build(BuildContext context) {
    final isGroup = c.type == 'group';

    String title = c.title;
    if (title.isEmpty) {
      title = isGroup ? 'Group Chat' : 'Direct Message';
    }

    return Obx(() {
      final isSelected =
          controller.selectedConversation.value?.conversationId ==
              c.conversationId;

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.selectConversation(c),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFEFF6FF) // Light blue tint
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Left vertical indicator bar for active/selected state
                  if (isSelected)
                    Positioned(
                      left: 0,
                      top: 6,
                      bottom: 6,
                      child: Container(
                        width: 3.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6), // Blue accent bar
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Row(
                      children: [
                        _buildAvatar(context, c, title, isGroup),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Obx(() {
                            final unreadCount = ChatService
                                    .instance.unreadCounts[c.conversationId] ??
                                0;
                            final hasUnread = unreadCount > 0;

                            final subtitle = c.lastMessage ??
                                (isGroup
                                    ? 'No messages in space'
                                    : 'No messages yet');

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: isSelected || hasUnread
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      c.timeAgo,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: hasUnread
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: hasUnread
                                            ? const Color(0xFF3B82F6)
                                            : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: hasUnread
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: hasUnread
                                              ? const Color(0xFF1F2937)
                                              : const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ),
                                    if (hasUnread) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAvatar(
    BuildContext context,
    Conversation c,
    String title,
    bool isGroup,
  ) {
    final currentUserId = UserModel.instance.userId;

    // Palette matching team.png (green, salmon, peach, blue, grey)
    final pastelColors = [
      const Color(0xFF4ADE80), // Green (MR)
      const Color(0xFFF87171), // Salmon/Red (VK)
      const Color(0xFFFDBA74), // Peach (B / BA)
      const Color(0xFF60A5FA), // Blue (VM)
      const Color(0xFFFB7185), // Coral (DS)
      const Color(0xFF9CA3AF), // Grey (I)
    ];

    final colorIndex =
        c.conversationId.hashCode.abs() % pastelColors.length;
    final avatarBg = pastelColors[colorIndex];

    if (isGroup) {
      return AppAvatar(
        imageUrl: c.avatar,
        name: title,
        size: 36,
        backgroundColor: avatarBg,
      );
    }

    // Direct Chat with online/offline status dot
    final otherMembers =
        c.members.where((m) => m.userId != currentUserId).toList();
    final otherMember =
        otherMembers.isNotEmpty ? otherMembers.first : null;
    final avatarUrl = otherMember?.avatar ?? c.avatar;

    final isOnline =
        otherMember != null && otherMember.status == PresenceStatus.online.value;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppAvatar(
          imageUrl: avatarUrl,
          name: title,
          size: 36,
          backgroundColor: avatarBg,
        ),
        Positioned(
          bottom: -1,
          right: -1,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: isOnline
                  ? const Color(0xFF22C55E) // Green checkmark circle
                  : Colors.white, // White circle with grey border
              shape: BoxShape.circle,
              border: Border.all(
                color: isOnline ? Colors.white : const Color(0xFF9CA3AF),
                width: 1.2,
              ),
            ),
            child: Icon(
              isOnline ? Icons.check : Icons.close,
              size: 8,
              color: isOnline ? Colors.white : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ],
    );
  }
}
