import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../services/meeting_service.dart';
import '../../../theme/app_theme.dart';

/// Modal bottom sheet listing all participants with status details.
class ParticipantsListSheet extends StatelessWidget {
  final List<Participant> participants;
  final bool isMicOn;
  final bool isCameraOn;
  final VoidCallback? onClose;

  const ParticipantsListSheet({
    super.key,
    required this.participants,
    required this.isMicOn,
    required this.isCameraOn,
    this.onClose,
  });

  /// Helper to display the sheet.
  static void show(
    BuildContext context, {
    required List<Participant> participants,
    required bool isMicOn,
    required bool isCameraOn,
    VoidCallback? onClose,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) => ParticipantsListSheet(
        participants: participants,
        isMicOn: isMicOn,
        isCameraOn: isCameraOn,
        onClose: onClose,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveParticipants = participants.isNotEmpty
        ? participants
        : (MeetingService.instance.isInMeeting.value
            ? MeetingService.instance.participants.toList()
            : <Participant>[]);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? null : AppTheme.card(context),
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF222228),
                  Color(0xFF141419),
                  Color(0xFF0C0C10),
                ],
                stops: [0.0, 0.25, 1.0],
              )
            : null,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.18)
              : AppTheme.divider(context).withValues(alpha: 0.3),
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.groups_rounded,
                      color: AppTheme.accentPurple,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Participants (${effectiveParticipants.length})',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    if (onClose != null) {
                      onClose!();
                    } else if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: AppTheme.divider(context).withValues(alpha: 0.3),
          ),
          // Participant list
          Expanded(
            child: effectiveParticipants.isEmpty
                ? Center(
                    child: Text(
                      'No participants',
                      style: TextStyle(
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: effectiveParticipants.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      indent: 68,
                      color: AppTheme.divider(context)
                          .withValues(alpha: 0.3),
                    ),
                      itemBuilder: (itemCtx, index) {
                        final p = effectiveParticipants[index];
                        final isLocal = p is LocalParticipant;
                        String name =
                            p.identity.isNotEmpty ? p.identity : 'User';
                        if (isLocal) name = 'You';
                        final initial =
                            name.isNotEmpty ? name[0].toUpperCase() : 'U';

                        final cameraPubs = p.videoTrackPublications.where(
                          (pub) => pub.source == TrackSource.camera,
                        );
                        final cameraTrack = cameraPubs.isNotEmpty
                            ? cameraPubs.first.track as VideoTrack?
                            : null;
                        final isCamOn = isLocal
                            ? isCameraOn &&
                                cameraTrack != null &&
                                !cameraTrack.muted
                            : (cameraTrack != null && !cameraTrack.muted);

                        final isMuted = isLocal
                            ? !isMicOn
                            : p.isMicrophoneEnabled() == false;

                        final screenPubs = p.videoTrackPublications.where(
                          (pub) => pub.source == TrackSource.screenShareVideo,
                        );
                        final isSharing = screenPubs.isNotEmpty &&
                            screenPubs.first.track != null &&
                            !screenPubs.first.track!.muted;

                        return ListTile(
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: AppTheme.accentGradient,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (isLocal) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentPurple
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'You',
                                    style: TextStyle(
                                      color: AppTheme.accentPurple,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: isSharing
                              ? Row(
                                  children: [
                                    Icon(
                                      Icons.screen_share_rounded,
                                      size: 13,
                                      color: AppTheme.accentPurple,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Sharing screen',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.accentPurple,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isMuted
                                    ? Icons.mic_off_rounded
                                    : Icons.mic_rounded,
                                color: isMuted
                                    ? AppTheme.errorRed
                                    : AppTheme.successGreen,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                isCamOn
                                    ? Icons.videocam_rounded
                                    : Icons.videocam_off_rounded,
                                color: isCamOn
                                    ? AppTheme.accentPurple
                                    : AppTheme.textSecondary(context),
                                size: 18,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
  }
}
