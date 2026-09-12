import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/meeting_service.dart';
import '../../theme/app_theme.dart';

class BottomControls extends StatelessWidget {
  const BottomControls({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MeetingService.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? null : AppTheme.card(context).withValues(alpha: 0.95),
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
            color: Colors.black.withValues(alpha: isDark ? 0.7 : 0.15),
            blurRadius: isDark ? 16 : 10,
            offset: const Offset(0, -3),
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
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlBtn(
                context: context,
                icon: service.isMicOn.value
                    ? Icons.mic_rounded
                    : Icons.mic_off_rounded,
                isActive: service.isMicOn.value,
                onTap: service.toggleMic,
                activeColor: AppTheme.accentPurple,
                inactiveColor: service.isMicOn.value ? null : AppTheme.errorRed,
              ),
              _buildControlBtn(
                context: context,
                icon: service.isCameraOn.value
                    ? Icons.videocam_rounded
                    : Icons.videocam_off_rounded,
                isActive: service.isCameraOn.value,
                onTap: service.toggleCamera,
                activeColor: AppTheme.accentPurple,
                inactiveColor: service.isCameraOn.value ? null : AppTheme.errorRed,
              ),
              _buildControlBtn(
                context: context,
                icon: Icons.screen_share_rounded,
                isActive: service.isScreenSharing.value,
                onTap: service.toggleScreenShare,
                activeColor: AppTheme.accentPurple,
              ),
              _buildControlBtn(
                context: context,
                icon: Icons.groups_rounded,
                isActive: service.isParticipantsSheetVisible.value,
                onTap: service.toggleParticipantsSheet,
                activeColor: AppTheme.accentPurple,
              ),
              _buildLeaveBtn(context, service),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlBtn({
    required BuildContext context,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : AppTheme.textPrimary(context);

    final effectiveActiveColor = activeColor ?? AppTheme.accentPurple;
    final effectiveInactiveColor = inactiveColor ?? primaryText;

    final Color iconColor = isActive ? effectiveActiveColor : effectiveInactiveColor;

    final BoxDecoration buttonDecoration;
    if (isDark) {
      if (isActive) {
        buttonDecoration = BoxDecoration(
          shape: BoxShape.circle,
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
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
      } else {
        // Shiny black button with polished rim and gradient
        buttonDecoration = BoxDecoration(
          shape: BoxShape.circle,
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
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.06),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        );
      }
    } else {
      buttonDecoration = BoxDecoration(
        color: isActive
            ? effectiveActiveColor.withValues(alpha: 0.15)
            : AppTheme.cardAlt(context),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive
              ? effectiveActiveColor.withValues(alpha: 0.35)
              : AppTheme.divider(context).withValues(alpha: 0.5),
          width: 1,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        decoration: buttonDecoration,
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildLeaveBtn(BuildContext context, MeetingService service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: service.leaveMeeting,
      child: Container(
        width: 60,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
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
              color: const Color(0xFFD32F2F).withValues(alpha: isDark ? 0.5 : 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.call_end_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
