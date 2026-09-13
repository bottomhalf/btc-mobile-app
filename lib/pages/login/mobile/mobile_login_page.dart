import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/theme_service.dart';
import 'widgets/login_form_card.dart';
import 'widgets/login_header.dart';
import 'widgets/login_feature_chips.dart';
import '../login_controller.dart';

/// Mobile-optimised login layout.
///
/// This is the original LoginPage UI extracted verbatim into
/// the mobile/ subfolder so that it can be loaded conditionally
/// via [ResponsiveBuilder].
class MobileLoginPage extends GetView<LoginController> {
  const MobileLoginPage({super.key});

  // ── Brand Colours ──
  static const Color _deepNavy = Color(0xFF0A0E21);
  static const Color _richIndigo = Color(0xFF4F46E5);
  static const Color _electricBlue = Color(0xFF06B6D4);
  static const Color _neonPurple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Obx(() {
      final isDark = ThemeService.instance.isDarkMode;

      return Scaffold(
        backgroundColor: isDark ? _deepNavy : const Color(0xFFF1F5F9),
        body: Stack(
          children: [
            // ── Animated gradient background mesh ──
            _buildGradientMesh(size, isDark),

            // ── Subtle grid pattern overlay ──
            Positioned.fill(
              child: CustomPaint(painter: _GridPainter(isDark: isDark)),
            ),

            // ── Theme toggle button ──
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 18,
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

            // ── Content ──
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                      maxWidth: 480,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width > 600 ? 32 : 24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          const LoginHeader(),
                          const SizedBox(height: 16),
                          const LoginFeatureChips(),
                          const SizedBox(height: 18),
                          const LoginFormCard(),
                          const SizedBox(height: 14),
                          _buildPrivacyPolicyFooter(isDark),
                          const SizedBox(height: 10),
                          _buildBottomInfo(isDark),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// ── Deep gradient mesh background with spots ──
  Widget _buildGradientMesh(Size size, bool isDark) {
    return Stack(
      children: [
        // Top-left indigo orb
        Positioned(
          top: -size.height * 0.15,
          left: -size.width * 0.3,
          child: Container(
            width: size.width * 0.9,
            height: size.width * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _richIndigo.withValues(alpha: isDark ? 0.35 : 0.22),
                  _richIndigo.withValues(alpha: isDark ? 0.05 : 0.04),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Center-right cyan orb
        Positioned(
          top: size.height * 0.3,
          right: -size.width * 0.25,
          child: Container(
            width: size.width * 0.7,
            height: size.width * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _electricBlue.withValues(alpha: isDark ? 0.20 : 0.18),
                  _electricBlue.withValues(alpha: isDark ? 0.03 : 0.03),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Bottom-left purple orb
        Positioned(
          bottom: -size.height * 0.08,
          left: -size.width * 0.15,
          child: Container(
            width: size.width * 0.65,
            height: size.width * 0.65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _neonPurple.withValues(alpha: isDark ? 0.22 : 0.20),
                  _neonPurple.withValues(alpha: isDark ? 0.03 : 0.03),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyPolicyFooter(bool isDark) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'By signing in, you agree to our ',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.55)
                    : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed('/privacy-policy'),
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: isDark ? const Color(0xFF06B6D4) : _richIndigo,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: isDark ? const Color(0xFF06B6D4) : _richIndigo,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.toNamed('/privacy-policy'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFF06B6D4).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF06B6D4).withValues(alpha: isDark ? 0.35 : 0.45),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.privacy_tip_outlined,
                  size: 14,
                  color: Color(0xFF06B6D4),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Privacy & Security Policy',
                  style: TextStyle(
                    color: Color(0xFF06B6D4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo(bool isDark) {
    return Column(
      children: [
        Divider(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
          thickness: 1,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.35)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              'End-to-end encrypted  •  Enterprise Privacy Protected',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.35)
                    : const Color(0xFF64748B),
                fontSize: 11,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ── Subtle dot-grid pattern painter ──
class _GridPainter extends CustomPainter {
  final bool isDark;
  const _GridPainter({this.isDark = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.03)
          : const Color(0xFF0F172A).withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
