import 'package:conference/models/conversation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user_model.dart';
import '../../../models/participant.dart';
import '../../../theme/app_theme.dart';
import '../team_controller.dart';

/// Mobile-optimised team page.
///
/// Features a clean list layout with search filtering, group member avatar stacks,
/// and live online indicators. Avatar background colors are derived from the first two
/// letters of the conversation/participant name.
class MobileTeamPage extends GetView<TeamController> {
  const MobileTeamPage({super.key});

  static final RxString searchQuery = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFF5F6FA)
          : AppTheme.surface(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildTeamHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  controller.initConnection();
                },
                color: AppTheme.accentPurple,
                backgroundColor: AppTheme.card(context),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accentPurple,
                        strokeWidth: 3,
                      ),
                    );
                  }

                  if (controller.errorMessage.isNotEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        alignment: Alignment.center,
                        child: _buildErrorState(context),
                      ),
                    );
                  }

                  final conversations = controller.conversations;

                  if (conversations.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        alignment: Alignment.center,
                        child: _buildEmptyState(context),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: conversations.length,
                    separatorBuilder: (context, index) => Divider(
                      color: AppTheme.divider(context).withValues(alpha: 0.3),
                      height: 1,
                      indent: 66,
                    ),
                    itemBuilder: (context, index) {
                      return _buildTeamTile(context, conversations[index]);
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamHeader(BuildContext context) {
    final user = UserModel.instance;
    final userInitials = user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?';
    final userGradients = [
      const [Color(0xFF6C5CE7), Color(0xFF8E7CF3)],
      const [Color(0xFF2D7FF9), Color(0xFF18BFFF)],
    ];
    final userColor = userGradients[user.userId.hashCode.abs() % userGradients.length];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.divider(context).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: userColor),
              boxShadow: [
                BoxShadow(
                  color: userColor[0].withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: user.imageUrl.isNotEmpty
                  ? Image.network(
                      user.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          userInitials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        userInitials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${user.firstName}!',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary(context).withValues(alpha: 0.8),
                ),
              ),
              Text(
                'Team Chats',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary(context),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.edit_note_rounded,
                color: AppTheme.accentPurple,
                size: 22,
              ),
              onPressed: () {},
              tooltip: 'New Chat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamTile(BuildContext context, Conversation c) {
    final isGroup = c.type == 'group';

    String title = c.title;
    if (title.isEmpty) {
      title = isGroup ? 'Group Chat' : 'Direct Message';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.openTeam(c),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            children: [
              _buildAvatar(context, c),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          c.timeAgo,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary(context).withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.lastMessage ??
                                (isGroup
                                    ? 'You were added to the group'
                                    : 'Start of conversation'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.textSecondary(context),
                            ),
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
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, Conversation c) {
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

    // Compute avatar color hash based on the first two letters of conversation name
    final nameKey = title.length >= 2 ? title.substring(0, 2).toLowerCase() : title.toLowerCase();
    final colorPair = gradients[nameKey.hashCode.abs() % gradients.length];

    if (isGroup) {
      final otherMembers = c.members.where((m) => m.userId != currentUserId).toList();
      if (otherMembers.isNotEmpty) {
        return SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            children: [
              for (int i = 0; i < otherMembers.take(2).length; i++)
                Positioned(
                  left: i * 16.0,
                  top: i * 8.0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.card(context),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: otherMembers[i].avatar != null && otherMembers[i].avatar!.isNotEmpty
                          ? Image.network(
                              otherMembers[i].avatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(otherMembers[i]),
                            )
                          : _buildInitialsAvatar(otherMembers[i]),
                    ),
                  ),
                ),
              if (otherMembers.length > 2)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.card(context),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '+${otherMembers.length - 2}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }

      // Group fallback
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colorPair),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.card(context),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.groups_rounded,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else {
      // Direct message
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
      final isOnline = otherMember.status == 1;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: hasImage
                  ? Image.network(
                      otherMember.avatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildInitialsWithGradient(colorPair, initials),
                    )
                  : _buildInitialsWithGradient(colorPair, initials),
            ),
          ),
          // Active/Online indicator dot
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isOnline ? const Color(0xFF2ECC71) : const Color(0xFF95A5A6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.card(context),
                  width: 2.5,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildInitialsAvatar(Participant p) {
    final name = p.firstName;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final gradients = [
      const [Color(0xFF6C5CE7), Color(0xFF8E7CF3)],
      const [Color(0xFF2D7FF9), Color(0xFF18BFFF)],
      const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      const [Color(0xFF00B894), Color(0xFF55EFC4)],
      const [Color(0xFFE17055), Color(0xFFF8A5C2)],
    ];
    
    // Compute avatar color hash based on the first two letters of user's first name
    final nameKey = name.length >= 2 ? name.substring(0, 2).toLowerCase() : name.toLowerCase();
    final colors = gradients[nameKey.hashCode.abs() % gradients.length];
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsWithGradient(List<Color> colorPair, String initials) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colorPair),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppTheme.accentPurple.withValues(alpha: 0.8),
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              searchQuery.value.isNotEmpty ? 'No matches found' : 'Start chatting',
              style: TextStyle(
                color: AppTheme.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.value.isNotEmpty
                  ? 'Try searching for something else.'
                  : 'Start a conversation with someone in your team.',
              textAlign: CenterText.center,
              style: TextStyle(
                color: AppTheme.textSecondary(context),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                color: AppTheme.errorRed,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Connection Error',
              style: TextStyle(
                color: AppTheme.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: CenterText.center,
              style: TextStyle(
                color: AppTheme.textSecondary(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.initConnection,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper to handle text alignment safely
class CenterText {
  static const TextAlign center = TextAlign.center;
}
