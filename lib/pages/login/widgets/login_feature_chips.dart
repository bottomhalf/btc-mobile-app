import 'package:flutter/material.dart';

/// Horizontal scrollable feature chips showcasing AI capabilities
class LoginFeatureChips extends StatelessWidget {
  const LoginFeatureChips({super.key});

  static const Color _richIndigo = Color(0xFF4F46E5);
  static const Color _electricBlue = Color(0xFF06B6D4);
  static const Color _neonPurple = Color(0xFF8B5CF6);
  static const Color _emeraldGreen = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final features = [
      _Feature(Icons.auto_awesome, 'AI Notes', _neonPurple),
      _Feature(Icons.hd_outlined, 'HD Video', _richIndigo),
      _Feature(Icons.spatial_audio_off_rounded, 'Crystal Audio', _electricBlue),
      _Feature(Icons.closed_caption_rounded, 'Live Captions', _emeraldGreen),
      _Feature(Icons.screen_share_rounded, 'Screen Share', _richIndigo),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: features.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _buildChip(features[i]),
      ),
    );
  }

  Widget _buildChip(_Feature f) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: f.color.withValues(alpha: 0.12),
        border: Border.all(
          color: f.color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(f.icon, size: 16, color: f.color),
          const SizedBox(width: 6),
          Text(
            f.label,
            style: TextStyle(
              color: f.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String label;
  final Color color;
  const _Feature(this.icon, this.label, this.color);
}
