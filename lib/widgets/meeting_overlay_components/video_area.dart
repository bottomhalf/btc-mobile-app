import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../services/meeting_service.dart';
import '../../theme/app_theme.dart';
import 'bottom_controls.dart';
import 'participant_grid.dart';

class VideoArea extends StatefulWidget {
  const VideoArea({super.key});

  @override
  State<VideoArea> createState() => _VideoAreaState();
}

class _VideoAreaState extends State<VideoArea> {
  bool _isScreenRotated = false;

  void _toggleRotation() {
    debugPrint('Toggling rotation--------------------------------');
    setState(() {
      _isScreenRotated = !_isScreenRotated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = MeetingService.instance;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Stack(
          alignment: Alignment.center,
          children: [
            // Video Background/Player
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.divider(context).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Obx(() {
                      final screenTrack = service.activeScreenShareTrack.value;

                      if (screenTrack != null) {
                        Widget player = IgnorePointer(
                          child: VideoTrackRenderer(
                            screenTrack,
                            fit: VideoViewFit.contain,
                          ),
                        );

                        if (_isScreenRotated) {
                          player = RotatedBox(
                            quarterTurns: 1, // 90 degree rotation
                            child: player,
                          );
                        }

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            player,
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: GestureDetector(
                                onTap: _toggleRotation,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.screen_rotation_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else if (service.participants.isNotEmpty) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            8.0,
                            8.0,
                            8.0,
                            service.isControlsVisible.value ? 68.0 : 8.0,
                          ),
                          child: ParticipantGrid(
                            participants: service.participants.toList(),
                          ),
                        );
                      }

                      // Fallback if participants array is somehow empty
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: AppTheme.accentGradient,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Center(
                              child: Text(
                                'U',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),

            // Floating Bottom Controls
            Obx(() {
              final hasScreenShare =
                  service.activeScreenShareTrack.value != null;
              final shouldRotateControls = hasScreenShare && _isScreenRotated;

              Widget controls = Visibility(
                visible: service.isControlsVisible.value,
                child: const BottomControls(),
              );

              if (shouldRotateControls) {
                controls = RotatedBox(quarterTurns: 1, child: controls);
              }

              return Positioned(
                bottom: shouldRotateControls ? null : 0,
                left: shouldRotateControls ? 24 : 0,
                right: shouldRotateControls ? null : 0,
                child: controls,
              );
            }),
          ],
        ),
      );
  }
}
