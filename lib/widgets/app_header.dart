import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../pages/main/main_controller.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final mainController = Get.isRegistered<MainController>() ? Get.find<MainController>() : null;

    if (mainController == null) {
      return _buildDefaultHeader(context);
    }

    return Obx(() {
      final index = mainController.currentIndex.value;
      
      switch (index) {
        case 1: // Meet Page
          return _buildPageHeader(
            context,
            title: 'Conference',
            subtitle: 'Start or join collaboration meetings',
            icon: Icons.videocam_rounded,
          );
        case 2: // Calendar Page
          return _buildPageHeader(
            context,
            title: 'Calendar',
            subtitle: 'Track your upcoming events and schedules',
            icon: Icons.calendar_month_rounded,
          );
        case 3: // Settings Page
          return _buildPageHeader(
            context,
            title: 'Settings',
            subtitle: 'Configure your preferences and account',
            icon: Icons.settings_rounded,
          );
        default: // Index 0 (Team page)
          return _buildDefaultHeader(context);
      }
    });
  }

  Widget _buildPageHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final user = UserModel.instance;
    final initials = user.firstName.isNotEmpty
        ? (user.firstName[0] + (user.lastName.isNotEmpty ? user.lastName[0] : '')).toUpperCase()
        : 'U';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context).withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.divider(context).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  // Icon badge
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title and Subtitle Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Notification Bell button
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: AppTheme.textSecondary(context),
                      size: 22,
                    ),
                    onPressed: () => Get.toNamed('/notifications'),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 16),

                  // Profile Avatar Button
                  GestureDetector(
                    onTap: () => Get.toNamed('/profile'),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accentPurple.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentPurple,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultHeader(BuildContext context) {
    final user = UserModel.instance;
    final initials = user.firstName.isNotEmpty
        ? (user.firstName[0] + (user.lastName.isNotEmpty ? user.lastName[0] : '')).toUpperCase()
        : 'U';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context).withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.divider(context).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // ── Profile Avatar ──
                  GestureDetector(
                    onTap: () => Get.toNamed('/profile'),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accentPurple.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentPurple,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // ── Search Bar ──
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/search'),
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.cardAlt(context),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppTheme.divider(context).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: AppTheme.textSecondary(context),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Search',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary(context).withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // ── Action / Notifications ──
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: AppTheme.textSecondary(context),
                      size: 24,
                    ),
                    onPressed: () => Get.toNamed('/notifications'),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
