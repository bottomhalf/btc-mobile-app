import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/meeting_service.dart';
import '../theme/app_theme.dart';

import 'meeting_overlay_components/connecting_state.dart';
import 'meeting_overlay_components/error_state.dart';
import 'meeting_overlay_components/top_bar.dart';
import 'meeting_overlay_components/video_area.dart';
import 'meeting_overlay_components/mini_window.dart';

/// In-app meeting overlay that supports two modes:
///
/// **Full mode** — covers entire screen with meeting controls, video area, etc.
/// **Mini mode** — small draggable card at a screen corner showing status.
///
/// Rendered via [MeetingOverlayManager] as an Overlay entry.
class MeetingOverlay extends StatefulWidget {
  const MeetingOverlay({super.key});

  @override
  State<MeetingOverlay> createState() => _MeetingOverlayState();
}

class _MeetingOverlayState extends State<MeetingOverlay> {
  final _service = MeetingService.instance;

  // Mini-window drag position
  double _miniX = double.infinity;
  double _miniY = double.infinity;
  bool _positioned = false;

  static const double _miniWidth = 160;
  static const double _miniHeight = 100;
  static const double _miniPadding = 16;

  void _snapToNearestCorner(Size screenSize) {
    final centerX = _miniX + _miniWidth / 2;
    final centerY = _miniY + _miniHeight / 2;
    final midX = screenSize.width / 2;
    final midY = screenSize.height / 2;

    setState(() {
      _miniX = centerX < midX
          ? _miniPadding
          : screenSize.width - _miniWidth - _miniPadding;
      _miniY = centerY < midY
          ? _miniPadding + MediaQuery.of(context).padding.top
          : screenSize.height -
                _miniHeight -
                _miniPadding -
                MediaQuery.of(context).padding.bottom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Initialize position on first build
    if (!_positioned) {
      _miniX = screenSize.width - _miniWidth - _miniPadding;
      _miniY = screenSize.height - _miniHeight - _miniPadding - 80;
      _positioned = true;
    }

    return Obx(() {
      if (!_service.isInMeeting.value) {
        return const SizedBox.shrink();
      }

      if (_service.isFullScreen.value) {
        return _buildFullScreen(context);
      } else {
        return MiniWindow(
          screenSize: screenSize,
          miniX: _miniX,
          miniY: _miniY,
          miniWidth: _miniWidth,
          miniHeight: _miniHeight,
          onPanUpdate: (d) {
            setState(() {
              _miniX = (_miniX + d.delta.dx).clamp(
                0.0,
                screenSize.width - _miniWidth,
              );
              _miniY = (_miniY + d.delta.dy).clamp(
                0.0,
                screenSize.height - _miniHeight,
              );
            });
          },
          onPanEnd: (_) => _snapToNearestCorner(screenSize),
        );
      }
    });
  }

  Widget _buildFullScreen(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _service.minimize();
      },
      child: Material(
        color: AppTheme.surface(context),
        child: SafeArea(
          child: Obx(() {
            if (_service.isConnecting.value) {
              return const ConnectingState();
            }
            if (_service.errorMessage.value != null) {
              return const ErrorState();
            }
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _service.toggleControls,
              child: const Column(
                children: [
                  TopBar(),
                  Expanded(child: VideoArea()),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
