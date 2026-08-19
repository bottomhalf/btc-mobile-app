import 'package:conference/models/conversation.dart';
import 'package:conference_sdk/conference_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/meeting_model.dart';
import '../../../models/chat_message_model.dart';
import '../../../models/user_model.dart';
import '../../../theme/app_theme.dart';
import '../../../services/meeting_service.dart';
import '../team_controller.dart';
import '../chat_detail_controller.dart';
import '../service/chat_service.dart';

/// Desktop-optimised team page.
///
/// Uses a master-detail split layout:
/// - Left panel (~35%): Conversation list
/// - Right panel (~65%): Selected chat detail (inline, no navigation)
///
/// On desktop, clicking a conversation opens it in the right panel
/// instead of navigating to a separate page.
class DesktopTeamPage extends GetView<TeamController> {
  const DesktopTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface(context),
      body: Row(
        children: [
          // ── Left: Conversation list ──
          SizedBox(
            width: 280,
            child: _ConversationListPanel(controller: controller),
          ),

          // ── Divider ──
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: AppTheme.divider(context).withValues(alpha: 0.5),
          ),

          // ── Right: Chat detail ──
          Expanded(
            child: Obx(() {
              if (controller.selectedConversation.value == null) {
                return _buildEmptyState(context);
              }
              return _DesktopChatDetail(
                key: ValueKey(controller.selectedConversation.value!.conversationId),
                conversation: controller.selectedConversation.value!,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: AppTheme.textSecondary(context).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a conversation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary(context).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a conversation from the left panel to start chatting',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary(context).withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Conversation list panel (left side) ──
class _ConversationListPanel extends StatelessWidget {
  const _ConversationListPanel({required this.controller});
  final TeamController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              Text(
                'Team',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list_rounded,
                    color: AppTheme.textSecondary(context),
                    size: 20,
                  ),
                  onPressed: () {},
                  tooltip: 'Filter',
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  icon: Icon(Icons.edit_rounded,
                      color: AppTheme.accentPurple, size: 20),
                  onPressed: () {},
                  tooltip: 'New Team',
                ),
              ),
            ],
          ),
        ),

        // ── Search bar ──
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.cardAlt(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.divider(context).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AppTheme.textSecondary(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search conversations...',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary(context).withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Conversation list ──
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accentPurple,
                  strokeWidth: 2.5,
                ),
              );
            }

            if (controller.errorMessage.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: AppTheme.errorRed,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: controller.initConnection,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (controller.conversations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppTheme.textSecondary(context).withValues(alpha: 0.4),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No conversations yet.',
                      style: TextStyle(
                        color: AppTheme.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            final members = controller.conversations.toList();
            final groups = [];

            return Column(
              children: [
                // Members Section (70%)
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text(
                          'MEMBERS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary(context),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            return _DesktopConvoTile(
                              c: members[index],
                              controller: controller,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    color: AppTheme.divider(context).withValues(alpha: 0.5),
                    height: 1,
                  ),
                ),

                // Groups Section (30%)
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          'GROUPS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary(context),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: groups.length,
                          itemBuilder: (context, index) {
                            return _DesktopConvoTile(
                              c: groups[index],
                              controller: controller,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

/// ── Single conversation tile for desktop ──
class _DesktopConvoTile extends StatelessWidget {
  const _DesktopConvoTile({
    required this.c,
    required this.controller,
  });

  final Conversation c;
  final TeamController controller;

  @override
  Widget build(BuildContext context) {
    final isGroup = c.type == 'group';

    String title = c.type;
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
    final colorPair = gradients[c.conversationId.hashCode.abs() % gradients.length];

    return Obx(() {
      final isSelected = controller.selectedConversation.value?.conversationId == c.conversationId;

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.selectConversation(c),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentPurple.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? Border.all(
                        color: AppTheme.accentPurple.withValues(alpha: 0.2),
                        width: 1,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colorPair),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      final unreadCount = ChatService.instance.unreadCounts[c.conversationId] ?? 0;
                      final hasUnread = unreadCount > 0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: hasUnread
                                        ? FontWeight.w800
                                        : (isSelected ? FontWeight.w700 : FontWeight.w600),
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    c.timeAgo,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                                      color: hasUnread
                                          ? AppTheme.accentPurple
                                          : AppTheme.textSecondary(context),
                                    ),
                                  ),
                                  if (hasUnread) ...[
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentPurple,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
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
                          ),
                          const SizedBox(height: 2),
                          Text(
                            c.lastMessage ??
                                (isGroup
                                    ? 'You were added to the group'
                                    : 'Start of conversation'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                              color: hasUnread
                                  ? AppTheme.textPrimary(context)
                                  : AppTheme.textSecondary(context),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// ── Inline chat detail for desktop (right panel) ──
///
/// This is a self-contained chat view that loads messages for the
/// given conversation. It does NOT use GetView/ChatDetailController
/// binding to avoid route-dependent state issues.
class _DesktopChatDetail extends StatefulWidget {
  const _DesktopChatDetail({
    super.key,
    required this.conversation,
  });

  final Conversation conversation;

  @override
  State<_DesktopChatDetail> createState() => _DesktopChatDetailState();
}

class _DesktopChatDetailState extends State<_DesktopChatDetail> {
  late ChatDetailController _chatController;

  @override
  void initState() {
    super.initState();
    // Register a controller for this specific conversation
    _chatController = Get.put(
      ChatDetailController(conversation: widget.conversation),
      tag: widget.conversation.conversationId,
    );
  }

  @override
  void dispose() {
    Get.delete<ChatDetailController>(tag: widget.conversation.conversationId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final convo = widget.conversation;

    return Column(
      children: [
        // ── Chat header ──
        _buildChatHeader(context, convo),

        // ── Messages ──
        Expanded(
          child: Obx(() {
            if (_chatController.isLoading.value &&
                _chatController.messages.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accentPurple,
                  strokeWidth: 2.5,
                ),
              );
            }

            if (_chatController.messages.isEmpty &&
                !_chatController.isLoading.value) {
              return Center(
                child: Text(
                  'No messages yet',
                  style: TextStyle(color: AppTheme.textSecondary(context)),
                ),
              );
            }

            return ListView.builder(
              controller: _chatController.scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: _chatController.messages.length +
                  (_chatController.isLoadingMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _chatController.messages.length) {
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

                final message = _chatController.messages[index];
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
    );
  }

  Widget _buildChatHeader(BuildContext context, Conversation c) {
    final gradients = [
      const [Color(0xFF6C5CE7), Color(0xFF8E7CF3)],
      const [Color(0xFF2D7FF9), Color(0xFF18BFFF)],
      const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    ];
    final colorPair = gradients[c.conversationId.hashCode.abs() % gradients.length];

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
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colorPair),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                c.title.isNotEmpty
                    ? c.title[0].toUpperCase()
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
                  c.title.isNotEmpty
                      ? c.title
                      : 'Chat',
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${c.memberCount} participants',
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
              icon: Icon(Icons.videocam_rounded, color: AppTheme.accentPurple),
              onPressed: () {
                MeetingService.instance.joinMeeting(
                  roomId: c.conversationId,
                  participantName: UserModel.instance.fullName,
                  meetingTitle: c.title,
                );
              },
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
              tooltip: 'Conversation info',
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
    final conversation = _chatController.conversation;

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
                controller: _chatController.messageController,
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
                onSubmitted: (_) async => await _chatController.sendMessage(),
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
                  onPressed: _chatController.sendMessage,
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
