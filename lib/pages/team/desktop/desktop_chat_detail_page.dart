import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/conversation.dart';
import '../../../models/user_model.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/desktop_shell.dart';
import '../../../theme/app_theme.dart';
import '../chat_detail_controller.dart';
import 'widgets/chat_history_header.dart';
import 'widgets/desktop_right_side_panel.dart';
import 'widgets/message_input.dart';
import 'widgets/receiver_bubble.dart';
import 'widgets/sender_bubble.dart';

/// Desktop-optimised chat detail page matching the team.png reference design.
///
/// Features:
/// - Exact header from team.png with "[ 📹 Join ]" button, phone, sparkles, add person & menu
/// - Date separator pill ("8/20/2026")
/// - Centered Google Chat messages with pastel avatars, @mentions, and soft lavender sender bubbles
/// - Centered bottom input bar with format, attach, emoji, GIF, and send actions
/// - Right companion panel with Calendar, Keep, Voice, Tasks, Add-ons
class DesktopChatDetailPage extends GetView<ChatDetailController> {
  const DesktopChatDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopShell(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                // ── Chat header matching team.png ──
                _buildChatHeader(context),

                const Divider(height: 1, color: Color(0xFFE5E7EB)),

                // ── Messages Stream ──
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

                    return Scrollbar(
                      controller: controller.scrollController,
                      thumbVisibility: true,
                      interactive: true,
                      thickness: 6.0,
                      radius: const Radius.circular(3),
                      child: ListView.builder(
                        controller: controller.scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: controller.messages.length + 2,
                        itemBuilder: (context, index) {
                          Widget content;
                          // Top of chat history: User / Space Info Card
                          if (index == controller.messages.length + 1) {
                            if (controller.isLoadingMore.value) {
                              content = const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              );
                            } else {
                              content = ChatHistoryHeader(
                                convo: controller.conversation,
                                controller: controller,
                              );
                            }
                          }
                          // Below info card: Date separator
                          else if (index == controller.messages.length) {
                            content = _buildDateSeparator(controller.conversation);
                          } else {
                            final message = controller.messages[index];
                            final isMe =
                                message.senderId == UserModel.instance.userId;
                            content = isMe
                                ? SenderBubble(
                                    message: message,
                                    conversation: controller.conversation,
                                  )
                                : ReceiverBubble(message: message);
                          }

                          return Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 860),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: content,
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),

                // ── Message input matching team.png ──
                MessageInput(controller: controller),
              ],
            ),
          ),

          // ── Right Companion Panel matching team.png ──
          const DesktopRightSidePanel(),
        ],
      ),
    );
  }

  Widget _buildChatHeader(BuildContext context) {
    final convo = controller.conversation;
    final currentUserId = UserModel.instance.userId;
    final otherMembers =
        convo.members.where((m) => m.userId != currentUserId).toList();
    final otherMember =
        otherMembers.isNotEmpty ? otherMembers.first : null;
    final avatarUrl = otherMember?.avatar ?? convo.avatar;

    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF4B5563),
                size: 20,
              ),
              onPressed: () => Get.back(),
              tooltip: 'Back',
            ),
          ),
          const SizedBox(width: 4),

          // Header Avatar (Coral / Peach from team.png with image fallback to letter)
          AppAvatar(
            imageUrl: avatarUrl,
            name: convo.title.isNotEmpty ? convo.title : 'Daily Stand-Up Meeting',
            size: 38,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: const Color(0xFFFB7185), // Coral from team.png
            fontSize: 14,
          ),
          const SizedBox(width: 12),

          // Title & member count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  convo.title.isNotEmpty ? convo.title : 'Daily Stand-Up Meeting',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '${convo.memberCount} members',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // "[ 📹 Join ]" Button matching team.png
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ElevatedButton.icon(
              onPressed: () => controller.joinMeeting(),
              icon: const Icon(Icons.videocam_rounded, size: 18, color: Colors.white),
              label: const Text(
                'Join',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4338CA), // Indigo/Blue from team.png
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Action Icons
          _buildHeaderIcon(Icons.phone_outlined, 'Voice call', () {}),
          _buildHeaderIcon(Icons.auto_awesome_outlined, 'AI Assistant', () {}),
          _buildHeaderIcon(Icons.person_add_outlined, 'Add members', () {}),
          _buildHeaderIcon(Icons.more_vert_rounded, 'More options', () {}),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, String tooltip, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          icon: Icon(icon, size: 19, color: const Color(0xFF4B5563)),
          onPressed: onTap,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
        ),
      ),
    );
  }

  Widget _buildDateSeparator(Conversation convo) {
    final date = convo.createdAt ?? convo.lastMessageAt ?? DateTime.now();
    final dateStr = '${date.month}/${date.day}/${date.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              dateStr,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
        ],
      ),
    );
  }
}
