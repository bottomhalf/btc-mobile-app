import 'package:conference/pages/team/chat_detail_controller.dart';
import 'package:conference/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Bottom message typing panel for sending messages styled like Google Chat.
///
/// Features:
/// - Centered responsive card layout matching the chat column
/// - Automatically scales based on screen size up to a max width of 860px
/// - Integrated attachment button, multiline text input, and circular send button
/// - Clean rounded pill border and subtle elevation
class MessageInput extends StatelessWidget {
  final ChatDetailController controller;

  const MessageInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      color: Colors.transparent,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 860),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.divider(context).withValues(alpha: 0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: IconButton(
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppTheme.textSecondary(context),
                    size: 24,
                  ),
                  onPressed: () {},
                  tooltip: 'Attach file',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller.messageController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: AppTheme.textSecondary(context)
                          .withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
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
                  onSubmitted: (_) async => await controller.sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, right: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentPurple.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: controller.sendMessage,
                    tooltip: 'Send message',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
