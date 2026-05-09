import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets/login_form_card.dart';
import 'widgets/login_header.dart';
import 'widgets/login_feature_chips.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  // ── Brand Colours ──
  static const Color _deepNavy = Color(0xFF0A0E21);
  static const Color _richIndigo = Color(0xFF4F46E5);
  static const Color _electricBlue = Color(0xFF06B6D4);
  static const Color _neonPurple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _deepNavy,
      body: Stack(
        children: [
          // ── Animated gradient background mesh ──
          _buildGradientMesh(size),

          // ── Subtle grid pattern overlay ──
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),

          // ── Content ──
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      _buildFooter(),
                      const SizedBox(height: 10),
                      _buildBottomInfo(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ── Deep gradient mesh background ──
  Widget _buildGradientMesh(Size size) {
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
                  _richIndigo.withValues(alpha: 0.35),
                  _richIndigo.withValues(alpha: 0.05),
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
                  _electricBlue.withValues(alpha: 0.2),
                  _electricBlue.withValues(alpha: 0.03),
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
                  _neonPurple.withValues(alpha: 0.22),
                  _neonPurple.withValues(alpha: 0.03),
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

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: Color(0xFF06B6D4),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo() {
    return Column(
      children: [
        Divider(
          color: Colors.white.withValues(alpha: 0.08),
          thickness: 1,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined,
                size: 14, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(width: 6),
            Text(
              'End-to-end encrypted  •  SOC 2 Compliant',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
