import 'package:get/get.dart';

class MeetCalendarController extends GetxController {
  final Rx<DateTime> currentMonth = DateTime.now().obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Mock events map: Key is "YYYY-MM-DD"
  final RxMap<String, List<Map<String, String>>> events = <String, List<Map<String, String>>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockEvents();
  }

  void _loadMockEvents() {
    final now = DateTime.now();
    
    final keyToday = _formatDateKey(now);
    final keyTomorrow = _formatDateKey(now.add(const Duration(days: 1)));
    final keyNextWeek = _formatDateKey(now.add(const Duration(days: 3)));

    events.value = {
      keyToday: [
        {
          'title': 'Daily Standup Meeting',
          'time': '10:00 AM',
          'duration': '30 mins',
          'type': 'meeting',
          'organizer': 'Md IstiyaQ',
        },
        {
          'title': 'Vite Refactor Review',
          'time': '02:30 PM',
          'duration': '1 hour',
          'type': 'review',
          'organizer': 'Vivek Kumar',
        },
      ],
      keyTomorrow: [
        {
          'title': 'Bottomhalf Internal Sync',
          'time': '11:00 AM',
          'duration': '45 mins',
          'type': 'meeting',
          'organizer': 'Md IstiyaQ',
        },
      ],
      keyNextWeek: [
        {
          'title': 'Client Demo - Phase 1',
          'time': '04:00 PM',
          'duration': '1 hour',
          'type': 'demo',
          'organizer': 'Md IstiyaQ',
        },
      ],
    };
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<Map<String, String>> getEventsForSelectedDate() {
    final key = _formatDateKey(selectedDate.value);
    return events[key] ?? [];
  }

  bool hasEvents(DateTime date) {
    final key = _formatDateKey(date);
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
