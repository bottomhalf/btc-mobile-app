import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../theme/app_theme.dart';

/// Single participant video/avatar card.
class ParticipantCard extends StatelessWidget {
  final Participant participant;
  final bool isMicOn;
  final bool isCameraOn;

  const ParticipantCard({
    super.key,
    required this.participant,
    this.isMicOn = true,
    this.isCameraOn = true,
  });

  @override
  Widget build(BuildContext context) {
    final isLocal = participant is LocalParticipant;

    final cameraPubs = participant.videoTrackPublications.where(
      (p) => p.source == TrackSource.camera,
    );
    final cameraTrack = cameraPubs.isNotEmpty
        ? cameraPubs.first.track as VideoTrack?
        : null;

    final screenPubs = participant.videoTrackPublications.where(
      (p) => p.source == TrackSource.screenShareVideo,
    );
    final screenTrack = screenPubs.isNotEmpty
        ? screenPubs.first.track as VideoTrack?
        : null;

    final isSharing = screenTrack != null && !screenTrack.muted;
    final hasCamera = isLocal
        ? isCameraOn && cameraTrack != null && !cameraTrack.muted
        : (cameraTrack != null && !cameraTrack.muted);
    final isMuted = isLocal
        ? !isMicOn
        : participant.isMicrophoneEnabled() == false;

    String name = participant.identity.isNotEmpty
        ? participant.identity
        : 'User';
    if (isLocal) {
      name = 'You';
    }
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.divider(context).withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video or Avatar
            if (isSharing)
              Positioned.fill(
                child: IgnorePointer(
                  child: VideoTrackRenderer(
                    screenTrack,
                    fit: VideoViewFit.contain,
                  ),
                ),
              )
            else if (hasCamera)
              Positioned.fill(
                child: IgnorePointer(
                  child: VideoTrackRenderer(
                    cameraTrack,
                    fit: VideoViewFit.cover,
                  ),
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      style: TextStyle(
                        color: AppTheme.textPrimary(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLocal
                          ? (isCameraOn ? 'Camera on' : 'Camera off')
                          : 'Camera off',
                      style: TextStyle(
                        color: AppTheme.textSecondary(context),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

            // Name & Mic Status Badge (Bottom Left)
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color:
                          isMuted ? AppTheme.errorRed : AppTheme.successGreen,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 80),
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Screen Share Badge
            if (isSharing)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.screen_share_rounded,
                        color: Colors.white,
                        size: 11,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Sharing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Fallback card shown when participant list is empty during connection.
class FallbackLocalCard extends StatelessWidget {
  final bool isCameraOn;

  const FallbackLocalCard({super.key, this.isCameraOn = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.divider(context).withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'U',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              isCameraOn ? 'Camera is on' : 'Camera is off',
              style: TextStyle(
                color: AppTheme.textSecondary(context),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
