import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:conference/theme/app_theme.dart';
import 'package:conference/pages/calendar/calendar_controller.dart';
import 'package:conference/pages/calendar/calendar_page.dart';
import 'package:conference/models/quick_meetings.dart';
import 'package:conference/models/scheduled_meeting.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  test('CalendarController loads mock events and handles date manipulation', () {
    final controller = Get.put(CalendarController());

    expect(controller.events.isNotEmpty, true);
    final today = DateTime.now();
    expect(controller.hasEvents(today), true);

    final currentMonth = controller.currentMonth.value;
    controller.nextMonth();
    expect(controller.currentMonth.value.month, (currentMonth.month % 12) + 1);

    controller.prevMonth();
    expect(controller.currentMonth.value.month, currentMonth.month);

    final testDate = DateTime(2026, 9, 14);
    controller.selectDate(testDate);
    expect(controller.selectedDate.value, testDate);
  });

  test('CalendarController.addEventFromMeeting adds event to events map', () {
    final controller = Get.put(CalendarController());
    final meetingDate = DateTime(2026, 9, 20, 14, 30);

    final meeting = QuickMeetings(
      meetingId: 'meet-123',
      meetingDetailId: 1,
      title: 'Sprint Planning',
      agenda: 'Sprint planning session',
      organizerName: 'Test Host',
      startDate: meetingDate,
      endDate: meetingDate.add(const Duration(hours: 1)),
      durationInSecond: 3600,
      meetingPassword: 'pass',
      isAllDay: false,
    );

    controller.addEventFromMeeting(meeting);

    controller.selectDate(meetingDate);
    final events = controller.getEventsForSelectedDate();
    expect(events.any((e) => e['title'] == 'Sprint Planning'), true);
    expect(events.any((e) => e['organizer'] == 'Test Host'), true);
  });

  testWidgets('CalendarPage renders calendar, events, and schedule meeting buttons', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0; // 540 x 1200 logical pixels
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Get.put(CalendarController());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const CalendarPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify calendar grid and month name are rendered
    expect(find.text('S'), findsWidgets); // Weekday header
    expect(find.text('M'), findsWidgets);

    // Verify date subheader with Today label
    expect(find.text('Today'), findsOneWidget);

    // Verify schedule action button in events header
    expect(find.text('Schedule'), findsOneWidget);

    // Verify FloatingActionButton is rendered
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Verify events are shown
    expect(find.text('Daily Standup Meeting'), findsOneWidget);

    // Verify Teams-style Join buttons are rendered
    expect(find.text('Join'), findsWidgets);
  });

  testWidgets('CalendarPage renders desktop layout without errors on wide screens', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Get.put(CalendarController());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const CalendarPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify both columns are present
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Daily Standup Meeting'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  test('CalendarController maintains agendaDates and expands dynamically', () {
    final controller = Get.put(CalendarController());
    expect(controller.agendaDates.isNotEmpty, true);
    expect(controller.agendaDates.length >= 60, true);

    // Add meeting far in the future
    final futureDate = DateTime.now().add(const Duration(days: 90));
    final meeting = QuickMeetings(
      meetingId: 'meet-far-future',
      meetingDetailId: 2,
      title: 'Quarterly Review',
      agenda: 'Quarterly sync',
      organizerName: 'Director',
      startDate: futureDate,
      durationInSecond: 1800,
      meetingPassword: '',
      isAllDay: false,
    );
    controller.addEventFromMeeting(meeting);

    expect(
      controller.agendaDates.any((d) => d.year == futureDate.year && d.month == futureDate.month && d.day == futureDate.day),
      true,
    );
    // Verify agendaDates remains sorted
    for (int i = 0; i < controller.agendaDates.length - 1; i++) {
      expect(controller.agendaDates[i].isBefore(controller.agendaDates[i + 1]), true);
    }
  });

  testWidgets('CalendarPage date strip can be tapped to sync selected date', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = Get.put(CalendarController());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const CalendarPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify horizontal strip is rendered with day numbers
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    // Tap tomorrow's date badge in the horizontal strip
    final tomorrowDayFinder = find.widgetWithText(GestureDetector, '${tomorrow.day}');
    if (tomorrowDayFinder.evaluate().isNotEmpty) {
      await tester.tap(tomorrowDayFinder.first);
      await tester.pumpAndSettle();
      expect(controller.selectedDate.value.day, tomorrow.day);
    }

    // Tap Jump to Today
    final jumpTodayFinder = find.byTooltip('Jump to Today');
    expect(jumpTodayFinder, findsOneWidget);
    await tester.tap(jumpTodayFinder);
    await tester.pumpAndSettle();
    expect(controller.selectedDate.value.day, today.day);

    // Verify month view can be expanded and collapsed
    final expandHandle = find.byType(GestureDetector);
    expect(expandHandle, findsWidgets);
    controller.toggleMonthView();
    await tester.pumpAndSettle();
    expect(controller.isMonthExpanded.value, true);

    controller.toggleMonthView();
    await tester.pumpAndSettle();
    expect(controller.isMonthExpanded.value, false);
  });

  test('ScheduledMeeting model parses API response correctly', () {
    final apiItem = {
      'meetingDetailId': 18,
      'agenda': '<b>Daily Scrum </b>meeting for the development team to review yesterday work, today plan, and any impediments affecting project progress.',
      'allDay': false,
      'conversationId': '0bd7a022651dcb56b849e606',
      'durationInSecond': 3600,
      'endDate': '2026-07-21T05:00:00',
      'endTime': null,
      'hasQuickMeeting': false,
      'meetingId': 'btc-Z-C9K4GoPNzzRQv2RR73Nw3-uwXSqHtP5OgbpH6KOag-e6IfEk32UtCfViNe2cyfzHTW9v1sdPDmB_UuahRRx8yCA_QsGUCxBoN3DqjNcwsi',
      'meetingPassword': 'wr7eBa',
      'organizedBy': 37,
      'organizerName': null,
      'participantCount': 0,
      'participants': '[\n    "BOT00012",\n    "BOT00035",\n    "BOT00037"\n]',
      'participantsDetail': null,
      'participantsId': null,
      'repeatType': 1,
      'startDate': '2026-07-21T05:00:00',
      'startTime': null,
      'title': 'Daily Stand-Up Meeting',
    };

    final meeting = ScheduledMeeting.fromJson(apiItem);

    expect(meeting.meetingDetailId, 18);
    expect(meeting.meetingId, 'btc-Z-C9K4GoPNzzRQv2RR73Nw3-uwXSqHtP5OgbpH6KOag-e6IfEk32UtCfViNe2cyfzHTW9v1sdPDmB_UuahRRx8yCA_QsGUCxBoN3DqjNcwsi');
    expect(meeting.meetingPassword, 'wr7eBa');
    expect(meeting.organizedBy, 37);
    expect(meeting.title, 'Daily Stand-Up Meeting');
    expect(meeting.cleanAgenda, 'Daily Scrum meeting for the development team to review yesterday work, today plan, and any impediments affecting project progress.');
    expect(meeting.repeatType, 1);
    expect(meeting.repeatTypeLabel, 'Daily');
    expect(meeting.durationInSecond, 3600);
    expect(meeting.durationLabel, '1 hour');
    expect(meeting.participants.length, 3);
    expect(meeting.participants, contains('BOT00012'));
    expect(meeting.formattedTime, '05:00 AM');
    expect(meeting.formattedEndTime, '06:00 AM');
    expect(meeting.formattedTimeRange, '05:00 AM – 06:00 AM');

    final eventMap = meeting.toEventMap();
    expect(eventMap['title'], 'Daily Stand-Up Meeting');
    expect(eventMap['meetingId'], meeting.meetingId);
    expect(eventMap['repeatLabel'], 'Daily');
  });

  test('CalendarController binds scheduled meetings API response into calendar events and expands agendaDates', () {
    final controller = Get.put(CalendarController());

    final apiResponseList = [
      {
        'meetingDetailId': 18,
        'agenda': '<b>Daily Scrum </b>meeting for the development team.',
        'allDay': false,
        'conversationId': '0bd7a022651dcb56b849e606',
        'durationInSecond': 3600,
        'endDate': '2026-07-21T05:00:00',
        'endTime': null,
        'hasQuickMeeting': false,
        'meetingId': 'btc-Z-C9K4GoPNzzRQv2RR73Nw3-uwXSqHtP5OgbpH6KOag-e6IfEk32UtCfViNe2cyfzHTW9v1sdPDmB_UuahRRx8yCA_QsGUCxBoN3DqjNcwsi',
        'meetingPassword': 'wr7eBa',
        'organizedBy': 37,
        'organizerName': null,
        'participantCount': 0,
        'participants': '[\n    "BOT00012",\n    "BOT00035",\n    "BOT00037"\n]',
        'participantsDetail': null,
        'participantsId': null,
        'repeatType': 1,
        'startDate': '2026-07-21T05:00:00',
        'startTime': null,
        'title': 'Daily Stand-Up Meeting',
      }
    ];

    controller.bindScheduledMeetings(apiResponseList);

    expect(controller.scheduledMeetings.length, 1);
    expect(controller.scheduledMeetings.first.title, 'Daily Stand-Up Meeting');

    // Earliest date should be expanded to include 2026-07-21
    expect(controller.agendaDates.first.isAfter(DateTime(2026, 7, 21)), false);

    // Meeting occurs on its start date
    final startEvents = controller.getEventsForDate(DateTime(2026, 7, 21));
    expect(startEvents.any((e) => e['title'] == 'Daily Stand-Up Meeting'), true);

    // Because it is a Daily recurring meeting (repeatType = 1), it also occurs on Today
    final todayEvents = controller.getEventsForDate(DateTime.now());
    expect(todayEvents.any((e) => e['title'] == 'Daily Stand-Up Meeting'), true);
  });

  testWidgets('CalendarPage hides 1st layer on scroll up and shows on scroll down while 2nd and 3rd layer remain sticky', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Get.put(CalendarController());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const CalendarPage(),
      ),
    );
    await tester.pumpAndSettle();

    // 1st layer is initially visible
    expect(find.byTooltip('Jump to Today'), findsOneWidget);
    expect(find.byTooltip('Meet Now / Schedule Meeting'), findsOneWidget);
    expect(find.text('S'), findsWidgets); // 2nd layer
    expect(find.text('${DateTime.now().day}'), findsWidgets); // 3rd layer

    // Scroll up (drag upwards on vertical agenda so cards scroll up)
    await tester.drag(find.byType(ListView).last, const Offset(0, -300));
    await tester.pumpAndSettle();

    // 1st layer is hidden
    expect(find.byTooltip('Jump to Today'), findsNothing);
    expect(find.byTooltip('Meet Now / Schedule Meeting'), findsNothing);

    // 2nd and 3rd layers remain sticky and visible!
    expect(find.text('S'), findsWidgets);
    expect(find.text('${DateTime.now().day}'), findsWidgets);

    // Scroll down (drag downwards so cards scroll back down)
    await tester.drag(find.byType(ListView).last, const Offset(0, 300));
    await tester.pumpAndSettle();

    // 1st layer is shown again
    expect(find.byTooltip('Jump to Today'), findsOneWidget);
    expect(find.byTooltip('Meet Now / Schedule Meeting'), findsOneWidget);
  });
}
