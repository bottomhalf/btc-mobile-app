import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../theme/app_theme.dart';

/// Modal bottom sheet listing all participants with status details.
class ParticipantsListSheet extends StatelessWidget {
  final List<Participant> participants;
  final bool isMicOn;
  final bool isCameraOn;

  const ParticipantsListSheet({
    super.key,
    required this.participants,
    required this.isMicOn,
    required this.isCameraOn,
  });

  /// Helper to display the sheet.
  static void show(
    BuildContext context, {
    required List<Participant> participants,
    required bool isMicOn,
    required bool isCameraOn,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) => ParticipantsListSheet(
        participants: participants,
        isMicOn: isMicOn,
        isCameraOn: isCameraOn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (sheetContext, scrollController) {
        return Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider(sheetContext),
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
                        'Participants (${participants.length})',
                        style: Theme.of(sheetContext)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: AppTheme.divider(sheetContext).withValues(alpha: 0.3),
            ),
            // Participant list
            Expanded(
              child: participants.isEmpty
                  ? Center(
                      child: Text(
                        'No participants',
                        style: TextStyle(
                          color: AppTheme.textSecondary(sheetContext),
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: participants.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        indent: 68,
                        color: AppTheme.divider(sheetContext)
                            .withValues(alpha: 0.3),
                      ),
                      itemBuilder: (itemCtx, index) {
                        final p = participants[index];
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
                                    : AppTheme.textSecondary(sheetContext),
                                size: 18,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
