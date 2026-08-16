import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import 'meet_calendar_controller.dart';

class MeetCalendarPage extends GetView<MeetCalendarController> {
  const MeetCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface(context),
      appBar: AppBar(
        backgroundColor: AppTheme.card(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary(context),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Meeting Calendar',
          style: TextStyle(
            color: AppTheme.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: AppTheme.accentPurple),
            onPressed: () => Get.toNamed('/schedule-meeting'),
            tooltip: 'Schedule Meeting',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: AppTheme.divider(context).withValues(alpha: 0.5),
          ),
        ),
      ),
      body: Column(
        children: [
          // ─── Monthly Calendar Section ───
          Container(
            color: AppTheme.card(context),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              children: [
                _buildMonthSelector(context),
                const SizedBox(height: 16),
                _buildWeekdayHeader(context),
                const SizedBox(height: 8),
                _buildCalendarGrid(context),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── Events Header ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Obx(() {
                  final date = controller.selectedDate.value;
                  return Text(
                    'Events for ${date.day} ${_getMonthName(date.month)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary(context),
                    ),
                  );
                }),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ─── Events List ───
          Expanded(
            child: Obx(() {
              final events = controller.getEventsForSelectedDate();
              if (events.isEmpty) {
                return _buildEmptyEvents(context);
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildEventCard(context, event);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    return Obx(() {
      final date = controller.currentMonth.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_getMonthName(date.month)} ${date.year}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left_rounded, color: AppTheme.textPrimary(context)),
                onPressed: controller.prevMonth,
              ),
              IconButton(
                icon: Icon(Icons.chevron_right_rounded, color: AppTheme.textPrimary(context)),
                onPressed: controller.nextMonth,
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildWeekdayHeader(BuildContext context) {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return SizedBox(
          width: 36,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary(context).withValues(alpha: 0.6),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    return Obx(() {
      final month = controller.currentMonth.value;
      final days = controller.getDaysInMonth(month);
      final selected = controller.selectedDate.value;
      final today = DateTime.now();

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: days.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final date = days[index];
          if (date == null) {
            return const SizedBox();
          }

          final isSelected = date.year == selected.year &&
              date.month == selected.month &&
              date.day == selected.day;

          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          final hasEvents = controller.hasEvents(date);

          return GestureDetector(
            onTap: () => controller.selectDate(date),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppTheme.accentPurple
                    : (isToday ? AppTheme.accentPurple.withValues(alpha: 0.15) : Colors.transparent),
                border: isToday && !isSelected
                    ? Border.all(color: AppTheme.accentPurple, width: 1.5)
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : (isToday ? AppTheme.accentPurple : AppTheme.textPrimary(context)),
                    ),
                  ),
                  if (hasEvents && !isSelected)
                    Positioned(
                      bottom: 6,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accentPurple,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildEmptyEvents(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: AppTheme.textSecondary(context).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No events scheduled',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click "+" to schedule a new meeting.',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, String> event) {
    final type = event['type'] ?? 'meeting';
    Color leftBarColor;
    Color badgeColor;

    switch (type) {
      case 'review':
        leftBarColor = const Color(0xFF2D7FF9);
        badgeColor = const Color(0xFF2D7FF9).withValues(alpha: 0.15);
        break;
      case 'demo':
        leftBarColor = const Color(0xFFFF6B6B);
        badgeColor = const Color(0xFFFF6B6B).withValues(alpha: 0.15);
        break;
      default:
        leftBarColor = AppTheme.accentPurple;
        badgeColor = AppTheme.accentPurple.withValues(alpha: 0.15);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: leftBarColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? 'Meeting',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textSecondary(context)),
                    const SizedBox(width: 6),
                    Text(
                      '${event['time']} (${event['duration']})',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.textSecondary(context)),
                    const SizedBox(width: 6),
                    Text(
                      'By: ${event['organizer']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              type.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: leftBarColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }
}
