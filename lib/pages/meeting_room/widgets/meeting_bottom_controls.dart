import 'package:flutter/material.dart';
import '../../../services/meeting_service.dart';
import '../../../theme/app_theme.dart';
import 'participants_list_sheet.dart';

/// Fixed bottom meeting controls with Mic, Camera, Screen Share, Team, and Leave actions.
class MeetingBottomControls extends StatelessWidget {
  static const double height = 66.0;

  final bool isMicOn;
  final bool isCameraOn;
  final bool isScreenSharing;
  final bool isLeaving;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleScreenShare;
  final VoidCallback? onShowParticipants;
  final VoidCallback onLeaveMeeting;

  const MeetingBottomControls({
    super.key,
    required this.isMicOn,
    required this.isCameraOn,
    required this.isScreenSharing,
    required this.isLeaving,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onToggleScreenShare,
    this.onShowParticipants,
    required this.onLeaveMeeting,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: height,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? null : AppTheme.card(context),
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF222228),
                    Color(0xFF121216),
                    Color(0xFF09090C),
                  ],
                  stops: [0.0, 0.35, 1.0],
                )
              : null,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.18)
                  : AppTheme.divider(context).withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.7 : 0.1),
              blurRadius: isDark ? 16 : 8,
              offset: const Offset(0, -2),
            ),
            if (isDark)
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.04),
                blurRadius: 1,
                offset: const Offset(0, -1),
              ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            ControlButton(
              icon: isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded,
              label: isMicOn ? 'Mute' : 'Unmute',
              isActive: isMicOn,
              onTap: onToggleMic,
              inactiveColor: isMicOn ? null : AppTheme.errorRed,
            ),
            ControlButton(
              icon: isCameraOn
                  ? Icons.videocam_rounded
                  : Icons.videocam_off_rounded,
              label: 'Camera',
              isActive: isCameraOn,
              onTap: onToggleCamera,
              inactiveColor: isCameraOn ? null : AppTheme.errorRed,
            ),
            ControlButton(
              icon: Icons.screen_share_rounded,
              label: 'Share',
              isActive: isScreenSharing,
              onTap: onToggleScreenShare,
              activeColor: AppTheme.accentPurple,
            ),
            ControlButton(
              icon: Icons.groups_rounded,
              label: 'Team',
              isActive: false,
              onTap: () {
                if (onShowParticipants != null) {
                  onShowParticipants!();
                } else {
                  ParticipantsListSheet.show(
                    context,
                    participants: MeetingService.instance.participants.toList(),
                    isMicOn: isMicOn,
                    isCameraOn: isCameraOn,
                  );
                }
              },
            ),
            LeaveButton(
              isLeaving: isLeaving,
              onLeave: onLeaveMeeting,
            ),
          ],
        ),
        ),
      ),
    );
  }
}

/// Circular action button with icon and label.
class ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? activeColor;
  final Color? inactiveColor;

  const ControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallbackInactiveColor = isDark ? Colors.white70 : AppTheme.textSecondary(context);
    final effectiveActiveColor = activeColor ?? AppTheme.accentPurple;
    final effectiveInactiveColor = inactiveColor ?? fallbackInactiveColor;
    final color = isActive ? effectiveActiveColor : effectiveInactiveColor;

    final BoxDecoration buttonDecoration;
    if (isDark) {
      if (isActive) {
        buttonDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              effectiveActiveColor.withValues(alpha: 0.4),
              effectiveActiveColor.withValues(alpha: 0.18),
            ],
          ),
          border: Border.all(
            color: effectiveActiveColor.withValues(alpha: 0.65),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: effectiveActiveColor.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        );
      } else {
        buttonDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E2E36),
              Color(0xFF18181F),
              Color(0xFF0E0E12),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        );
      }
    } else {
      buttonDecoration = BoxDecoration(
        color: isActive
            ? (activeColor ?? AppTheme.cardAlt(context)).withValues(alpha: 0.25)
            : AppTheme.cardAlt(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? color.withValues(alpha: 0.4)
              : AppTheme.divider(context).withValues(alpha: 0.3),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 38,
            height: 38,
            decoration: buttonDecoration,
            child: Icon(
              icon,
              color: color,
              size: 19,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              height: 1.1,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : AppTheme.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Red leave button with spinner during exit.
class LeaveButton extends StatelessWidget {
  final bool isLeaving;
  final VoidCallback onLeave;

  const LeaveButton({
    super.key,
    required this.isLeaving,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: isLeaving ? null : onLeave,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFF5757),
                  Color(0xFFE53935),
                  Color(0xFFC62828),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              border: isDark
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.0,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD32F2F).withValues(alpha: isDark ? 0.5 : 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isLeaving
                ? const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.call_end_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
          ),
          const SizedBox(height: 2),
          Text(
            'Leave',
            style: TextStyle(
              fontSize: 10,
              height: 1.1,
              fontWeight: FontWeight.w500,
              color: AppTheme.errorRed,
            ),
          ),
        ],
      ),
    );
  }
}
