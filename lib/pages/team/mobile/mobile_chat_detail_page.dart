import 'package:conference/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/conversation.dart';
import '../../../theme/app_theme.dart';
import '../chat_detail_controller.dart';
import 'widgets/sender_bubble.dart';
import 'widgets/receiver_bubble.dart';
import 'widgets/chat_history_header.dart';
import 'widgets/message_input.dart';

/// Mobile-optimised chat detail page.
class MobileChatDetailPage extends GetView<ChatDetailController> {
  const MobileChatDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface(context),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accentPurple,
                  ),
                );
              }

              if (controller.messages.isEmpty && !controller.isLoading.value) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchMessages(),
                color: AppTheme.accentPurple,
                backgroundColor: AppTheme.card(context),
                child: ListView.builder(
                  controller: controller.scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == controller.messages.length) {
                      if (controller.isLoadingMore.value || controller.hasMore) {
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
                      } else {
                        return ChatHistoryHeader(convo: controller.conversation);
                      }
                    }

                    final message = controller.messages[index];
                    final isMe = message.senderId != UserModel.instance.userId;
                    return isMe
                        ? SenderBubble(
                            message: message,
                            conversation: controller.conversation,
                          )
                        : ReceiverBubble(message: message);
                  },
                ),
              );
            }),
          ),
          MessageInput(controller: controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final convo = controller.conversation;
    return AppBar(
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
      titleSpacing: 0,
      title: Row(
        children: [
          _buildAvatar(convo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  convo.title.isNotEmpty ? convo.title : 'Chat',
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
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.videocam_rounded, color: AppTheme.accentPurple),
          onPressed: () => controller.joinMeeting(),
        ),
        IconButton(
          icon: Icon(
            Icons.info_outline_rounded,
            color: AppTheme.textSecondary(context),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          color: AppTheme.divider(context).withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildAvatar(Conversation convo) {
    final gradients = [
      const [Color(0xFF6C5CE7), Color(0xFF8E7CF3)],
      const [Color(0xFF2D7FF9), Color(0xFF18BFFF)],
      const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    ];
    final colorPair = gradients[convo.conversationId.hashCode.abs() % gradients.length];

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colorPair),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          convo.title.isNotEmpty ? convo.title[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final convo = controller.conversation;
    return RefreshIndicator(
      onRefresh: () => controller.fetchMessages(),
      color: AppTheme.accentPurple,
      backgroundColor: AppTheme.card(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Center(
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accentPurple.withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.forum_outlined,
                        size: 38,
                        color: AppTheme.accentPurple,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Messages Yet',
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to start the conversation!',
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ChatHistoryHeader(convo: convo, isEmptyState: true),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Or suggest a conversation starter:',
              style: TextStyle(
                color: AppTheme.textSecondary(context),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickMessageChip(context, "👋 Hey everyone!"),
                _buildQuickMessageChip(context, "📅 Are we meeting today?"),
                _buildQuickMessageChip(context, "🚀 Let's get started!"),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
        ],
      ),
    );
  }

  Widget _buildQuickMessageChip(BuildContext context, String text) {
    return ActionChip(
      label: Text(
        text,
        style: TextStyle(
          color: AppTheme.accentPurple,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: AppTheme.accentPurple.withValues(alpha: 0.08),
      side: BorderSide(color: AppTheme.accentPurple.withValues(alpha: 0.15)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () {
        controller.messageController.text = text;
      },
    );
  }
}
