import 'package:flutter/material.dart';

/// Desktop branded sidebar for the login page.
///
/// Shows the logo, app title, tagline, and a vertical list of
/// feature highlights on a deep-navy background with animated
/// gradient orbs.
class DesktopLoginSidebar extends StatelessWidget {
  const DesktopLoginSidebar({super.key});

  static const Color _deepNavy = Color(0xFF0A0E21);
  static const Color _richIndigo = Color(0xFF4F46E5);
  static const Color _electricBlue = Color(0xFF06B6D4);
  static const Color _neonPurple = Color(0xFF8B5CF6);
  static const Color _emeraldGreen = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? _deepNavy : const Color(0xFFEDF2F7),
      ),
      child: Stack(
        children: [
          // ── Gradient orbs ──
          _buildGradientOrbs(size, isDark),

          // ── Dot grid ──
          Positioned.fill(
            child: CustomPaint(painter: _SidebarGridPainter(isDark: isDark)),
          ),

          // ── Content ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo + Title ──
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _neonPurple.withValues(alpha: isDark ? 0.4 : 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: _richIndigo.withValues(alpha: isDark ? 0.25 : 0.15),
                            blurRadius: 30,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: isDark
                            ? const [Colors.white, Color(0xFF06B6D4)]
                            : const [Color(0xFF0F172A), Color(0xFF4F46E5)],
                      ).createShader(bounds),
                      child: const Text(
                        'Confeet',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // ── Tagline ──
                Text(
                  'Your AI-powered\nmeeting platform',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.95)
                        : const Color(0xFF0F172A),
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Crystal-clear audio, HD video, smart transcription\n'
                  'and AI-generated meeting notes — all in one place.',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : const Color(0xFF475569),
                    height: 1.6,
                    letterSpacing: 0.1,
                  ),
                ),

                const SizedBox(height: 48),

                // ── Feature list ──
                _buildFeatureItem(
                  Icons.auto_awesome,
                  'AI Meeting Notes',
                  'Automatic summaries & action items',
                  _neonPurple,
                  isDark,
                ),
                const SizedBox(height: 20),
                _buildFeatureItem(
                  Icons.hd_outlined,
                  'HD Video Conferencing',
                  'Crystal clear 1080p video calls',
                  _richIndigo,
                  isDark,
                ),
                const SizedBox(height: 20),
                _buildFeatureItem(
                  Icons.spatial_audio_off_rounded,
                  'Spatial Audio',
                  'Noise-cancelling immersive audio',
                  _electricBlue,
                  isDark,
                ),
                const SizedBox(height: 20),
                _buildFeatureItem(
                  Icons.closed_caption_rounded,
                  'Live Captions',
                  'Real-time multi-language transcription',
                  _emeraldGreen,
                  isDark,
                ),

                const Spacer(),

                // ── Bottom trust badge ──
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.3)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'End-to-end encrypted  •  SOC 2 Compliant',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.3)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withValues(alpha: isDark ? 0.12 : 0.09),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.2 : 0.3),
              width: 1,
            ),
          ),
          child: Icon(icon, size: 22, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.9)
                      : const Color(0xFF1E293B),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : const Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGradientOrbs(Size size, bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -60,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _richIndigo.withValues(alpha: isDark ? 0.3 : 0.22),
                  _richIndigo.withValues(alpha: isDark ? 0.05 : 0.04),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _neonPurple.withValues(alpha: isDark ? 0.2 : 0.18),
                  _neonPurple.withValues(alpha: isDark ? 0.03 : 0.03),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.4,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _electricBlue.withValues(alpha: isDark ? 0.15 : 0.16),
                  _electricBlue.withValues(alpha: isDark ? 0.02 : 0.03),
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
}

/// ── Subtle dot-grid painter for the sidebar ──
class _SidebarGridPainter extends CustomPainter {
  final bool isDark;
  const _SidebarGridPainter({this.isDark = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.025)
          : const Color(0xFF0F172A).withValues(alpha: 0.035)
      ..strokeWidth = 1;

    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SidebarGridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
