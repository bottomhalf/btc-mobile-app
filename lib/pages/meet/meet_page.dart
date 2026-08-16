import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../services/meeting_service.dart';
import '../../theme/app_theme.dart';
import '../main/main_controller.dart';
import 'meet_controller.dart';
import 'widgets/quick_action_tile.dart';
import 'widgets/recent_meetings_grid.dart';

class MeetPage extends GetView<MeetController> {
  const MeetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isInMeeting = MeetingService.instance.isInMeeting.value;

      return PopScope(
        canPop: !isInMeeting,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          final bool? shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.card(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Exit Application?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              content: Text(
                'Currently a meeting is ongoing. If you exit, you will automatically be disconnected from the meeting.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.accentPurple),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Exit',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          );

          if (shouldPop == true) {
            await MeetingService.instance.leaveMeeting();
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? const [Color(0xFF131224), Color(0xFF1B1A2E)]
                    : const [Color(0xFFF3F5FA), Color(0xFFE8ECF5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                // ── Background gradient orbs ──
                _backgroundOrbs(),

                // ── Main content ──
                SafeArea(
                  child: RefreshIndicator(
                    onRefresh: controller.fetchRecentMeetings,
                    color: AppTheme.accentPurple,
                    backgroundColor: AppTheme.card(context),
                    child: CustomScrollView(
                      slivers: [
                        // ─── Welcome Section ───
                        SliverToBoxAdapter(child: _buildWelcome(context)),

                        // ─── Dashboard Banner ───
                        SliverToBoxAdapter(child: _buildDashboardBanner(context)),

                        // ─── Quick Actions ───
                        SliverToBoxAdapter(child: _buildQuickActions(context)),

                        // ─── Recent Meetings Header ───
                        SliverToBoxAdapter(child: _buildRecentHeader(context)),

                        // ─── Recent Meetings Grid (from API) ───
                        const SliverToBoxAdapter(child: RecentMeetingsGrid()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _backgroundOrbs() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accentPurple.withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryIndigo.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildWelcome(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back 👋',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 6),
          Text(
            'Start or join a meeting to collaborate with your team.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        children: [
          QuickActionTile(
            icon: Icons.video_call_rounded,
            label: 'New\nMeeting',
            gradient: AppTheme.accentGradient,
            onTap: () {
              Get.toNamed('/schedule-meeting');
            },
          ),
          const SizedBox(width: 14),
          QuickActionTile(
            icon: Icons.calendar_today_rounded,
            label: 'Schedule',
            gradient: const LinearGradient(
              colors: [Color(0xFF2D7FF9), Color(0xFF18BFFF)],
            ),
            onTap: () {
              if (Get.isRegistered<MainController>()) {
                Get.find<MainController>().changePage(2);
              }
            },
          ),
          const SizedBox(width: 14),
          QuickActionTile(
            icon: Icons.screen_share_rounded,
            label: 'Share\nScreen',
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Row(
        children: [
          Text(
            'Recent Meetings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text(
              'See all',
              style: TextStyle(
                color: AppTheme.accentPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            AppTheme.accentPurple,
            AppTheme.primaryIndigo,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPurple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative Background Circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'PRO EDITION',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start Instant Meetings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Connect with your team instantly anywhere, anytime.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.bolt_rounded,
                            color: AppTheme.accentPurple,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
