import 'dart:io';
import 'package:conference/config/app_config.dart';
import 'package:conference/services/http_service.dart';
import 'package:conference_sdk/conference_sdk.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter/material.dart';
import '../../services/meeting_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/meeting_bottom_controls.dart';
import 'widgets/participant_grid.dart';
import 'widgets/participants_list_sheet.dart';

class MeetingRoomPage extends StatefulWidget {
  final ConferenceManager conferenceManager;
  final String? meetingTitle;
  final VoidCallback? onMinimize;

  const MeetingRoomPage({
    super.key,
    required this.conferenceManager,
    this.meetingTitle,
    this.onMinimize,
  });

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
  EventsListener<RoomEvent>? _roomListener;

  final _http = HttpService.instance;

  List<Participant> get _participants {
    if (_room == null) return [];
    return [
      if (_room!.localParticipant != null) _room!.localParticipant!,
      ..._room!.remoteParticipants.values,
    ];
  }

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

      _setupRoomListeners(room);

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

  void _setupRoomListeners(Room room) {
    _roomListener = room.createListener();
    _roomListener?.on<RoomEvent>((event) {
      if (!mounted) return;
      if (event is ParticipantConnectedEvent ||
          event is ParticipantDisconnectedEvent ||
          event is TrackSubscribedEvent ||
          event is TrackUnsubscribedEvent ||
          event is LocalTrackPublishedEvent ||
          event is LocalTrackUnpublishedEvent ||
          event is TrackMutedEvent ||
          event is TrackUnmutedEvent) {
        setState(() {});
      }
    });
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
    _roomListener?.dispose();
    _roomListener = null;
    // Clean up — disconnect if still connected
    _room?.disconnect();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    final nextState = !_isMicOn;
    setState(() => _isMicOn = nextState);
    await _room?.localParticipant?.setMicrophoneEnabled(nextState);
  }

  Future<void> _toggleCamera() async {
    final nextState = !_isCameraOn;
    setState(() => _isCameraOn = nextState);
    await _room?.localParticipant?.setCameraEnabled(nextState);
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
    await _roomListener?.dispose();
    _roomListener = null;
    await _room?.disconnect();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  String get _displayTitle {
    if (widget.meetingTitle != null && widget.meetingTitle!.trim().isNotEmpty) {
      return widget.meetingTitle!.trim();
    }
    if (_room?.name != null && _room!.name!.trim().isNotEmpty) {
      return _room!.name!.trim();
    }
    if (MeetingService.instance.meetingName.trim().isNotEmpty) {
      return MeetingService.instance.meetingName.trim();
    }
    return 'In Meeting';
  }

  void _handleMinimize() {
    if (widget.onMinimize != null) {
      widget.onMinimize!();
      return;
    }
    if (MeetingService.instance.isInMeeting.value) {
      MeetingService.instance.minimize();
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _showParticipantsSheet() {
    final list = _participants.isNotEmpty
        ? _participants
        : (MeetingService.instance.isInMeeting.value
            ? MeetingService.instance.participants.toList()
            : <Participant>[]);
    ParticipantsListSheet.show(
      context,
      participants: list,
      isMicOn: _isMicOn,
      isCameraOn: _isCameraOn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (_isConnecting || _errorMessage != null) {
            Navigator.of(context).pop();
          } else {
            _handleMinimize();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.surface(context),
        body: SafeArea(
          child: _isConnecting
              ? _buildConnectingState()
              : _errorMessage != null
              ? _buildErrorState()
              : _buildMeetingUI(context),
        ),
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
    return Stack(
      children: [
        // ─── Top: All Participant Cards ─────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: MeetingBottomControls.height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: ParticipantGrid(
              participants: _participants,
              isMicOn: _isMicOn,
              isCameraOn: _isCameraOn,
              onShowAllParticipants: _showParticipantsSheet,
            ),
          ),
        ),

        // ─── Floating Top: Meeting Title Label (Stretched Circular) ───
        Positioned(
          top: 14,
          left: 20,
          right: 20,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? null
                    : AppTheme.card(context).withValues(alpha: 0.88),
                gradient: Theme.of(context).brightness == Brightness.dark
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF222228),
                          Color(0xFF141419),
                          Color(0xFF0C0C10),
                        ],
                        stops: [0.0, 0.4, 1.0],
                      )
                    : null,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.18)
                      : AppTheme.divider(context).withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark ? 0.5 : 0.2,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary(context),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),

        // ─── Bottom: Only Control Card ───────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: MeetingBottomControls.height,
          child: MeetingBottomControls(
            isMicOn: _isMicOn,
            isCameraOn: _isCameraOn,
            isScreenSharing: _isScreenSharing,
            isLeaving: _isLeaving,
            onToggleMic: _toggleMic,
            onToggleCamera: _toggleCamera,
            onToggleScreenShare: _toggleScreenShare,
            onShowParticipants: _showParticipantsSheet,
            onLeaveMeeting: _leaveMeeting,
          ),
        ),
      ],
    );
  }
}
