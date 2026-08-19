import 'package:conference/models/chat_message_model.dart';
import 'package:conference/pages/team/service/chat_service.dart';
import 'package:conference/theme/app_theme.dart';
import 'package:conference_sdk/conference_sdk.dart';
import 'package:flutter/material.dart';

/// Renders a message received from another participant.
class ReceiverBubble extends StatefulWidget {
  final Message message;

  const ReceiverBubble({
    super.key,
    required this.message,
  });

  @override
  State<ReceiverBubble> createState() => _ReceiverBubbleState();
}

class _ReceiverBubbleState extends State<ReceiverBubble> {
  final ChatService chatService = ChatService.instance;
  bool _isExpanded = false;

  bool _hasTextOverflow(String text, TextStyle style, double maxWidth) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 10,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.message.senderId.isNotEmpty ? widget.message.senderId[0].toUpperCase() : '?';
    final textStyle = TextStyle(
      color: AppTheme.textPrimary(context),
      fontSize: 14,
    );

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
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9 - 48, // Max upto 90% of screen width
              ),
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
                      chatService.getParticipantName(widget.message.conversationId, widget.message.senderId),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentPurple,
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final textMaxWidth = constraints.maxWidth;
                      final hasOverflow = _hasTextOverflow(widget.message.content, textStyle, textMaxWidth);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.message.content,
                            style: textStyle,
                            maxLines: _isExpanded ? null : 10,
                            overflow: _isExpanded ? TextOverflow.clip : TextOverflow.ellipsis,
                          ),
                          if (hasOverflow) ...[
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isExpanded = !_isExpanded;
                                  });
                                },
                                child: Text(
                                  _isExpanded ? 'Read less' : 'Read more',
                                  style: TextStyle(
                                    color: AppTheme.accentPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppTheme.accentPurple,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(widget.message.createdAt),
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
