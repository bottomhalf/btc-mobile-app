import 'package:conference/pages/team/chat_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Message input box styled exactly to match the team.png reference design.
///
/// Features:
/// - Clean white rounded card (BorderRadius.circular(10), border Color(0xFFE5E7EB))
/// - Left action tools: Text format (T), Attach (paperclip), Emoji, GIF
/// - Placeholder text: "Type a new message or @mention"
/// - Right send icon button in subtle card
/// - Keyboard shortcuts: Enter to send, Shift+Enter for newline
class MessageInput extends StatefulWidget {
  final ChatDetailController controller;

  const MessageInput({
    super.key,
    required this.controller,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.messageController.text.trim().isNotEmpty;
    widget.controller.messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.messageController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final has = widget.controller.messageController.text.trim().isNotEmpty;
    if (has != _hasText) {
      setState(() {
        _hasText = has;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      color: Colors.transparent,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left formatting & attachment tools
              _buildToolIcon(
                icon: Icons.text_format_rounded,
                tooltip: 'Formatting',
                onTap: () {},
              ),
              _buildToolIcon(
                icon: Icons.attach_file_rounded,
                tooltip: 'Attach file',
                onTap: () {},
              ),
              _buildToolIcon(
                icon: Icons.sentiment_satisfied_outlined,
                tooltip: 'Emoji',
                onTap: () {},
              ),
              _buildToolIcon(
                icon: Icons.gif_box_outlined,
                tooltip: 'GIF',
                onTap: () {},
              ),
              const SizedBox(width: 6),

              // Input field with placeholder matching team.png
              Expanded(
                child: Focus(
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.enter &&
                        !HardwareKeyboard.instance.isShiftPressed) {
                      widget.controller.sendMessage();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: TextField(
                    controller: widget.controller.messageController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Type a new message or @mention',
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Right send button matching team.png
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: widget.controller.sendMessage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _hasText
                          ? const Color(0xFF4F46E5) // Purple active button
                          : const Color(0xFFF3F4F6), // Light grey disabled
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      size: 16,
                      color: _hasText ? Colors.white : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolIcon({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(
              icon,
              size: 19,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}
