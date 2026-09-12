import 'package:conference/config/app_config.dart';
import 'package:flutter/material.dart';

/// Reusable avatar widget that displays a network image when available,
/// and gracefully falls back to name letter initials if the URL is null,
/// empty, or fails to load (e.g. 404 / network error).
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final double? fontSize;
  final FontWeight fontWeight;
  final Color textColor;
  final BoxBorder? border;

  const AppAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 36,
    this.backgroundColor,
    this.borderRadius,
    this.fontSize,
    this.fontWeight = FontWeight.bold,
    this.textColor = Colors.white,
    this.border,
  });

  /// Resolves relative image paths against [AppConfig.instance.imageBaseUrl].
  static String? resolveUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    try {
      final base = AppConfig.instance.imageBaseUrl;
      final cleanUrl = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
      final cleanBase = base.endsWith('/') ? base : '$base/';
      return '$cleanBase$cleanUrl';
    } catch (_) {
      return trimmed;
    }
  }

  /// Extracts 1 or 2 letter initials from a name string.
  static String getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (trimmed.length >= 2) {
      return trimmed.substring(0, 2).toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  /// Consistent pastel colors for avatars matching the design system
  static const List<Color> pastelPalette = [
    Color(0xFF4ADE80), // Green
    Color(0xFFF87171), // Salmon
    Color(0xFFFDBA74), // Peach
    Color(0xFF60A5FA), // Sky Blue
    Color(0xFFFB7185), // Coral
    Color(0xFFA78BFA), // Purple
    Color(0xFF9CA3AF), // Grey
  ];

  Color _resolveColor() {
    if (backgroundColor != null) return backgroundColor!;
    final index = name.hashCode.abs() % pastelPalette.length;
    return pastelPalette[index];
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(size / 2);
    final fallback = _buildFallback(effectiveRadius);
    final resolved = resolveUrl(imageUrl);

    if (resolved == null) {
      return fallback;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        border: border,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: Image.network(
          resolved,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // If image is not found or fails to load, fallback to name initials
            return fallback;
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            // While loading, show fallback initials
            return fallback;
          },
        ),
      ),
    );
  }

  Widget _buildFallback(BorderRadius radius) {
    final initials = getInitials(name);
    final effectiveFontSize = fontSize ?? (size * 0.38).clamp(9.0, 20.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _resolveColor(),
        borderRadius: radius,
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: textColor,
          fontWeight: fontWeight,
          fontSize: effectiveFontSize,
          height: 1.0,
        ),
      ),
    );
  }
}
