import 'dart:io';
import 'package:conference/config/app_config.dart';
import 'package:conference/services/http_service.dart';
import 'package:conference/services/meeting_service.dart';
import 'package:conference_sdk/conference_sdk.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';

class MeetingRoomPage extends StatefulWidget {
  final ConferenceManager conferenceManager;

  const MeetingRoomPage({super.key, required this.conferenceManager});

  @override
  State<MeetingRoomPage> createState() => _MeetingRoomPageState();
}

class _MeetingRoomPageState extends State<MeetingRoomPage> {
  bool _isMicOn = true;
  bool _isCameraOn = true;
  bool _isScreenSharing = false;
  bool _isLeaving = false;

  bool _isConnecting = true;
  String? _errorMessage;
  Room? _room;

  final _http = HttpService.instance;

  @override
  void initState() {
    super.initState();
    // Fire-and-forget — never make initState async
    _initMeeting();
  }

  /// Async meeting initialization — called from initState().
  Future<void> _initMeeting() async {
    try {
      // 1. Fetch the LiveKit token from backend
      final token = await _http.getMeetingToken(
        "694f949da08d8877589cbdda",
        "Vivek Kumar",
      );

      // 2. Connect to the LiveKit room
      final room = await widget.conferenceManager.joinRoom(
        "wss://${AppConfig.instance.livekitUrl}/conference",
        token,
      );

      if (!mounted) return;

      // 3. Enable mic & camera after joining
      try {
        await room.localParticipant?.setMicrophoneEnabled(true);
      } catch (e) {
        debugPrint("Mic enable failed: $e");
      }
      try {
        await room.localParticipant?.setCameraEnabled(true);
      } catch (e) {
        debugPrint("Camera enable failed: $e");
      }

      if (!mounted) return;

      setState(() {
        _room = room;
        _isConnecting = false;
      });
    } catch (e) {
      debugPrint("Meeting init failed: $e");
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<bool> _startBackgroundExecution() async {
    if (!Platform.isAndroid) return true;
    try {
      const androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "Screen Sharing Active",
        notificationText: "Confeet is sharing your screen in the meeting",
        notificationImportance: AndroidNotificationImportance.normal,
        notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
      );
      final initialized = await FlutterBackground.initialize(androidConfig: androidConfig);
      if (initialized) {
        if (!FlutterBackground.isBackgroundExecutionEnabled) {
          return await FlutterBackground.enableBackgroundExecution();
        }
        return true;
      }
    } catch (e) {
      debugPrint("FlutterBackground initialize error: $e");
    }
    return false;
  }

  Future<void> _stopBackgroundExecution() async {
    if (!Platform.isAndroid) return;
    try {
      if (FlutterBackground.isBackgroundExecutionEnabled) {
        await FlutterBackground.disableBackgroundExecution();
      }
    } catch (e) {
      debugPrint("FlutterBackground disable error: $e");
    }
  }

  @override
  void dispose() {
    _stopBackgroundExecution();
    // Clean up — disconnect if still connected
    _room?.disconnect();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    setState(() => _isMicOn = !_isMicOn);
    await _room?.localParticipant?.setMicrophoneEnabled(_isMicOn);
  }

  Future<void> _toggleCamera() async {
    setState(() => _isCameraOn = !_isCameraOn);
    await _room?.localParticipant?.setCameraEnabled(_isCameraOn);
  }

  Future<void> _toggleScreenShare() async {
    final newState = !_isScreenSharing;
    if (newState) {
      try {
        if (Platform.isAndroid) {
          final hasCapturePermission = await Helper.requestCapturePermission();
          if (!hasCapturePermission) {
            debugPrint("Screen capture permission was not granted by user");
            return;
          }
          await _startBackgroundExecution();
        }
        await _room?.localParticipant?.setScreenShareEnabled(true, captureScreenAudio: false);
        if (!mounted) return;
        setState(() => _isScreenSharing = true);
      } catch (e) {
        debugPrint("Screen share failed: $e");
        await _stopBackgroundExecution();
        if (!mounted) return;
        setState(() => _isScreenSharing = false);
      }
    } else {
      try {
        await _room?.localParticipant?.setScreenShareEnabled(false);
      } catch (e) {
        debugPrint("Disable screen share failed: $e");
      }
      await _stopBackgroundExecution();
      if (!mounted) return;
      setState(() => _isScreenSharing = false);
    }
  }

  Future<void> _leaveMeeting() async {
    setState(() => _isLeaving = true);
    await _stopBackgroundExecution();
    await _room?.disconnect();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface(context),
      body: SafeArea(
        child: _isConnecting
            ? _buildConnectingState()
            : _errorMessage != null
            ? _buildErrorState()
            : _buildMeetingUI(context),
      ),
    );
  }

