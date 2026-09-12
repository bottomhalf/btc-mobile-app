import 'package:conference/models/conversation.dart';
import 'package:conference/models/participant.dart';
import 'package:conference/models/presence_status.dart';
import 'package:conference/models/user_model.dart';
import 'package:conference/pages/team/chat_detail_controller.dart';
import 'package:conference/shared/widgets/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Card showing rich user / space metadata at the very top of the chat history
/// or when there are no messages, preventing the page from looking blank on mobile.
class ChatHistoryHeader extends StatelessWidget {
  final Conversation convo;
  final bool isEmptyState;
  final ChatDetailController? controller;

  const ChatHistoryHeader({
    super.key,
    required this.convo,
    this.isEmptyState = false,
    this.controller,
  });

  void _onStarterTapped(String text) {
    if (controller != null) {
      controller!.messageController.text = text;
      return;
    }
    try {
      final ctrl = Get.find<ChatDetailController>(tag: convo.conversationId);
      ctrl.messageController.text = text;
    } catch (_) {
      try {
        final ctrl = Get.find<ChatDetailController>();
        ctrl.messageController.text = text;
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isGroup = convo.type.toLowerCase() == 'group';
    final currentUserId = UserModel.instance.userId;

    final otherMembers =
        convo.members.where((m) => m.userId != currentUserId).toList();
    final otherMember =
        otherMembers.isNotEmpty ? otherMembers.first : null;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? null : Colors.white,
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF22222A),
                    Color(0xFF131318),
                    Color(0xFF0E0E12),
                  ],
                  stops: [0.0, 0.45, 1.0],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.16)
                : const Color(0xFFE5E7EB),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.03),
              blurRadius: isDark ? 14 : 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isGroup
            ? _buildGroupCard(context)
            : _buildDirectChatCard(context, otherMember),
      ),
    );
  }

  Widget _buildDirectChatCard(BuildContext context, Participant? other) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = other != null && other.firstName.isNotEmpty
        ? '${other.firstName} ${other.lastName ?? ''}'.trim()
        : (convo.title.isNotEmpty ? convo.title : 'Direct Message');

    final email = other?.email ?? '';
    final avatarUrl = other?.avatar ?? convo.avatar;
    final isOnline =
        other != null && other.status == PresenceStatus.online.value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            AppAvatar(
              imageUrl: avatarUrl,
              name: name,
              size: 64,
              fontSize: 22,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFFE5E7EB),
                width: 2,
              ),
            ),
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: isOnline
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF9CA3AF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF131318) : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Text(
          name,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (email.isNotEmpty) ...[
              Text(
                email,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '•',
                style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFFD1D5DB),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isOnline
                    ? (isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7))
                    : (isDark ? const Color(0xFF1E1E26) : const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isOnline
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF9CA3AF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOnline ? 'Active Now' : 'Offline',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isOnline
                          ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
                          : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Divider(
          height: 1,
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFF3F4F6),
        ),
        const SizedBox(height: 12),

        Text(
          'This is the beginning of your 1-on-1 message history with $name. Direct messages sent here are private.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : const Color(0xFF4B5563),
            height: 1.4,
          ),
        ),

        const SizedBox(height: 14),

        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            _buildQuickChip(context, '👋 Say Hello!'),
            _buildQuickChip(context, '📅 Quick meeting?'),
            _buildQuickChip(context, '🚀 Ready to start!'),
          ],
        ),
      ],
    );
  }

  Widget _buildGroupCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = convo.title.isNotEmpty ? convo.title : 'Group Space';
    final memberCount = convo.memberCount > 0
        ? convo.memberCount
        : convo.members.length;

    Participant? admin;
    for (var m in convo.members) {
      if (m.role.toLowerCase() == 'admin' ||
          m.role.toLowerCase() == 'creator') {
        admin = m;
        break;
      }
    }
    final creatorName = convo.createdBy != null && convo.createdBy!.isNotEmpty
        ? convo.createdBy!
        : (admin != null ? admin.firstName : 'Team');

    final createdDate =
        convo.createdAt ?? convo.lastMessageAt ?? DateTime.now();
    final formattedDate =
        '${createdDate.month}/${createdDate.day}/${createdDate.year}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppAvatar(
          imageUrl: convo.avatar,
          name: title,
          size: 64,
          borderRadius: BorderRadius.circular(14),
          backgroundColor: const Color(0xFFFB7185),
          fontSize: 22,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        const SizedBox(height: 12),

        Text(
          title,
          style: TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                      : const Color(0xFFBFDBFE),
                ),
              ),
              child: Text(
                'GROUP SPACE',
                style: TextStyle(
                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF1D4ED8),
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$memberCount members',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Text(
          convo.description != null && convo.description!.isNotEmpty
              ? convo.description!
              : 'Welcome to $title! Everyone in this space can collaborate and share updates.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : const Color(0xFF4B5563),
            height: 1.4,
          ),
        ),

        const SizedBox(height: 12),
        Divider(
          height: 1,
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFF3F4F6),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 13,
              color: isDark ? Colors.white60 : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 5),
            Text(
              'Created by $creatorName on $formattedDate',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            _buildQuickChip(context, '👋 Hey everyone!'),
            _buildQuickChip(context, '📋 Today\'s agenda?'),
            _buildQuickChip(context, '🚀 Ready to start!'),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickChip(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _onStarterTapped(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E26) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.18)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}
