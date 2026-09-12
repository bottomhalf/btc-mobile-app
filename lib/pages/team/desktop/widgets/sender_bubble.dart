import 'dart:math' as math;
import 'package:conference/models/conversation.dart';
import 'package:conference_sdk/conference_sdk.dart';
import 'package:flutter/material.dart';

/// Sender bubble matching the reference design in team.png.
///
/// Features:
/// - Right-aligned with timestamp above the bubble
/// - Soft lavender/purple card background (Color(0xFFF3E8FF)) with borderRadius 10
/// - Automatic @mention highlighting in bold maroon (Color(0xFF991B1B))
/// - Status indicator (sending, delivered, seen)
/// - Desktop middle-centered layout
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
    final screenWidth = MediaQuery.of(context).size.width;
    final bubbleMaxWidth = math.min(screenWidth * 0.65, 520.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 48),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Timestamp above the bubble as shown in team.png
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        if (message.status == 0) ...[
                          const SizedBox(width: 4),
                          const Text(
                            'sending...',
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Lavender / Purple bubble
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF), // Light lavender from team.png
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE9D5FF),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: _parseFormattedText(message.content),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _parseFormattedText(String text) {
    final mentionRegex = RegExp(
        r'(@[a-zA-Z0-9_\-]+)|([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})|(https?://[^\s]+)');
    final spans = <TextSpan>[];

    int lastMatchEnd = 0;
    for (final match in mentionRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
        );
      }

      final matchText = match.group(0)!;
      if (matchText.startsWith('@')) {
        // Maroon/red bold mention as seen in team.png
        spans.add(
          TextSpan(
            text: matchText,
            style: const TextStyle(
              color: Color(0xFF991B1B), // Dark red/maroon
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
        );
      } else {
        // Link or email
        spans.add(
          TextSpan(
            text: matchText,
            style: const TextStyle(
              color: Color(0xFF2563EB),
              decoration: TextDecoration.underline,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
        );
      }
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastMatchEnd),
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
      );
    }

    return SelectableText.rich(
      TextSpan(children: spans),
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }
}
