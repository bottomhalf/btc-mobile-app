import 'dart:math' as math;
import 'package:conference/pages/team/service/chat_service.dart';
import 'package:conference/shared/widgets/app_avatar.dart';
import 'package:conference_sdk/conference_sdk.dart';
import 'package:flutter/material.dart';

/// Receiver bubble matching the reference design in team.png.
///
/// Features:
/// - Left avatar circle with initial (matching pastel colors from team.png)
/// - Sender name (bold) followed by timestamp in a header line above the card
/// - Clean white message card with thin border (Color(0xFFE5E7EB)) and borderRadius 10
/// - Automatic @mention highlighting in maroon (Color(0xFF991B1B))
/// - Quoted reply preview card support
/// - Desktop middle-centered layout
class ReceiverBubble extends StatelessWidget {
  final Message message;

  const ReceiverBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService.instance;
    final senderName = chatService.getParticipantName(
      message.conversationId,
      message.senderId,
    );

    final senderAvatar = chatService.getParticipantAvatar(
      message.conversationId,
      message.senderId,
    );

    final pastelColors = [
      const Color(0xFF4ADE80), // Green (M)
      const Color(0xFFF59E0B), // Amber (V)
      const Color(0xFF38BDF8), // Sky Blue
      const Color(0xFFF87171), // Salmon
      const Color(0xFFA78BFA), // Purple
    ];
    final avatarBg =
        pastelColors[message.senderId.hashCode.abs() % pastelColors.length];

    final screenWidth = MediaQuery.of(context).size.width;
    final bubbleMaxWidth = math.min(screenWidth * 0.65, 520.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 16),
          // Left circle avatar with image or initial fallback
          AppAvatar(
            imageUrl: senderAvatar,
            name: senderName.isNotEmpty ? senderName : message.senderId,
            size: 32,
            backgroundColor: avatarBg,
            fontSize: 13,
          ),
          const SizedBox(width: 10),
          // Message column
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sender name + timestamp header
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        senderName,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(message.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // White message card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
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
                    child: _buildRichMessageContent(message.content),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildRichMessageContent(String text) {
    // Check if message contains a quoted block (e.g. > quote or reply)
    final lines = text.split('\n');
    final quoteLines = <String>[];
    final bodyLines = <String>[];
    bool inQuote = false;

    for (final line in lines) {
      if (line.startsWith('> ') || line.startsWith('Quote:')) {
        quoteLines.add(line.replaceFirst(RegExp(r'^(> |Quote:)'), ''));
        inQuote = true;
      } else if (inQuote && line.isEmpty) {
        inQuote = false;
      } else if (inQuote) {
        quoteLines.add(line);
      } else {
        bodyLines.add(line);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (quoteLines.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: const Border(
                left: BorderSide(
                  color: Color(0xFF64748B),
                  width: 3,
                ),
              ),
            ),
            child: Text(
              quoteLines.join('\n'),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
        _parseFormattedText(
          bodyLines.isNotEmpty ? bodyLines.join('\n') : text,
        ),
      ],
    );
  }

  Widget _parseFormattedText(String text) {
    // Regex to split on @mentions, URLs, and emails
    final mentionRegex = RegExp(r'(@[a-zA-Z0-9_\-]+)|([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})|(https?://[^\s]+)');
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
        // Email or URL: blue text with underline
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
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }
}
