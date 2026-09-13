import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/theme_service.dart';
import '../login_controller.dart';
import 'widgets/desktop_login_sidebar.dart';
import 'widgets/desktop_login_form.dart';

/// Desktop-optimised login layout.
///
/// Uses a split-panel design:
/// - Left panel (~45%): Branded sidebar with logo, tagline & features
/// - Right panel (~55%): Glassmorphic login form
///
/// The layout is also responsive within the desktop breakpoint:
/// - 800–1100px: narrower sidebar, tighter padding
/// - 1100px+: full sidebar with comfortable spacing
class DesktopLoginPage extends GetView<LoginController> {
  const DesktopLoginPage({super.key});

  static const Color _deepNavy = Color(0xFF0A0E21);
  static const Color _richIndigo = Color(0xFF4F46E5);
  static const Color _electricBlue = Color(0xFF06B6D4);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    // Adaptive sidebar flex based on width
    final sidebarFlex = width > 1100 ? 45 : 38;
    final formFlex = width > 1100 ? 55 : 62;

    return Obx(() {
      final isDark = ThemeService.instance.isDarkMode;

      return Scaffold(
        backgroundColor: isDark ? _deepNavy : const Color(0xFFF1F5F9),
        body: Row(
          children: [
            // ── Left: Branded Sidebar ──
            Expanded(
              flex: sidebarFlex,
              child: const DesktopLoginSidebar(),
            ),

            // ── Right: Login Form ──
            Expanded(
              flex: formFlex,
              child: _buildFormPanel(context, isDark),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFormPanel(BuildContext context, bool isDark) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      color: isDark ? const Color(0xFF0D1228) : const Color(0xFFF8FAFC),
      child: Stack(
        children: [
          // ── Subtle gradient orbs on right panel ──
          Positioned(
            top: -60,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _electricBlue.withValues(alpha: isDark ? 0.1 : 0.12),
                    _electricBlue.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _richIndigo.withValues(alpha: isDark ? 0.12 : 0.14),
                    _richIndigo.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ── Dot grid ──
          Positioned.fill(
            child: CustomPaint(painter: _FormPanelGridPainter(isDark: isDark)),
          ),

          // ── Theme toggle button in top right ──
          Positioned(
            top: 24,
            right: 28,
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? const Color(0xFFFBBF24) : _richIndigo,
                  size: 20,
                ),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: ThemeService.instance.toggleTheme,
              ),
            ),
          ),

          // ── Centered form ──
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width > 1200 ? 80 : 48,
                  vertical: 40,
                ),
                child: const DesktopLoginForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Subtle dot-grid painter for the form panel ──
class _FormPanelGridPainter extends CustomPainter {
  final bool isDark;
  const _FormPanelGridPainter({this.isDark = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.02)
          : const Color(0xFF0F172A).withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const spacing = 36.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FormPanelGridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
