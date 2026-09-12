import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Fixed bottom meeting controls with Mic, Camera, Screen Share, Team, and Leave actions.
class MeetingBottomControls extends StatelessWidget {
  static const double height = 90.0;

  final bool isMicOn;
  final bool isCameraOn;
  final bool isScreenSharing;
  final bool isLeaving;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleScreenShare;
  final VoidCallback onShowParticipants;
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
    required this.onShowParticipants,
    required this.onLeaveMeeting,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.card(context).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.divider(context).withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ControlButton(
              icon: isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded,
              label: isMicOn ? 'Mute' : 'Unmute',
              isActive: isMicOn,
              onTap: onToggleMic,
            ),
            ControlButton(
              icon: isCameraOn
                  ? Icons.videocam_rounded
                  : Icons.videocam_off_rounded,
              label: 'Camera',
              isActive: isCameraOn,
              onTap: onToggleCamera,
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
              onTap: onShowParticipants,
            ),
            LeaveButton(
              isLeaving: isLeaving,
              onLeave: onLeaveMeeting,
            ),
          ],
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

  const ControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppTheme.textPrimary(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isActive
                  ? (activeColor ?? AppTheme.cardAlt(context)).withValues(
                      alpha: 0.25,
                    )
                  : AppTheme.cardAlt(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? color.withValues(alpha: 0.4)
                    : AppTheme.divider(context).withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? color : AppTheme.textSecondary(context),
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              height: 1.1,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary(context),
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
    return GestureDetector(
      onTap: isLeaving ? null : onLeave,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.errorRed,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.errorRed.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: isLeaving
                ? const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.call_end_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
          ),
          const SizedBox(height: 4),
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
