import 'package:conference/models/chat_message_model.dart';
import 'package:conference/pages/team/service/chat_service.dart';
import 'package:conference/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Renders a message received from another participant.
class ReceiverBubble extends StatelessWidget {
  final ChatMessage message;
  final ChatService chatService = ChatService.instance;

  ReceiverBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final initials = message.senderId.isNotEmpty ? message.senderId[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.accentPurple.withValues(alpha: 0.2),
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.accentPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      chatService.getParticipantName(message.conversationId, message.senderId),
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
                      color: AppTheme.textPrimary(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      color: AppTheme.textSecondary(context),
                      fontSize: 10,
                    ),
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

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
