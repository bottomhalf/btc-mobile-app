import 'package:conference/models/conversation.dart';
import 'package:conference/models/user_model.dart';
import 'package:conference/shared/widgets/app_avatar.dart';
import 'package:conference/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../chat_detail_controller.dart';
import '../team_controller.dart';
import 'widgets/chat_history_header.dart';
import 'widgets/desktop_convo_tile.dart';
import 'widgets/desktop_right_side_panel.dart';
import 'widgets/message_input.dart';
import 'widgets/receiver_bubble.dart';
import 'widgets/sender_bubble.dart';

/// Desktop-optimised team page matching the team.png reference design.
///
/// Features:
/// - Top Global Bar: Search input with Ctrl+K badge, "+ Create Group" button, user profile
/// - Left Sidebar (~280px): Profile card (Available status), search box, collapsible Chat and Group [3] sections
/// - Middle Chat Panel: Header with "[ 📹 Join ]" button, phone, sparkles, add person & menu icons
/// - Date separator ("8/20/2026")
/// - Messages: Google Chat style cards with pastel avatars, @mentions, and soft lavender sender bubbles
/// - Bottom Input Bar: Formatted tools (T, paperclip, emoji, GIF) and "Type a new message or @mention"
/// - Right Panel: Companion vertical rail matching team.png (Calendar, Keep, Voice, Tasks, Add-ons)
class DesktopTeamPage extends GetView<TeamController> {
  const DesktopTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Top Global Bar (Search people, chats, messages... + Create Group) ──
          _buildGlobalTopBar(context),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // ── Main Content Area (Sidebar + Chat Detail + Right Companion Panel) ──
          Expanded(
            child: Row(
              children: [
                // ── Left: Conversation list sidebar ──
                SizedBox(
                  width: 290,
                  child: _ConversationListPanel(controller: controller),
                ),

                // ── Divider ──
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xFFE5E7EB),
                ),

                // ── Middle: Selected Chat detail ──
                Expanded(
                  child: Obx(() {
                    if (controller.selectedConversation.value == null) {
                      return _buildEmptySelectionState(context);
                    }
                    return _DesktopChatDetail(
                      key: ValueKey(
                        controller.selectedConversation.value!.conversationId,
                      ),
                      conversation: controller.selectedConversation.value!,
                    );
                  }),
                ),

                // ── Far Right: Companion Bar matching team.png ──
                const DesktopRightSidePanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalTopBar(BuildContext context) {
    final user = UserModel.instance;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Spacer(),

          // Centered global search bar with Ctrl+K shortcut
          Container(
            width: 440,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Search people, chats, messages...',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Text(
                    'Ctrl+K',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // "+ Create Group" button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.group_add_outlined, size: 16),
              label: const Text(
                'Create Group',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF374151),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // User avatar
          AppAvatar(
            imageUrl: user.imageUrl,
            name: user.fullName.isNotEmpty ? user.fullName : 'MI',
            size: 32,
            backgroundColor: const Color(0xFFFFB4A2), // Peach from team.png
            fontSize: 12,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildEmptySelectionState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select a conversation',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose a conversation from the left panel to start chatting',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Conversation list sidebar matching team.png ──
class _ConversationListPanel extends StatefulWidget {
  const _ConversationListPanel({required this.controller});
  final TeamController controller;

  @override
  State<_ConversationListPanel> createState() => _ConversationListPanelState();
}

class _ConversationListPanelState extends State<_ConversationListPanel> {
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  bool _isChatExpanded = true;
  bool _isGroupExpanded = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = UserModel.instance;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // ── User Profile Card (Available status) ──
          Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                AppAvatar(
                  imageUrl: user.imageUrl,
                  name: user.fullName.isNotEmpty ? user.fullName : 'MI',
                  size: 36,
                  backgroundColor: const Color(0xFFFFB4A2), // Peach color from team.png
                  fontSize: 13,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName.isNotEmpty ? user.fullName : 'Md IstiyaQ',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E), // Green dot
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Available',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Search conversations bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.search_rounded,
                    size: 17,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => _searchQuery.value = val,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF1F2937),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search conversations...',
                        hintStyle: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF9CA3AF),
                        ),
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ── Chat & Group list ──
          Expanded(
            child: Obx(() {
              if (widget.controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accentPurple,
                    strokeWidth: 2.5,
                  ),
                );
              }

              final allConvos = widget.controller.conversations;
              final query = _searchQuery.value.trim().toLowerCase();

              final filtered = query.isEmpty
                  ? allConvos
                  : allConvos.where((c) {
                      final titleMatches =
                          c.title.toLowerCase().contains(query);
                      final memberMatches = c.members.any((m) =>
                          m.firstName.toLowerCase().contains(query) ||
                          m.email.toLowerCase().contains(query));
                      return titleMatches || memberMatches;
                    }).toList();

              final members =
                  filtered.where((c) => c.type != 'group').toList();
              final groups =
                  filtered.where((c) => c.type == 'group').toList();

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                children: [
                  // ── Section 1: Chat ──
                  _buildSectionHeader(
                    title: 'Chat',
                    badge: null,
                    isExpanded: _isChatExpanded,
                    onToggle: () {
                      setState(() {
                        _isChatExpanded = !_isChatExpanded;
                      });
                    },
                    onAdd: () {},
                  ),
                  if (_isChatExpanded) ...[
                    for (final item in members)
                      DesktopConvoTile(
                        key: ValueKey(item.conversationId),
                        c: item,
                        controller: widget.controller,
                      ),
                  ],

                  const SizedBox(height: 8),

                  // ── Section 2: Group [3] ──
                  _buildSectionHeader(
                    title: 'Group',
                    badge: groups.isNotEmpty ? '${groups.length}' : '3',
                    isExpanded: _isGroupExpanded,
                    onToggle: () {
                      setState(() {
                        _isGroupExpanded = !_isGroupExpanded;
                      });
                    },
                    onAdd: () {},
                  ),
                  if (_isGroupExpanded) ...[
                    for (final item in groups)
                      DesktopConvoTile(
                        key: ValueKey(item.conversationId),
                        c: item,
                        controller: widget.controller,
                      ),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String? badge,
    required bool isExpanded,
    required VoidCallback onToggle,
    required VoidCallback onAdd,
  }) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(
              isExpanded
                  ? Icons.arrow_drop_down_rounded
                  : Icons.arrow_right_rounded,
              size: 20,
              color: const Color(0xFF4B5563),
            ),
            const SizedBox(width: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
            const Spacer(),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onAdd,
                child: const Icon(
                  Icons.add,
                  size: 17,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

/// ── Inline chat detail matching team.png ──
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
    _chatController = Get.put(
      ChatDetailController(conversation: widget.conversation),
      tag: widget.conversation.conversationId,
    );
  }

  @override
  void dispose() {
    final tag = widget.conversation.conversationId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<ChatDetailController>(tag: tag)) {
        Get.delete<ChatDetailController>(tag: tag);
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final convo = widget.conversation;

    return Column(
      children: [
        // ── Chat Header Bar matching team.png ──
        _buildChatHeader(context, convo),

        const Divider(height: 1, color: Color(0xFFE5E7EB)),

        // ── Messages Stream ──
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

            final messages = _chatController.messages;

            return Scrollbar(
              controller: _chatController.scrollController,
              thumbVisibility: true,
              interactive: true,
              thickness: 6.0,
              radius: const Radius.circular(3),
              child: ListView.builder(
                controller: _chatController.scrollController,
                reverse: true,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: messages.length + 2,
                itemBuilder: (context, index) {
                  Widget content;
                  // Top of chat history: User / Space Info Card
                  if (index == messages.length + 1) {
                    if (_chatController.isLoadingMore.value) {
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
                        convo: convo,
                        controller: _chatController,
                      );
                    }
                  }
                  // Below info card: Date separator
                  else if (index == messages.length) {
                    content = _buildDateSeparator(convo);
                  } else {
                    final message = messages[index];
                    final isMe =
                        message.senderId == UserModel.instance.userId;

                    content = isMe
                        ? SenderBubble(
                            message: message,
                            conversation: convo,
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

        // ── Bottom Input Bar matching team.png ──
        MessageInput(controller: _chatController),
      ],
    );
  }

  Widget _buildChatHeader(BuildContext context, Conversation c) {
    final currentUserId = UserModel.instance.userId;
    final otherMembers =
        c.members.where((m) => m.userId != currentUserId).toList();
    final otherMember =
        otherMembers.isNotEmpty ? otherMembers.first : null;
    final avatarUrl = otherMember?.avatar ?? c.avatar;

    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: Row(
        children: [
          // Header Avatar (Coral / Peach from team.png with image fallback to letter)
          AppAvatar(
            imageUrl: avatarUrl,
            name: c.title.isNotEmpty ? c.title : 'Daily Stand-Up Meeting',
            size: 38,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: const Color(0xFFFB7185), // Coral from team.png
            fontSize: 14,
          ),
          const SizedBox(width: 12),

          // Title and member count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  c.title.isNotEmpty ? c.title : 'Daily Stand-Up Meeting',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '${c.memberCount} members',
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
              onPressed: () => _chatController.joinMeeting(),
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

          // Action Icons: Phone, AI sparkles, Add person, More vert
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
