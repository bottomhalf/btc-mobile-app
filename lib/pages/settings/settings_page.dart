import 'package:conference/services/http_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/storage/storage.dart';
import '../../models/user_model.dart';
import '../../push_notification_manager/service/notification_handler_service.dart';
import '../../services/meeting_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.pageGradient(context),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Hero Brand & User Card ───
                  _buildHeroHeader(context),
                  const SizedBox(height: 28),

                  // ─── Section 1: Notifications & Alerts ───
                  _buildSectionHeader(
                    context,
                    title: 'NOTIFICATIONS & ALERTS',
                    icon: Icons.notifications_active_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationCard(context),
                  const SizedBox(height: 28),

                  // ─── Section 2: Appearance & Display ───
                  _buildSectionHeader(
                    context,
                    title: 'APPEARANCE & DISPLAY',
                    icon: Icons.palette_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildAppearanceCard(context),
                  const SizedBox(height: 28),

                  // ─── Section 3: Account & Workspace ───
                  _buildSectionHeader(
                    context,
                    title: 'ACCOUNT & WORKSPACE',
                    icon: Icons.account_circle_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildAccountCard(context),
                  const SizedBox(height: 28),

                  // ─── Section 4: Legal & Security ───
                  _buildSectionHeader(
                    context,
                    title: 'LEGAL & SECURITY',
                    icon: Icons.shield_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildLegalCard(context),
                  const SizedBox(height: 36),

                  // ─── Footer Branding ───
                  _buildFooter(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Hero Brand & Connected User Card
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeroHeader(BuildContext context) {
    final user = UserModel.instance;
    final displayName =
        user.fullName.trim().isNotEmpty ? user.fullName : 'Confeet Member';
    final email = user.email.isNotEmpty ? user.email : 'Member Account';
    final initials = user.firstName.isNotEmpty
        ? (user.firstName[0] +
                (user.lastName.isNotEmpty ? user.lastName[0] : ''))
            .toUpperCase()
        : 'C';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryIndigo,
            AppTheme.accentPurple,
            const Color(0xFF8B5CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPurple.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circles
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 80,
            bottom: -35,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Logo & Tag Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 26,
                            width: 26,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.videocam_rounded,
                                color: Color(0xFF6264A7),
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Confeet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF34D399).withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF34D399),
                            size: 13,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Online Session',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Connected User Information Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          backgroundImage: user.imageUrl.isNotEmpty
                              ? NetworkImage(user.imageUrl)
                              : null,
                          child: user.imageUrl.isEmpty
                              ? Text(
                                  initials,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.accentPurple,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'View Profile',
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: () => Get.toNamed('/profile'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Section Header Helper
  // ─────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.accentPurple,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.accentPurple,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontSize: 12,
              ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Section 1: Notifications & Alerts Card
  // ─────────────────────────────────────────────────────────────
  Widget _buildNotificationCard(BuildContext context) {
    final notificationService = NotificationHandlerService.instance;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.divider(context).withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Push Notification Toggle Tile
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Obx(
                  () => Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: notificationService.isNotificationsEnabled.value
                          ? AppTheme.accentPurple.withValues(alpha: 0.12)
                          : Colors.grey.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      notificationService.isNotificationsEnabled.value
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_rounded,
                      color: notificationService.isNotificationsEnabled.value
                          ? AppTheme.accentPurple
                          : AppTheme.textSecondary(context),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Notification Service',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Obx(
                            () => _buildStatusChip(
                              isEnabled: notificationService
                                  .isNotificationsEnabled.value,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Incoming calls, meeting alerts & chat notices',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary(context),
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => Switch.adaptive(
                    value: notificationService.isNotificationsEnabled.value,
                    activeThumbColor: AppTheme.accentPurple,
                    activeTrackColor:
                        AppTheme.accentPurple.withValues(alpha: 0.5),
                    onChanged: (val) async {
                      if (!val) {
                        // User is turning it OFF: Show confirmation dialog first!
                        final confirmed =
                            await _showDisableConfirmationDialog(context);
                        if (confirmed == true) {
                          await notificationService.setNotificationsEnabled(false);
                          if (context.mounted) {
                            _showNotificationFeedback(
                              context,
                              title: 'Notification Paused',
                              message:
                                  'Notification service has been paused successfully.',
                              isSuccess: true,
                            );
                          }
                        }
                      } else {
                        // User is turning it ON: Request permission and trigger system popup
                        final success =
                            await notificationService.setNotificationsEnabled(true);
                        if (!success && context.mounted) {
                          _showPermissionDialog(context, notificationService);
                        } else if (success && context.mounted) {
                          _showNotificationFeedback(
                            context,
                            title: 'Notifications Enabled',
                            message:
                                'Incoming video calls, meetings, and chat alerts are now active.',
                            isSuccess: true,
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Conditional Warning Banner if permission blocked in OS
          Obx(() {
            if (!notificationService.isPermissionBlocked.value) {
              return const SizedBox.shrink();
            }
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Notifications are blocked in device settings. Please grant permission to receive alerts.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFD97706),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: notificationService.openSystemSettings,
                    child: const Text(
                      'Fix',
                      style: TextStyle(
                        color: Color(0xFFD97706),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          Divider(
            color: AppTheme.divider(context).withValues(alpha: 0.5),
            height: 1,
            indent: 64,
          ),

          // OS Device Notification Settings Link
          _buildSettingsTile(
            context,
            icon: Icons.tune_rounded,
            title: 'Device Notification Settings',
            subtitle: 'Manage OS ringtones, banners and lock screen preview',
            trailing: const Icon(
              Icons.launch_rounded,
              size: 17,
              color: Color(0xFF7B83EB),
            ),
            onTap: notificationService.openSystemSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({required bool isEnabled}) {
    final color = isEnabled ? const Color(0xFF10B981) : const Color(0xFF6B7280);
    final text = isEnabled ? 'Active' : 'Disabled';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDisableConfirmationDialog(BuildContext context) {
    bool isLoading = false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return PopScope(
            canPop: !isLoading,
            child: AlertDialog(
              backgroundColor: AppTheme.card(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.notifications_off_rounded,
                      color: Color(0xFFEF4444),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Disable Notifications?',
                    style: TextStyle(
                      color: AppTheme.textPrimary(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              content: Text(
                'You will no longer receive alerts or ringtones for incoming video calls, scheduled meetings, or team chat messages. Are you sure you want to turn off notifications?',
                style: TextStyle(
                  color: AppTheme.textSecondary(context),
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.of(ctx).pop(false),
                  child: Text(
                    'Keep Enabled',
                    style: TextStyle(
                      color: isLoading
                          ? AppTheme.textSecondary(context)
                              .withValues(alpha: 0.4)
                          : AppTheme.textSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });

                          final success =
                              await _turnedOffNotification(context);

                          if (ctx.mounted) {
                            if (success) {
                              Navigator.of(ctx).pop(true);
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Turn Off',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> _turnedOffNotification(BuildContext context) async {
    try {
      final String? deviceId =
          Get.find<NotificationHandlerService>().deviceId ??
              StorageService.instance.getValue<String>('fcm_device_token');

      final Map<String, dynamic> payload = {
        'deviceId': deviceId,
        'isNotificationEnabled': true,
        'isActive': true,
      };

      debugPrint(
          "Sending notification status request to /api/auth/v2/pauseNotification: $payload");

      final response = await HttpService.instance.post(
        '/api/auth/v2/pauseNotification',
        body: payload,
      );

      debugPrint("Notification paused successfully: $response");
      return true;
    } catch (e) {
      debugPrint("Failed to update notification status on backend: $e");
      if (context.mounted) {
        _showNotificationFeedback(
          context,
          title: 'Operation Failed',
          message: 'Unable to pause notifications on server: $e',
          isSuccess: false,
        );
      }
      return false;
    }
  }

  void _showNotificationFeedback(
    BuildContext context, {
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    final color =
        isSuccess ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final icon = isSuccess
        ? Icons.notifications_active_rounded
        : Icons.notifications_off_rounded;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.card(context),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppTheme.divider(context),
            width: 1,
          ),
        ),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPrimary(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: TextStyle(
                      color: AppTheme.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionDialog(
    BuildContext context,
    NotificationHandlerService service,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_paused_rounded,
                color: Color(0xFF7B83EB),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Permission Required',
              style: TextStyle(
                color: AppTheme.textPrimary(context),
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Text(
          'Notifications are disabled in your operating system settings. Please open App Settings to allow Confeet to send you call and chat alerts.',
          style: TextStyle(
            color: AppTheme.textSecondary(context),
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Later',
              style: TextStyle(color: AppTheme.textSecondary(context)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              service.openSystemSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Section 2: Appearance & Display Card
  // ─────────────────────────────────────────────────────────────
  Widget _buildAppearanceCard(BuildContext context) {
    final themeService = ThemeService.instance;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.divider(context).withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: themeService.toggleTheme,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
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
                        'Appearance Theme',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          themeService.isDarkMode
                              ? 'Obsidian Dark (Deep Canvas)'
                              : 'Platinum Light (Clean Daylight)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary(context),
                                fontSize: 12,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Switch.adaptive(
                    value: themeService.isDarkMode,
                    onChanged: (val) => themeService.toggleTheme(),
                    activeThumbColor: AppTheme.accentPurple,
                    activeTrackColor:
                        AppTheme.accentPurple.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Section 3: Account & Workspace Card
  // ─────────────────────────────────────────────────────────────
  Widget _buildAccountCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.divider(context).withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.person_outline_rounded,
            title: 'Personal Profile',
            subtitle: 'Manage your contact details, designation & avatar',
            onTap: () => Get.toNamed('/profile'),
          ),
          Divider(
            color: AppTheme.divider(context).withValues(alpha: 0.5),
            height: 1,
            indent: 64,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.lock_reset_rounded,
            title: 'Reset Password',
            subtitle: 'Account managed via organization directory',
            onTap: () => _showSecurityInfo(context),
          ),
          Divider(
            color: AppTheme.divider(context).withValues(alpha: 0.5),
            height: 1,
            indent: 64,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.logout_rounded,
            title: 'Log Out',
            subtitle: 'Safely end your session on this device',
            textColor: const Color(0xFFEF4444),
            iconColor: const Color(0xFFEF4444),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  void _showSecurityInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: Color(0xFF06B6D4),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Reset Password',
              style: TextStyle(
                color: AppTheme.textPrimary(context),
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Text(
          'Confeet enterprise accounts are managed by your organization or workspace administrator. To update your password or credentials, please contact your workspace administrator.',
          style: TextStyle(
            color: AppTheme.textSecondary(context),
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out',
          style: TextStyle(
            color: AppTheme.textPrimary(context),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of Confeet? Your active meeting and messaging session will be terminated.',
          style: TextStyle(
            color: AppTheme.textSecondary(context),
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary(context)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Section 4: Legal & Security Card
  // ─────────────────────────────────────────────────────────────
  Widget _buildLegalCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.divider(context).withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our end-to-end encryption & privacy standards',
            onTap: () => Get.toNamed('/privacy-policy'),
          ),
          Divider(
            color: AppTheme.divider(context).withValues(alpha: 0.5),
            height: 1,
            indent: 64,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.verified_user_outlined,
            title: 'Security & Encryption',
            subtitle: 'TLS 1.3 in-transit and WebRTC media security',
            onTap: () => _showEncryptionDetails(context),
          ),
        ],
      ),
    );
  }

  void _showEncryptionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Enterprise Security',
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '• All signaling traffic is encrypted using TLS 1.3 / HTTPS.\n'
              '• Audio and video streaming is transported via SRTP WebRTC encryption.\n'
              '• Push notifications use Firebase Cloud Messaging authenticated tokens.\n'
              '• Auth tokens are safely stored in device secure hardware storage.',
              style: TextStyle(
                color: AppTheme.textSecondary(context),
                fontSize: 13.5,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Settings Tile Helper
  // ─────────────────────────────────────────────────────────────
  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? textColor,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.accentPurple)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppTheme.accentPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: textColor ?? AppTheme.textPrimary(context),
                            fontWeight: FontWeight.w600,
                            fontSize: 14.5,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary(context),
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color:
                        AppTheme.textSecondary(context).withValues(alpha: 0.6),
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Footer Branding
  // ─────────────────────────────────────────────────────────────
  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.card(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.divider(context).withValues(alpha: 0.5),
              ),
            ),
            child: Image.asset(
              'assets/images/logo.png',
              height: 22,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.videocam_rounded,
                color: AppTheme.accentPurple,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Confeet Unified Communications',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Version 1.0.0 • Build 2026.1',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary(context).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
