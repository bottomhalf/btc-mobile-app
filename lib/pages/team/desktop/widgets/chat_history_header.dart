import 'package:conference/models/conversation.dart';
import 'package:conference/models/participant.dart';
import 'package:conference/models/presence_status.dart';
import 'package:conference/models/user_model.dart';
import 'package:conference/pages/team/chat_detail_controller.dart';
import 'package:conference/shared/widgets/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Card showing rich user / space metadata at the very top of the chat history
/// or when there are no messages, preventing the page from looking blank.
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
    final isGroup = convo.type.toLowerCase() == 'group';
    final currentUserId = UserModel.instance.userId;

    final otherMembers =
        convo.members.where((m) => m.userId != currentUserId).toList();
    final otherMember =
        otherMembers.isNotEmpty ? otherMembers.first : null;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
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
        // ── Large Avatar with Status Ring ──
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            AppAvatar(
              imageUrl: avatarUrl,
              name: name,
              size: 68,
              fontSize: 24,
              border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isOnline
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF9CA3AF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Full Name ──
        Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // ── Email & Status Badge ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (email.isNotEmpty) ...[
              Text(
                email,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '•',
                style: TextStyle(color: Color(0xFFD1D5DB)),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isOnline
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
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
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isOnline
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
        const SizedBox(height: 14),

        // ── Description / Context ──
        Text(
          'This is the very beginning of your direct chat history with $name. Send a message or schedule a call to connect.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF4B5563),
            height: 1.45,
          ),
        ),

        const SizedBox(height: 16),

        // ── Quick Conversation Starters ──
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildQuickChip('👋 Say Hello!'),
            _buildQuickChip('📅 Free for a quick sync?'),
            _buildQuickChip('🚀 Let\'s collaborate!'),
          ],
        ),
      ],
    );
  }

  Widget _buildGroupCard(BuildContext context) {
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
        // ── Space Avatar (Rounded Square matching team.png) ──
        AppAvatar(
          imageUrl: convo.avatar,
          name: title,
          size: 68,
          borderRadius: BorderRadius.circular(16),
          backgroundColor: const Color(0xFFFB7185), // Coral from team.png
          fontSize: 24,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
        ),
        const SizedBox(height: 14),

        // ── Space Title ──
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // ── Member Count & Tag Badge ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Text(
                'GROUP SPACE',
                style: TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$memberCount members',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Description ──
        Text(
          convo.description != null && convo.description!.isNotEmpty
              ? convo.description!
              : 'Welcome to $title! Everyone in this space can collaborate, share updates, and join group meetings.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF4B5563),
            height: 1.45,
          ),
        ),

        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
        const SizedBox(height: 14),

        // ── Creation Details ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline_rounded,
                size: 14, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 6),
            Text(
              'Created by $creatorName on $formattedDate',
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),

        // ── Overlapping Member Avatars ──
        if (convo.members.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildMemberAvatarsRow(context),
        ],

        const SizedBox(height: 16),

        // ── Quick Conversation Starters ──
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildQuickChip('👋 Hey everyone!'),
            _buildQuickChip('📋 What\'s today\'s agenda?'),
            _buildQuickChip('🚀 Ready to sync!'),
          ],
        ),
      ],
    );
  }

  Widget _buildMemberAvatarsRow(BuildContext context) {
    final previewCount = convo.members.length > 6 ? 6 : convo.members.length;
    final displayMembers = convo.members.take(previewCount).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 30,
          child: Stack(
            children: [
              for (int i = 0; i < displayMembers.length; i++)
                Positioned(
                  left: i * 20.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: AppAvatar(
                      imageUrl: displayMembers[i].avatar,
                      name: displayMembers[i].firstName,
                      size: 26,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (convo.members.length > 6) ...[
          const SizedBox(width: 6),
          Text(
            '+${convo.members.length - 6} more',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickChip(String text) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _onStarterTapped(text),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }
}
