import 'package:conference/models/conversation.dart';
import 'package:conference_sdk/conference_sdk.dart';
import 'package:flutter/material.dart';

/// Renders a message sent by the current user.
class SenderBubble extends StatefulWidget {
  final Message message;
  final Conversation conversation;

  const SenderBubble({
    super.key,
    required this.message,
    required this.conversation,
  });

  @override
  State<SenderBubble> createState() => _SenderBubbleState();
}

class _SenderBubbleState extends State<SenderBubble> {
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
    final status = widget.message.status;
    final isSeen = status == 3;
    final textStyle = const TextStyle(
      color: Color(0xFF2C2738), // Dark purple for high contrast readability on light bg
      fontSize: 14,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Aligned to the right side of the screen
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isSeen) const SizedBox(width: 24), // Safety margin to prevent left-overlapping avatar from clipping
          Flexible(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.95 - 48, // Max upto 95% of screen width
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFE8F8), // Light lavender background
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
                                const SizedBox(height: 10),
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
                                      style: const TextStyle(
                                        color: Color(0xFF6C5CE7), // Brand purple link
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Color(0xFF6C5CE7),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(widget.message.createdAt),
                            style: const TextStyle(
                              color: Colors.black54, // Readable dark grey on light bg
                              fontSize: 10,
                            ),
                          ),
                          if (!isSeen) ...[
                            const SizedBox(width: 4),
                            _buildInsideStatusIndicator(),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSeen)
                  Positioned(
                    bottom: 0,
                    left: -15, // Aligns to the left side of the bubble (94% outside)
                    child: _buildSeenAvatar(context),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildInsideStatusIndicator() {
    final status = widget.message.status;

    // Status 0: Pending/Local -> Show "sending..." text
    if (status == 0) {
      return const Text(
        'sending...',
        style: TextStyle(
          color: Color(0xFF6B5F88),
          fontSize: 10,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Status 1: Delivered -> Single check icon
    if (status == 1) {
      return const Icon(
        Icons.check,
        size: 13,
        color: Color(0xFF6B5F88),
      );
    }

    // Status 2: Received/Server -> Double check icon
    if (status == 2) {
      return const Icon(
        Icons.done_all,
        size: 13,
        color: Color(0xFF6B5F88),
      );
    }

    // Fallback: single check
    return const Icon(
      Icons.check,
      size: 13,
      color: Color(0xFF6B5F88),
    );
  }

  Widget _buildSeenAvatar(BuildContext context) {
    final otherMembers = widget.conversation.members
        .where((m) => m.userId != widget.message.senderId)
        .toList();

    final avatarUrl = otherMembers.isNotEmpty ? otherMembers.first.avatar : null;
    final initials = otherMembers.isNotEmpty && otherMembers.first.firstName.isNotEmpty
        ? otherMembers.first.firstName[0].toUpperCase()
        : '?';

    final cutoffBorderColor = Theme.of(context).scaffoldBackgroundColor;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: cutoffBorderColor,
            width: 1,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            avatarUrl,
            width: 16,
            height: 16,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(initials, cutoffBorderColor),
          ),
        ),
      );
    } else {
      return _buildInitialsAvatar(initials, cutoffBorderColor);
    }
  }

  Widget _buildInitialsAvatar(String initials, Color cutoffBorderColor) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
        border: Border.all(
          color: cutoffBorderColor,
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 9,
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
