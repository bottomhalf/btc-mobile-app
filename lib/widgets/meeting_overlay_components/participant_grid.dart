import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../theme/app_theme.dart';

class ParticipantGrid extends StatelessWidget {
  final List<Participant> participants;

  const ParticipantGrid({super.key, required this.participants});

  @override
  Widget build(BuildContext context) {
    final displayList = participants.take(4).toList();
    final count = displayList.length;

    if (count == 1) {
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: _buildParticipantCard(displayList[0], context),
      );
    }

    if (count == 2) {
      return Column(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: _buildParticipantCard(
                displayList[0],
                context,
                bottomPadding: 4,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: _buildParticipantCard(
                displayList[1],
                context,
                topPadding: 4,
              ),
            ),
          ),
        ],
      );
    }

    if (count == 3) {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: _buildParticipantCard(
                      displayList[0],
                      context,
                      rightPadding: 4,
                      bottomPadding: 4,
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: _buildParticipantCard(
                      displayList[1],
                      context,
                      leftPadding: 4,
                      bottomPadding: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: _buildParticipantCard(
                displayList[2],
                context,
                topPadding: 4,
              ),
            ),
          ),
        ],
      );
    }

    // 4 participants
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: _buildParticipantCard(
                    displayList[0],
                    context,
                    rightPadding: 4,
                    bottomPadding: 4,
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: _buildParticipantCard(
                    displayList[1],
                    context,
                    leftPadding: 4,
                    bottomPadding: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: _buildParticipantCard(
                    displayList[2],
                    context,
                    rightPadding: 4,
                    topPadding: 4,
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: _buildParticipantCard(
                    displayList[3],
                    context,
                    leftPadding: 4,
                    topPadding: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantCard(
    Participant participant,
    BuildContext context, {
    double leftPadding = 0,
    double topPadding = 0,
    double rightPadding = 0,
    double bottomPadding = 0,
  }) {
    final cameraPubs = participant.videoTrackPublications.where(
      (p) => p.source == TrackSource.camera,
    );
    final cameraTrack = cameraPubs.isNotEmpty
        ? cameraPubs.first.track as VideoTrack?
        : null;

    final isCameraOn = cameraTrack != null && !cameraTrack.muted;
    final isMuted = participant.isMicrophoneEnabled() == false;

    String name = participant.identity.isNotEmpty
        ? participant.identity
        : 'User';
    if (participant is LocalParticipant) {
      name = 'You';
    }
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        leftPadding,
        topPadding,
        rightPadding,
        bottomPadding,
      ),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isCameraOn)
                Positioned.fill(
                  child: IgnorePointer(
                    child: VideoTrackRenderer(
                      cameraTrack,
                      fit: VideoViewFit.contain,
                    ),
                  ), // using contain to avoid cropping vertically
                )
              else ...[
                Positioned.fill(
                  child: Container(
                    color: AppTheme.surface(context).withValues(alpha: 0.5),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Overlay Name & Status
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      if (isMuted) ...[
                        const Icon(
                          Icons.mic_off,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
