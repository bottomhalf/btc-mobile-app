import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../pages/main/main_controller.dart';

/// A persistent side navigation menu for desktop viewports.
///
/// Displays the app logo, navigation items (Team, Meet, Calendar, Settings),
/// and a user profile section at the bottom. This replaces the mobile
/// bottom navigation bar when the viewport width ≥ 800px.
class DesktopSideMenu extends GetView<MainController> {
  const DesktopSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isCollapsed = controller.isSidebarCollapsed.value;
      
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        width: isCollapsed ? 72 : 200,
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          border: Border(
            right: BorderSide(
              color: AppTheme.divider(context).withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            // ── Logo / Brand header ──
            _buildBrandHeader(context, isCollapsed),

            const SizedBox(height: 8),

            // ── Navigation items ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    _buildNavItem(
                      context: context,
                      icon: Icons.groups_rounded,
                      label: 'Team',
                      index: 0,
                      isCollapsed: isCollapsed,
                    ),
                    const SizedBox(height: 4),
                    _buildNavItem(
                      context: context,
                      icon: Icons.videocam_rounded,
                      label: 'Meet',
                      index: 1,
                      isCollapsed: isCollapsed,
                    ),
                    const SizedBox(height: 4),
                    _buildNavItem(
                      context: context,
                      icon: Icons.calendar_month_rounded,
                      label: 'Calendar',
                      index: 2,
                      isCollapsed: isCollapsed,
                    ),
                    const SizedBox(height: 4),
                    _buildNavItem(
                      context: context,
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      index: 3,
                      isCollapsed: isCollapsed,
                    ),
                    const Spacer(),
                    _buildProfileSection(context, isCollapsed),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBrandHeader(BuildContext context, bool isCollapsed) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 16,
        horizontal: isCollapsed ? 0 : 16,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.divider(context).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (isCollapsed)
            IconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: AppTheme.textSecondary(context),
              ),
              onPressed: controller.toggleSidebar,
              tooltip: 'Expand menu',
            )
          else ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentPurple.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Confeet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(context),
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.menu_open_rounded,
                color: AppTheme.textSecondary(context),
                size: 20,
              ),
              onPressed: controller.toggleSidebar,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Collapse menu',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isCollapsed,
  }) {
    final isSelected = controller.currentIndex.value == index;
    final color = isSelected
        ? AppTheme.accentPurple
        : AppTheme.textSecondary(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.changePage(index),
          borderRadius: BorderRadius.circular(10),
          splashColor: AppTheme.accentPurple.withValues(alpha: 0.1),
          highlightColor: AppTheme.accentPurple.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : 12,
              vertical: 10,
            ),
            alignment: isCollapsed ? Alignment.center : null,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accentPurple.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment:
                  isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 20),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, bool isCollapsed) {
    return Container(
      padding: EdgeInsets.all(isCollapsed ? 8 : 10),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.divider(context).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment:
            isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
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
                'MI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentPurple,
                ),
              ),
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.more_horiz_rounded,
              size: 16,
              color: AppTheme.textSecondary(context),
            ),
          ],
        ],
      ),
    );
  }
}