  // ─── Connecting / Loading State ──────────────────────────────

  Widget _buildConnectingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.accentPurple,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Joining meeting…',
            style: TextStyle(
              color: AppTheme.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connecting to the conference server',
            style: TextStyle(
              color: AppTheme.textSecondary(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Error State ─────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 20),
            Text(
              'Connection Failed',
              style: TextStyle(
                color: AppTheme.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.divider(context)),
                  ),
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 14),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isConnecting = true;
                      _errorMessage = null;
                    });
                    _initMeeting();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPurple,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Main Meeting UI ────────────────────────────────────────

  Widget _buildMeetingUI(BuildContext context) {
    return Column(
      children: [
        // ─── Top Bar ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.fiber_manual_record_rounded,
                  color: AppTheme.successGreen,
                  size: 12,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'In Meeting',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.divider(context).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: 16,
                      color: AppTheme.accentPurple,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${(_room?.remoteParticipants.length ?? 0) + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ─── Video Area ──────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.divider(context).withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Obx(() {
                    final screenTrack =
                        MeetingService.instance.activeScreenShareTrack.value;
                    final videoTrack =
                        MeetingService.instance.activeVideoTrack.value;

                    if (screenTrack != null) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: IgnorePointer(
                          child: VideoTrackRenderer(
                            screenTrack,
                            fit: VideoViewFit.contain,
                          ),
                        ),
                      );
                    } else if (videoTrack != null) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: IgnorePointer(
                          child: VideoTrackRenderer(
                            videoTrack,
                            fit: VideoViewFit.cover,
                          ),
                        ),
                      );
                    }

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
                        const SizedBox(height: 16),
                        Text(
                          'You',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isCameraOn ? 'Camera is on' : 'Camera is off',
                          style: TextStyle(
                            color: AppTheme.textSecondary(context),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),

        // ─── Bottom Controls ─────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: AppTheme.card(context).withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: AppTheme.divider(context).withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: _isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                label: _isMicOn ? 'Mute' : 'Unmute',
                isActive: _isMicOn,
                onTap: _toggleMic,
              ),
              _buildControlButton(
                icon: _isCameraOn
                    ? Icons.videocam_rounded
                    : Icons.videocam_off_rounded,
                label: 'Camera',
                isActive: _isCameraOn,
                onTap: _toggleCamera,
              ),
              _buildControlButton(
                icon: Icons.screen_share_rounded,
                label: 'Share',
                isActive: _isScreenSharing,
                onTap: _toggleScreenShare,
                activeColor: AppTheme.accentPurple,
              ),
              _buildControlButton(
                icon: Icons.groups_rounded,
                label: 'Team',
                isActive: false,
                onTap: () {},
              ),
              _buildLeaveButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    final color = activeColor ?? AppTheme.textPrimary(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isActive
                  ? (activeColor ?? AppTheme.cardAlt(context)).withValues(
                      alpha: 0.25,
                    )
                  : AppTheme.cardAlt(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? color.withValues(alpha: 0.4)
                    : AppTheme.divider(context).withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? color : AppTheme.textSecondary(context),
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveButton() {
    return GestureDetector(
      onTap: _isLeaving ? null : _leaveMeeting,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.errorRed,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.errorRed.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isLeaving
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.call_end_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            'Leave',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.errorRed,
            ),
          ),
        ],
      ),
    );
  }
}
