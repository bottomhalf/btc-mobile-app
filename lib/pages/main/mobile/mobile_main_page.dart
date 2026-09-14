import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/app_header.dart';
import '../../team/team_page.dart';
import '../../calendar/calendar_page.dart';
import '../../meet/meet_page.dart';
import '../../settings/settings_page.dart';
import '../main_controller.dart';

/// Mobile-optimised main page with bottom navigation bar.
///
/// This is the original MainPage UI extracted into the mobile/ subfolder.
class MobileMainPage extends GetView<MainController> {
  const MobileMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const AppHeader(),
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            TeamPage(),
            MeetPage(),
            CalendarPage(),
            SettingsPage(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF13131A) : AppTheme.card(context),
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF16161D),
                    Color(0xFF111116),
                  ],
                )
              : null,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppTheme.divider(context).withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 58,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context: context,
                    icon: Icons.groups_rounded,
                    label: 'Team',
                    index: 0,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.videocam_rounded,
                    label: 'Meet',
                    index: 1,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.calendar_month_rounded,
                    label: 'Calendar',
                    index: 2,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = controller.currentIndex.value == index;
    final color = isSelected
        ? AppTheme.accentPurple
        : (isDark ? Colors.white70 : AppTheme.textSecondary(context));

    return Expanded(
      child: InkWell(
        onTap: () => controller.changePage(index),
        splashColor: AppTheme.accentPurple.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accentPurple.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
