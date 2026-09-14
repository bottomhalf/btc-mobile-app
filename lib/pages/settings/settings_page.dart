import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_service.dart';
import '../../core/storage/storage.dart';
import '../../services/meeting_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, 'Preferences'),
              const SizedBox(height: 16),
              _buildThemeToggleCard(context),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Account'),
              const SizedBox(height: 16),
              _buildAccountOptions(context),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Legal & About'),
              const SizedBox(height: 16),
              _buildLegalOptions(context),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Confeet v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary(context).withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: AppTheme.accentPurple,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildThemeToggleCard(BuildContext context) {
    final themeService = ThemeService.instance;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.divider(context).withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: themeService.toggleTheme,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(
                    () => Icon(
                      themeService.isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: AppTheme.accentPurple,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          themeService.isDarkMode ? 'Dark Mode' : 'Light Mode',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Switch.adaptive(
                    value: themeService.isDarkMode,
                    onChanged: (val) => themeService.toggleTheme(),
                    activeTrackColor: AppTheme.accentPurple,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountOptions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.divider(context).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.person_outline_rounded,
            title: 'Profile',
            onTap: () => Get.toNamed('/profile'),
          ),
          Divider(
            color: AppTheme.divider(context).withValues(alpha: 0.5),
            height: 1,
            indent: 60,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.logout_rounded,
            title: 'Logout',
            textColor: Colors.orangeAccent,
            iconColor: Colors.orangeAccent,
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Log Out',
          style: TextStyle(
            color: AppTheme.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of Confeet?',
          style: TextStyle(color: AppTheme.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary(context)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await MeetingService.instance.leaveMeeting();
              } catch (_) {}
              await StorageService.instance.clearAll();
              Get.offAllNamed('/login');
            },
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalOptions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.divider(context).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => Get.toNamed('/privacy-policy'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? AppTheme.textSecondary(context),
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: textColor),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary(context).withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
