import 'package:conference/models/conversation.dart';
import 'package:conference/theme/app_theme.dart';
import 'package:conference_sdk/conference_sdk.dart';
import 'package:flutter/material.dart';

/// Renders a message sent by the current user.
class SenderBubble extends StatelessWidget {
  final Message message;
  final Conversation conversation;

  const SenderBubble({
    super.key,
    required this.message,
    required this.conversation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
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
                  Text(
                    message.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusIndicator(context),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final status = message.status;

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

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
