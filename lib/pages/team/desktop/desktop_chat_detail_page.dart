import 'package:conference_sdk/conference_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/desktop_shell.dart';

import '../../../models/chat_message_model.dart';
import '../../../models/user_model.dart';
import '../../../theme/app_theme.dart';
import '../chat_detail_controller.dart';

/// Desktop-optimised chat detail page (standalone route variant).
///
/// When navigated to via `/chat-detail` route on desktop, this wraps
/// the chat view inside the [DesktopShell] to maintain the side menu.
///
/// Note: On desktop, the preferred UX is the inline master-detail
/// in DesktopTeamPage. This route is a fallback for direct navigation.
class DesktopChatDetailPage extends GetView<ChatDetailController> {
  const DesktopChatDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopShell(
      child: Column(
        children: [
          // ── Chat header ──
          _buildChatHeader(context),

          // ── Messages ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accentPurple,
                    strokeWidth: 2.5,
                  ),
                );
              }

              if (controller.messages.isEmpty && !controller.isLoading.value) {
                return Center(
                  child: Text(
                    'No messages yet',
                    style: TextStyle(color: AppTheme.textSecondary(context)),
                  ),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                reverse: true,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
                itemCount: controller.messages.length +
                    (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.messages.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.accentPurple,
                          ),
                        ),
                      ),
                    );
                  }

                  final message = controller.messages[index];
                  final isMe =
                      message.senderId != UserModel.instance.userId;
                  return _buildMessageBubble(context, message, isMe);
                },
              );
            }),
          ),

          // ── Message input ──
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildChatHeader(BuildContext context) {
    final convo = controller.conversation;
    final gradients = [
      const [Color(0xFF6C5CE7), Color(0xFF8E7CF3)],
      const [Color(0xFF2D7FF9), Color(0xFF18BFFF)],
      const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    ];
    final colorPair = gradients[convo.conversationId.hashCode.abs() % gradients.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.divider(context).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.textPrimary(context),
                size: 22,
              ),
              onPressed: () => Get.back(),
              tooltip: 'Back',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colorPair),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                convo.title.isNotEmpty
                    ? convo.title[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  convo.title.isNotEmpty
                      ? convo.title
                      : 'Chat',
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${convo.memberCount} participants',
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              icon: Icon(Icons.videocam_rounded,
                  color: AppTheme.accentPurple),
              onPressed: () => controller.joinMeeting(),
              tooltip: 'Start video call',
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              icon: Icon(
                Icons.info_outline_rounded,
                color: AppTheme.textSecondary(context),
              ),
              onPressed: () {},
              tooltip: 'Info',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    Message message,
    bool isMe,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.accentPurple.withValues(alpha: 0.2),
              child: Text(
                message.senderId.isNotEmpty
                    ? message.senderId[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.accentPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isMe ? AppTheme.accentPurple : AppTheme.card(context),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentPurple,
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe
                          ? Colors.white
                          : AppTheme.textPrimary(context),
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          color: isMe
                              ? Colors.white70
                              : AppTheme.textSecondary(context),
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 8),
                        _buildStatusIndicator(context, message),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 32),
          if (!isMe) const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, Message message) {
    final status = message.status;
    final conversation = controller.conversation;

    // Status 0: Pending/Local -> Single check
    if (status == 0) {
      return const Icon(
        Icons.check,
        size: 14,
        color: Colors.white70,
      );
    }

    // Status 2: Pushed to Server -> Double check
    if (status == 2) {
      return const Icon(
        Icons.done_all,
        size: 14,
        color: Colors.white70,
      );
    }

    // Status 3: Seen -> Small avatar
    if (status == 3) {
      final otherMembers = conversation.members
          .where((m) => m.userId != message.senderId)
          .toList();

      final avatarUrl = otherMembers.isNotEmpty ? otherMembers.first.avatar : null;
      final initials = otherMembers.isNotEmpty && otherMembers.first.firstName.isNotEmpty
          ? otherMembers.first.firstName[0].toUpperCase()
          : '?';

      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        return Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white24,
          ),
          child: ClipOval(
            child: Image.network(
              avatarUrl,
              width: 14,
              height: 14,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(initials),
            ),
          ),
        );
      } else {
        return _buildInitialsAvatar(initials);
      }
    }

    // Fallback default: single check
    return const Icon(
      Icons.check,
      size: 14,
      color: Colors.white70,
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      width: 14,
      height: 14,
      decoration: const BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 8,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppTheme.textSecondary(context),
                  size: 28,
                ),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.divider(context).withValues(alpha: 0.5),
                ),
              ),
              child: TextField(
                controller: controller.messageController,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 14,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
                style: TextStyle(
                  color: AppTheme.textPrimary(context),
                  fontSize: 14,
                ),
                onSubmitted: (_) async => await controller.sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentPurple.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: controller.sendMessage,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
