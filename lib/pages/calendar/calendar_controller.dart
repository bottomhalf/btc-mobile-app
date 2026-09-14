import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:conference/models/api_response.dart';
import 'package:conference/models/quick_meetings.dart';
import 'package:conference/models/scheduled_meeting.dart';
import 'package:conference/services/http_service.dart';

class CalendarController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rx<DateTime> currentMonth = DateTime.now().obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isMonthExpanded = false.obs;

  final RxList<DateTime> agendaDates = <DateTime>[].obs;

  // Scheduled meetings loaded from the API
  final RxList<ScheduledMeeting> scheduledMeetings = <ScheduledMeeting>[].obs;
  final RxBool isLoadingMeetings = false.obs;
  final Rxn<String> meetingsError = Rxn<String>();

  // Events map: Key is "YYYY-MM-DD" -> List of Event Maps
  final RxMap<String, List<Map<String, String>>> events = <String, List<Map<String, String>>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _generateAgendaDates();
    _loadMockEvents(); // Fallback / offline mock events
    fetchScheduledMeetings();
  }

  void _generateAgendaDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates = <DateTime>[];
    for (int i = -14; i <= 45; i++) {
      dates.add(today.add(Duration(days: i)));
    }
    agendaDates.assignAll(dates);
  }

  /// Fetches all scheduled meetings for the organizer from the API:
  /// `https://www.confeet.com/api/meeting/getAllScheduleMeetingByOrganizer`
  Future<void> fetchScheduledMeetings() async {
    isLoadingMeetings.value = true;
    meetingsError.value = null;

    try {
      final response = await HttpService.instance.get('meeting/getAllScheduleMeetingByOrganizer');

      if (response != null && response is ApiResponse && response.responseBody != null) {
        bindScheduledMeetings(response.responseBody);
      } else if (response != null && response is List) {
        bindScheduledMeetings(response);
      } else if (response != null && response is Map<String, dynamic> && response['responseBody'] != null) {
        bindScheduledMeetings(response['responseBody']);
      }
    } catch (e) {
      debugPrint('[CalendarController] Error fetching scheduled meetings: $e');
      meetingsError.value = e.toString();
      // Keep existing events/fallback on error
    } finally {
      isLoadingMeetings.value = false;
    }
  }

  /// Binds the API response list of scheduled meetings into typed models and calendar events.
  void bindScheduledMeetings(dynamic responseBody) {
    if (responseBody == null) return;
    final List<ScheduledMeeting> parsedMeetings = [];

    if (responseBody is List) {
      for (final item in responseBody) {
        if (item is Map) {
          parsedMeetings.add(ScheduledMeeting.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } else if (responseBody is Map) {
      if (responseBody.containsKey('meetingDetailId') || responseBody.containsKey('meetingId')) {
        parsedMeetings.add(ScheduledMeeting.fromJson(Map<String, dynamic>.from(responseBody)));
      }
    }

    if (parsedMeetings.isEmpty) return;

    scheduledMeetings.assignAll(parsedMeetings);

    // Expand agendaDates so that all meetings are scrollable
    _adjustAgendaDatesForMeetings(parsedMeetings);

    // Group and populate the events map by date
    _populateEventsFromScheduledMeetings(parsedMeetings);
  }

  /// Expands and normalizes agendaDates to contiguously cover the meeting range and today
  void _adjustAgendaDatesForMeetings(List<ScheduledMeeting> meetings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime earliest = today.subtract(const Duration(days: 14));
    DateTime latest = today.add(const Duration(days: 45));

    for (final m in meetings) {
      if (m.startDate != null) {
        final d = DateTime(m.startDate!.year, m.startDate!.month, m.startDate!.day);
        if (d.isBefore(earliest)) earliest = d;
        if (d.isAfter(latest)) latest = d;
      }
      if (m.endDate != null) {
        final d = DateTime(m.endDate!.year, m.endDate!.month, m.endDate!.day);
        if (d.isAfter(latest)) latest = d;
      }
    }

    final dates = <DateTime>[];
    DateTime current = earliest;
    while (!current.isAfter(latest)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    agendaDates.assignAll(dates);
  }

  /// Populates the `events` map by date from the given list of scheduled meetings.
  void _populateEventsFromScheduledMeetings(List<ScheduledMeeting> meetings) {
    final Map<String, List<Map<String, String>>> newEvents = {};

    for (final meeting in meetings) {
      if (meeting.startDate == null) continue;

      final startDay = DateTime(
        meeting.startDate!.year,
        meeting.startDate!.month,
        meeting.startDate!.day,
      );

      if (meeting.repeatType == 0) {
        // Non-repeating meeting
        final key = formatDateKey(startDay);
        final list = newEvents.putIfAbsent(key, () => []);
        list.add(meeting.toEventMap(occurrenceDate: startDay));
      } else {
        // Recurring meeting: populate across applicable dates in agendaDates
        for (final date in agendaDates) {
          if (date.isBefore(startDay)) continue;

          bool occurs = false;
          switch (meeting.repeatType) {
            case 1: // Daily
              occurs = true;
              break;
            case 2: // Weekly
              occurs = (date.weekday == startDay.weekday);
              break;
            case 3: // Monthly
              occurs = (date.day == startDay.day);
              break;
            default:
              occurs = (date.year == startDay.year && date.month == startDay.month && date.day == startDay.day);
          }

          if (occurs) {
            final key = formatDateKey(date);
            final list = newEvents.putIfAbsent(key, () => []);
            list.add(meeting.toEventMap(occurrenceDate: date));
          }
        }
      }
    }

    events.assignAll(newEvents);
  }

  void toggleMonthView() {
    isMonthExpanded.toggle();
  }

  void jumpToToday() {
    final now = DateTime.now();
    selectedDate.value = now;
    currentMonth.value = DateTime(now.year, now.month, 1);
  }

  void nextWeek() {
    selectedDate.value = selectedDate.value.add(const Duration(days: 7));
    currentMonth.value = DateTime(selectedDate.value.year, selectedDate.value.month, 1);
  }

  void prevWeek() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 7));
    currentMonth.value = DateTime(selectedDate.value.year, selectedDate.value.month, 1);
  }

  /// Calculates the 7 days of the week for the currently selected date (starting Sunday).
  List<DateTime> getDaysInCurrentWeek() {
    final date = selectedDate.value;
    final daysFromSunday = date.weekday % 7;
    final sunday = DateTime(date.year, date.month, date.day).subtract(Duration(days: daysFromSunday));
    return List.generate(7, (i) => sunday.add(Duration(days: i)));
  }

  void _loadMockEvents() {
    final now = DateTime.now();

    final keyToday = formatDateKey(now);
    final keyTomorrow = formatDateKey(now.add(const Duration(days: 1)));
    final keyNextWeek = formatDateKey(now.add(const Duration(days: 3)));

    events.value = {
      keyToday: [
        {
          'title': 'Daily Standup Meeting',
          'time': '10:00 AM',
          'duration': '30 mins',
          'timeRange': '10:00 – 10:30',
          'type': 'meeting',
          'organizer': 'Md IstiyaQ',
          'platform': 'Confeet Meeting',
          'meetingId': 'daily-standup-101',
          'agenda': 'Daily team sync and status review.',
          'repeatLabel': 'Daily',
        },
        {
          'title': 'Vite Refactor Review',
          'time': '11:00 AM',
          'duration': '1 hour',
          'timeRange': '11:00 – 12:00',
          'type': 'review',
          'organizer': 'Vivek Kumar',
          'platform': 'Confeet Meeting',
          'meetingId': 'vite-review-202',
          'agenda': 'Code review for Vite bundling migration.',
        },
        {
          'title': 'Design & Architecture Sync',
          'time': '12:00 PM',
          'duration': '1 hour',
          'timeRange': '12:00 – 13:00',
          'type': 'meeting',
          'organizer': 'Design Team',
          'platform': 'Confeet Meeting',
          'meetingId': 'design-sync-303',
        },
        {
          'title': 'Client Progress Demo',
          'time': '01:05 PM',
          'duration': '55 mins',
          'timeRange': '13:05 – 14:00',
          'type': 'demo',
          'organizer': 'Md IstiyaQ',
          'platform': 'Confeet Meeting',
          'meetingId': 'client-demo-404',
        },
      ],
      keyTomorrow: [
        {
          'title': 'Bottomhalf Internal Sync',
          'time': '11:00 AM',
          'duration': '45 mins',
          'timeRange': '11:00 – 11:45',
          'type': 'meeting',
          'organizer': 'Md IstiyaQ',
          'platform': 'Confeet Meeting',
          'meetingId': 'internal-sync-505',
        },
      ],
      keyNextWeek: [
        {
          'title': 'Client Demo - Phase 1',
          'time': '04:00 PM',
          'duration': '1 hour',
          'timeRange': '16:00 – 17:00',
          'type': 'demo',
          'organizer': 'Md IstiyaQ',
          'platform': 'Confeet Meeting',
          'meetingId': 'client-demo-606',
        },
      ],
    };
  }

  String formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void addEventFromMeeting(QuickMeetings meeting) {
    final scheduled = ScheduledMeeting.fromQuickMeetings(meeting);
    scheduledMeetings.add(scheduled);

    if (meeting.startDate == null) return;
    final dateOnly = DateTime(meeting.startDate!.year, meeting.startDate!.month, meeting.startDate!.day);

    if (agendaDates.isEmpty || dateOnly.isBefore(agendaDates.first) || dateOnly.isAfter(agendaDates.last)) {
      _adjustAgendaDatesForMeetings(scheduledMeetings);
    }

    if (meeting.repeatType == 0) {
      final key = formatDateKey(dateOnly);
      final currentList = List<Map<String, String>>.from(events[key] ?? []);
      currentList.add(scheduled.toEventMap(occurrenceDate: dateOnly));
      events[key] = currentList;
    } else {
      _populateEventsFromScheduledMeetings(scheduledMeetings);
    }
  }

  List<Map<String, String>> getEventsForDate(DateTime date) {
    final key = formatDateKey(date);
    return events[key] ?? [];
  }

  List<Map<String, String>> getEventsForSelectedDate() {
    return getEventsForDate(selectedDate.value);
  }

  bool hasEvents(DateTime date) {
    final key = formatDateKey(date);
    return events.containsKey(key) && (events[key]?.isNotEmpty ?? false);
  }

  void nextMonth() {
    currentMonth.value = DateTime(currentMonth.value.year, currentMonth.value.month + 1, 1);
  }

  void prevMonth() {
    currentMonth.value = DateTime(currentMonth.value.year, currentMonth.value.month - 1, 1);
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    currentMonth.value = DateTime(date.year, date.month, 1);
  }

  List<DateTime?> getDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    final days = <DateTime?>[];
    final firstWeekday = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;

    for (var i = 0; i < firstWeekday; i++) {
      days.add(null);
    }

    for (var i = 1; i <= lastDayOfMonth.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    final totalCells = (days.length / 7).ceil() * 7;
    while (days.length < totalCells) {
      days.add(null);
    }

    return days;
  }
}

/// Backward compatibility alias
typedef MeetCalendarController = CalendarController;
