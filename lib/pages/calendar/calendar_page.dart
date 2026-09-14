import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../services/meeting_service.dart';
import '../../theme/app_theme.dart';
import 'calendar_controller.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final CalendarController controller;
  late final ScrollController _agendaScrollController;
  late final ScrollController _stripScrollController;

  bool _isProgrammaticScroll = false;
  double _lastScrollOffset = 0.0;
  bool _showFirstLayer = true;

  // Sizing constants for date strip & agenda layout
  static const double _stripItemWidth = 50.0;
  static const double _headerHeight = 44.0;
  static const double _emptySectionHeight = 54.0;
  static const double _cardHeightWithMargin = 108.0;
  static const double _dateSectionSpacing = 16.0;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CalendarController>()
        ? Get.find<CalendarController>()
        : Get.put(CalendarController());

    _agendaScrollController = ScrollController();
    _stripScrollController = ScrollController();

    _agendaScrollController.addListener(_onAgendaScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate(controller.selectedDate.value, animate: false);
    });
  }

  @override
  void dispose() {
    _agendaScrollController.removeListener(_onAgendaScroll);
    _agendaScrollController.dispose();
    _stripScrollController.dispose();
    super.dispose();
  }

  // ─── Scroll Synchronization Handlers ───

  /// Calculates the vertical height of a single date section in the agenda.
  double _getSectionHeight(DateTime date) {
    final eventCount = controller.getEventsForDate(date).length;
    final cardsHeight = eventCount == 0 ? _emptySectionHeight : (eventCount * _cardHeightWithMargin);
    return _headerHeight + cardsHeight + _dateSectionSpacing;
  }

  /// Returns the vertical scroll offset where the given [date] section starts.
  double _getOffsetForDate(DateTime date) {
    double offset = 0.0;
    for (final d in controller.agendaDates) {
      if (_isSameDay(d, date)) break;
      offset += _getSectionHeight(d);
    }
    return offset;
  }

  /// Determines which date is currently at the top of the vertical agenda scroll offset.
  DateTime _getDateForOffset(double offset) {
    if (controller.agendaDates.isEmpty) return DateTime.now();
    if (offset <= 0) return controller.agendaDates.first;

    double currentOffset = 0.0;
    for (final d in controller.agendaDates) {
      final height = _getSectionHeight(d);
      if (offset < currentOffset + height) {
        return d;
      }
      currentOffset += height;
    }
    return controller.agendaDates.last;
  }

  /// Listener for vertical agenda scrolling: updates active date & centers horizontal strip.
  void _onAgendaScroll() {
    if (_isProgrammaticScroll) return;
    if (!_agendaScrollController.hasClients) return;

    final offset = _agendaScrollController.offset;

    // Handle hiding 1st layer on scroll up (cards moving up), showing on scroll down
    final delta = offset - _lastScrollOffset;
    if (offset <= 10) {
      if (!_showFirstLayer) {
        setState(() {
          _showFirstLayer = true;
        });
      }
    } else if (delta > 6 && offset > 30) {
      if (_showFirstLayer) {
        setState(() {
          _showFirstLayer = false;
        });
      }
    } else if (delta < -6) {
      if (!_showFirstLayer) {
        setState(() {
          _showFirstLayer = true;
        });
      }
    }
    _lastScrollOffset = offset;

    final activeDate = _getDateForOffset(offset);

    if (!_isSameDay(activeDate, controller.selectedDate.value)) {
      controller.selectedDate.value = activeDate;
      if (activeDate.month != controller.currentMonth.value.month ||
          activeDate.year != controller.currentMonth.value.year) {
        controller.currentMonth.value = DateTime(activeDate.year, activeDate.month, 1);
      }
      _scrollStripToDate(activeDate);
    }
  }

  /// Centers the given [date] in the horizontal date strip.
  void _scrollStripToDate(DateTime date, {bool animate = true}) {
    if (!_stripScrollController.hasClients) return;
    final index = controller.agendaDates.indexWhere((d) => _isSameDay(d, date));
    if (index == -1) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset = (index * _stripItemWidth) + (_stripItemWidth / 2) - (screenWidth / 2);
    final clampedOffset = targetOffset.clamp(
      0.0,
      _stripScrollController.position.maxScrollExtent,
    );

    if (animate) {
      _stripScrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    } else {
      _stripScrollController.jumpTo(clampedOffset);
    }
  }

  /// Smoothly scrolls the vertical agenda to [date] and centers it in the horizontal strip.
  void _scrollToDate(DateTime date, {bool animate = true}) {
    if (_isSameDay(date, DateTime.now()) && !_showFirstLayer) {
      setState(() {
        _showFirstLayer = true;
      });
    }
    controller.selectDate(date);
    _scrollStripToDate(date, animate: animate);

    if (!_agendaScrollController.hasClients) return;

    final targetOffset = _getOffsetForDate(date);
    final clampedOffset = targetOffset.clamp(
      0.0,
      _agendaScrollController.position.maxScrollExtent,
    );

    _isProgrammaticScroll = true;
    if (animate) {
      _agendaScrollController
          .animateTo(
            clampedOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
          )
          .then((_) {
            _isProgrammaticScroll = false;
          });
    } else {
      _agendaScrollController.jumpTo(clampedOffset);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isProgrammaticScroll = false;
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      backgroundColor: AppTheme.surface(context),
      appBar: canPop
          ? AppBar(
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
                'Calendar',
                style: TextStyle(
                  color: AppTheme.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.video_call_rounded, color: AppTheme.accentPurple, size: 26),
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
            )
          : null,
      floatingActionButton: FloatingActionButton(
        heroTag: 'calendar_schedule_meeting_fab',
        onPressed: () => Get.toNamed('/schedule-meeting'),
        backgroundColor: AppTheme.accentPurple,
        elevation: 4,
        tooltip: 'Schedule Meeting',
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 900) {
              return _buildDesktopLayout(context);
            }
            return _buildMobileLayout(context);
          },
        ),
      ),
    );
  }

  // ─── Mobile Layout: Sticky Teams Header + Continuous Vertical Agenda ───
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // Pinned Sticky Header: Top Month Bar + Horizontally Scrollable Date Strip + Handle
        _buildTeamsCalendarHeader(context),

        // Continuous Vertical Agenda of Meeting Cards by Date
        Expanded(
          child: _buildAgendaList(context),
        ),
      ],
    );
  }

  // ─── Desktop / Wide Screen Side-by-Side Layout ───
  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Calendar Card
          SizedBox(
            width: 360,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.divider(context).withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMonthSelectorRow(context),
                  const SizedBox(height: 16),
                  _buildWeekdayHeader(context),
                  const SizedBox(height: 8),
                  _buildCalendarGrid(context),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),

          // Right Column: Meeting List
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDesktopDateSubheader(context),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    final events = controller.getEventsForSelectedDate();
                    if (events.isEmpty) {
                      return _buildEmptyEvents(context);
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return _buildTeamsMeetingCard(context, event);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Teams-Style Calendar Header (Sticky: Month Bar + Horizontal Strip + Handle) ───
  Widget _buildTeamsCalendarHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141418) : AppTheme.card(context),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.divider(context).withValues(alpha: 0.35),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── 1st Layer: Month Title & Actions (hides on scroll up, shows on scroll down) ───
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: (_showFirstLayer || controller.isMonthExpanded.value)
                ? ClipRect(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildMonthTitleAndActions(context),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // ─── 2nd & 3rd Layers: Sticky Weekday Letters & Date Strip OR Full Month Grid ───
          Obx(() {
            if (controller.isMonthExpanded.value) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildWeekdayHeader(context),
                    const SizedBox(height: 8),
                    _buildCalendarGrid(context),
                  ],
                ),
              );
            }
            return _buildHorizontalDateStrip(context);
          }),

          // ─── Expand / Collapse Handle (Teams pill bar) ───
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.toggleMonthView,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Month Title and Top Actions ───
  Widget _buildMonthTitleAndActions(BuildContext context) {
    return Obx(() {
      final date = controller.currentMonth.value;
      final isExpanded = controller.isMonthExpanded.value;

      return Row(
        children: [
          // Month Name with Chevron dropdown
          Expanded(
            child: GestureDetector(
              onTap: controller.toggleMonthView,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      _getFullMonthName(date.month),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary(context),
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textSecondary(context),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // Schedule Meeting / Meet Now icon (Video camera icon from reference image)
          IconButton(
            icon: Icon(Icons.video_call_rounded, color: AppTheme.accentPurple, size: 26),
            onPressed: () => Get.toNamed('/schedule-meeting'),
            tooltip: 'Meet Now / Schedule Meeting',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // Jump to Today button
          IconButton(
            icon: Icon(Icons.today_rounded, color: AppTheme.textSecondary(context), size: 22),
            onPressed: () => _scrollToDate(DateTime.now()),
            tooltip: 'Jump to Today',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // Previous / Next month controls when expanded
          if (isExpanded) ...[
            IconButton(
              icon: Icon(Icons.chevron_left_rounded, color: AppTheme.textPrimary(context)),
              onPressed: controller.prevMonth,
              tooltip: 'Previous Month',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right_rounded, color: AppTheme.textPrimary(context)),
              onPressed: controller.nextMonth,
              tooltip: 'Next Month',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ],
        ],
      );
    });
  }

  // ─── Horizontally Scrollable Date Strip (Teams-style with Day Initial & Number) ───
  Widget _buildHorizontalDateStrip(BuildContext context) {
    return Obx(() {
      final dates = controller.agendaDates;
      final selected = controller.selectedDate.value;
      final today = DateTime.now();

      return SizedBox(
        height: 68,
        child: ListView.builder(
          controller: _stripScrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: dates.length,
          itemBuilder: (context, index) {
            final date = dates[index];
            final isSelected = _isSameDay(date, selected);
            final isToday = _isSameDay(date, today);
            final hasEvents = controller.hasEvents(date);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _scrollToDate(date),
              child: SizedBox(
                width: _stripItemWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Weekday initial (S, M, T, W, T, F, S)
                    Text(
                      _getWeekdayInitial(date.weekday),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.accentPurple
                            : AppTheme.textSecondary(context).withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Circular Date Badge
                    Container(
                      width: 36,
                      height: 36,
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
                              fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isToday ? AppTheme.accentPurple : AppTheme.textPrimary(context)),
                            ),
                          ),
                          if (hasEvents && !isSelected)
                            Positioned(
                              bottom: 4,
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
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ─── Continuous Vertical Agenda List ───
  Widget _buildAgendaList(BuildContext context) {
    return Obx(() {
      final dates = controller.agendaDates;
      return RefreshIndicator(
        onRefresh: controller.fetchScheduledMeetings,
        color: AppTheme.accentPurple,
        child: ListView.builder(
          controller: _agendaScrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.only(top: 12, bottom: 80), // Clearance for FAB
          itemCount: dates.length,
          itemBuilder: (context, index) {
            final date = dates[index];
            return _buildDateSection(context, date);
          },
        ),
      );
    });
  }

  // ─── Date Section in Agenda (Subheader + Meeting Cards or Empty State) ───
  Widget _buildDateSection(BuildContext context, DateTime date) {
    final events = controller.getEventsForDate(date);

    return Obx(() {
      final isSelected = _isSameDay(date, controller.selectedDate.value);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDateSectionHeader(context, date, isSelected: isSelected),
          const SizedBox(height: 8),
          if (events.isEmpty)
            _buildEmptyDateRow(context)
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: events.map((e) => _buildTeamsMeetingCard(context, e)).toList(),
              ),
            ),
          const SizedBox(height: _dateSectionSpacing),
        ],
      );
    });
  }

  // ─── Date Section Header ("Feb 6 Today" + Schedule button for active date) ───
  Widget _buildDateSectionHeader(BuildContext context, DateTime date, {required bool isSelected}) {
    final monthStr = _getMonthName(date.month);
    final relativeLabel = _getDateRelativeLabel(date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$monthStr ${date.day}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? AppTheme.accentPurple : AppTheme.textPrimary(context),
                  letterSpacing: -0.2,
                ),
              ),
              if (relativeLabel.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  relativeLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary(context).withValues(alpha: 0.75),
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),

          // Schedule Action pill button (prominent on the selected active date)
          if (isSelected)
            InkWell(
              onTap: () => Get.toNamed('/schedule-meeting'),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 16, color: AppTheme.accentPurple),
                    const SizedBox(width: 4),
                    Text(
                      'Schedule',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Clean Unobtrusive Indicator for Dates with No Meetings ───
  Widget _buildEmptyDateRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 18,
              color: AppTheme.textSecondary(context).withValues(alpha: 0.45),
            ),
            const SizedBox(width: 10),
            Text(
              'No meetings scheduled',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary(context).withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Weekday Header Row (S M T W T F S) for Expanded Month View ───
  Widget _buildWeekdayHeader(BuildContext context) {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return SizedBox(
          width: 38,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary(context).withValues(alpha: 0.65),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Full Month Calendar Grid (Shown when Expanded) ───
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

          final isSelected = _isSameDay(date, selected);
          final isToday = _isSameDay(date, today);
          final hasEvents = controller.hasEvents(date);

          return GestureDetector(
            onTap: () {
              _scrollToDate(date);
              controller.toggleMonthView();
            },
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

  // ─── Desktop Month Selector Row ───
  Widget _buildMonthSelectorRow(BuildContext context) {
    return Obx(() {
      final date = controller.currentMonth.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${_getFullMonthName(date.month)} ${date.year}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left_rounded, color: AppTheme.textPrimary(context)),
                onPressed: controller.prevMonth,
                tooltip: 'Previous Month',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.chevron_right_rounded, color: AppTheme.textPrimary(context)),
                onPressed: controller.nextMonth,
                tooltip: 'Next Month',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
              ),
            ],
          ),
        ],
      );
    });
  }

  // ─── Desktop Date Subheader ───
  Widget _buildDesktopDateSubheader(BuildContext context) {
    return Row(
      children: [
        Obx(() {
          final date = controller.selectedDate.value;
          final monthStr = _getMonthName(date.month);
          final relativeLabel = _getDateRelativeLabel(date);

          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$monthStr ${date.day}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary(context),
                  letterSpacing: -0.2,
                ),
              ),
              if (relativeLabel.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  relativeLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary(context).withValues(alpha: 0.75),
                  ),
                ),
              ],
            ],
          );
        }),
        const Spacer(),

        // Quick Schedule Pill Button
        InkWell(
          onTap: () => Get.toNamed('/schedule-meeting'),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 16, color: AppTheme.accentPurple),
                const SizedBox(width: 4),
                Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentPurple,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Microsoft Teams Style Meeting Card with Join Button ───
  Widget _buildTeamsMeetingCard(BuildContext context, Map<String, String> event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = event['type'] ?? 'meeting';
    final timeRange = event['timeRange'] ?? '${event['time'] ?? '10:00 AM'} (${event['duration'] ?? '30 mins'})';
    final platform = event['platform'] ?? 'Confeet Meeting';
    final agenda = event['agenda'] ?? '';
    final repeatLabel = event['repeatLabel'];
    final isRecurring = repeatLabel != null && repeatLabel.isNotEmpty && repeatLabel != 'Does not repeat';

    Color leftBarColor;
    switch (type) {
      case 'review':
        leftBarColor = const Color(0xFF3B82F6); // Blue
        break;
      case 'demo':
        leftBarColor = const Color(0xFFFF6B6B); // Red/Coral
        break;
      default:
        leftBarColor = AppTheme.accentPurple; // Purple
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : AppTheme.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : AppTheme.divider(context).withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left vertical indicator bar (matching Microsoft Teams)
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: leftBarColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),

          // Title, Time, Platform / Organizer, Agenda
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event['title'] ?? 'Meeting',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      timeRange,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                    if (isRecurring) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.repeat_rounded,
                        size: 14,
                        color: AppTheme.accentPurple,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        repeatLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentPurple,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.repeat_rounded,
                        size: 14,
                        color: AppTheme.textSecondary(context).withValues(alpha: 0.6),
                      ),
                    ],
                  ],
                ),
                if (agenda.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    agenda,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary(context).withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  platform,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary(context).withValues(alpha: 0.75),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Join button on the right (matching Microsoft Teams)
          _buildJoinButton(context, event),
        ],
      ),
    );
  }

  // ─── Join Button (Lavender pill button from screenshot) ───
  Widget _buildJoinButton(BuildContext context, Map<String, String> event) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleJoinMeeting(event),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF7B83EB),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B83EB).withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            'Join',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Join Meeting Handler ───
  void _handleJoinMeeting(Map<String, String> event) {
    final roomId = event['meetingId'] ?? '';
    final title = event['title'] ?? 'Meeting';
    final user = UserModel.instance;
    final participantName = user.fullName.isNotEmpty ? user.fullName : 'Participant';

    if (roomId.isNotEmpty) {
      MeetingService.instance.joinMeeting(
        roomId: roomId,
        participantName: participantName,
        meetingTitle: title,
      );
    } else {
      Get.toNamed('/schedule-meeting');
    }
  }

  // ─── Empty Events State (for desktop) ───
  Widget _buildEmptyEvents(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
              'No meetings planned for this day.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary(context),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/schedule-meeting'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Schedule Meeting'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ───
  String _getWeekdayInitial(int weekday) {
    // DateTime weekday: 1 = Monday, ..., 7 = Sunday
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    if (weekday < 1 || weekday > 7) return '';
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  String _getFullMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  String _getDateRelativeLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';

    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[date.weekday - 1];
  }
}

/// Backward compatibility alias
typedef MeetCalendarPage = CalendarPage;
