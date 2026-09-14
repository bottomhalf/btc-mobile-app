import 'dart:convert';
import 'package:conference/models/quick_meetings.dart';

/// Model representing a scheduled meeting from the API:
/// `meeting/getAllScheduleMeetingByOrganizer`
class ScheduledMeeting {
  final int meetingDetailId;
  final String meetingId;
  final String meetingPassword;
  final int organizedBy;
  final String? organizerName;
  final String? agenda;
  final String title;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? startTime;
  final String? endTime;
  final int durationInSecond;
  final bool hasQuickMeeting;
  final String conversationId;
  final int repeatType;
  final List<String> participants;
  final dynamic participantsDetail;
  final dynamic participantsId;
  final int participantCount;
  final bool allDay;

  ScheduledMeeting({
    this.meetingDetailId = 0,
    this.meetingId = '',
    this.meetingPassword = '',
    this.organizedBy = 0,
    this.organizerName,
    this.agenda,
    this.title = '',
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.durationInSecond = 0,
    this.hasQuickMeeting = false,
    this.conversationId = '',
    this.repeatType = 0,
    this.participants = const [],
    this.participantsDetail,
    this.participantsId,
    this.participantCount = 0,
    this.allDay = false,
  });

  /// Strips HTML tags from the agenda field (e.g. `<b>Daily Scrum </b>` -> `Daily Scrum`).
  String get cleanAgenda {
    if (agenda == null || agenda!.isEmpty) return '';
    return agenda!.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  /// Readable label for repeat frequency
  String get repeatTypeLabel {
    switch (repeatType) {
      case 1:
        return 'Daily';
      case 2:
        return 'Weekly';
      case 3:
        return 'Monthly';
      default:
        return 'Does not repeat';
    }
  }

  /// Formatted start time string, e.g. "05:00 AM" or "10:30 AM"
  String get formattedTime {
    if (startTime != null && startTime!.isNotEmpty) {
      return startTime!;
    }
    if (startDate != null) {
      return _formatTimeOfDay(startDate!);
    }
    return '';
  }

  /// Formatted end time string, e.g. "06:00 AM"
  String get formattedEndTime {
    if (endTime != null && endTime!.isNotEmpty) {
      return endTime!;
    }
    if (endDate != null && startDate != null && endDate!.isAfter(startDate!)) {
      return _formatTimeOfDay(endDate!);
    }
    if (startDate != null && durationInSecond > 0) {
      return _formatTimeOfDay(startDate!.add(Duration(seconds: durationInSecond)));
    }
    if (endDate != null) {
      return _formatTimeOfDay(endDate!);
    }
    return '';
  }

  /// Formatted time range, e.g. "05:00 AM – 06:00 AM"
  String get formattedTimeRange {
    final start = formattedTime;
    final end = formattedEndTime;
    if (allDay) return 'All Day';
    if (start.isNotEmpty && end.isNotEmpty && start != end) {
      return '$start – $end';
    }
    if (start.isNotEmpty) return start;
    return '';
  }

  /// Formatted human-readable duration, e.g. "1 hour", "30 mins"
  String get durationLabel {
    if (durationInSecond <= 0) return '';
    final minutes = (durationInSecond / 60).round();
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMins = minutes % 60;
      if (remainingMins == 0) {
        return hours == 1 ? '1 hour' : '$hours hours';
      }
      return '$hours hr $remainingMins min';
    }
    return '$minutes mins';
  }

  static String _formatTimeOfDay(DateTime dt) {
    final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final hourPadded = hour12.toString().padLeft(2, '0');
    return '$hourPadded:$minute $period';
  }

  /// Converts this model to the map structure used by calendar event cards
  Map<String, String> toEventMap({DateTime? occurrenceDate}) {
    final timeStr = formattedTime;
    final rangeStr = formattedTimeRange;

    String type = 'meeting';
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('review') || lowerTitle.contains('retrospective')) {
      type = 'review';
    } else if (lowerTitle.contains('demo') || lowerTitle.contains('client')) {
      type = 'demo';
    }

    return {
      'meetingDetailId': meetingDetailId.toString(),
      'meetingId': meetingId,
      'meetingPassword': meetingPassword,
      'title': title.isNotEmpty ? title : 'Meeting',
      'time': timeStr.isNotEmpty ? timeStr : '10:00 AM',
      'duration': durationLabel.isNotEmpty ? durationLabel : '30 mins',
      'timeRange': rangeStr.isNotEmpty ? rangeStr : '10:00 AM – 10:30 AM',
      'type': type,
      'platform': 'Confeet Meeting',
      'organizer': (organizerName != null && organizerName!.isNotEmpty) ? organizerName! : 'Organizer',
      'agenda': cleanAgenda,
      'conversationId': conversationId,
      'repeatType': repeatType.toString(),
      'repeatLabel': repeatTypeLabel,
      'hasQuickMeeting': hasQuickMeeting.toString(),
    };
  }

  /// Interop converter to QuickMeetings
  QuickMeetings toQuickMeetings() {
    return QuickMeetings(
      meetingDetailId: meetingDetailId,
      meetingId: meetingId,
      meetingPassword: meetingPassword,
      organizedBy: organizedBy,
      organizerName: organizerName ?? '',
      agenda: agenda,
      title: title,
      startDate: startDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
      durationInSecond: durationInSecond,
      hasQuickMeeting: hasQuickMeeting,
      conversationId: conversationId,
      repeatType: repeatType,
      participants: participants,
      participantsDetail: participantsDetail,
      participantsId: participantsId,
      participantCount: participantCount,
      allDay: allDay,
      isAllDay: allDay,
    );
  }

  factory ScheduledMeeting.fromQuickMeetings(QuickMeetings m) {
    return ScheduledMeeting(
      meetingDetailId: m.meetingDetailId,
      meetingId: m.meetingId,
      meetingPassword: m.meetingPassword,
      organizedBy: m.organizedBy,
      organizerName: m.organizerName,
      agenda: m.agenda,
      title: m.title,
      startDate: m.startDate,
      endDate: m.endDate,
      startTime: m.startTime,
      endTime: m.endTime,
      durationInSecond: m.durationInSecond,
      hasQuickMeeting: m.hasQuickMeeting,
      conversationId: m.conversationId,
      repeatType: m.repeatType,
      participants: m.participants?.map((e) => e.toString()).toList() ?? [],
      participantsDetail: m.participantsDetail,
      participantsId: m.participantsId,
      participantCount: m.participantCount,
      allDay: m.allDay || m.isAllDay,
    );
  }

  factory ScheduledMeeting.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate = _parseDateTime(json['startDate']);
    DateTime? parsedEndDate = _parseDateTime(json['endDate']);

    int repeat = 0;
    if (json['repeatType'] is int) {
      repeat = json['repeatType'] as int;
    } else if (json['repeatType'] is String) {
      final str = (json['repeatType'] as String).toLowerCase();
      if (str.contains('daily')) {
        repeat = 1;
      } else if (str.contains('weekly')) {
        repeat = 2;
      } else if (str.contains('monthly')) {
        repeat = 3;
      } else {
        repeat = int.tryParse(json['repeatType'] as String) ?? 0;
      }
    }

    List<String> parsedParticipants = [];
    if (json['participants'] != null) {
      if (json['participants'] is List) {
        parsedParticipants = (json['participants'] as List).map((e) => e.toString()).toList();
      } else if (json['participants'] is String) {
        try {
          final decoded = jsonDecode(json['participants'] as String);
          if (decoded is List) {
            parsedParticipants = decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }
    }

    final int pCount = json['participantCount'] as int? ?? parsedParticipants.length;
    final bool allDayVal = json['allDay'] as bool? ?? json['isAllDay'] as bool? ?? false;

    return ScheduledMeeting(
      meetingDetailId: json['meetingDetailId'] as int? ?? 0,
      meetingId: json['meetingId'] as String? ?? '',
      meetingPassword: json['meetingPassword'] as String? ?? '',
      organizedBy: json['organizedBy'] as int? ?? 0,
      organizerName: json['organizerName'] as String?,
      agenda: json['agenda'] as String?,
      title: json['title'] as String? ?? '',
      startDate: parsedDate,
      endDate: parsedEndDate,
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      durationInSecond: json['durationInSecond'] as int? ?? 0,
      hasQuickMeeting: json['hasQuickMeeting'] as bool? ?? false,
      conversationId: json['conversationId'] as String? ?? '',
      repeatType: repeat,
      participants: parsedParticipants,
      participantsDetail: json['participantsDetail'],
      participantsId: json['participantsId'],
      participantCount: pCount,
      allDay: allDayVal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meetingDetailId': meetingDetailId,
      'meetingId': meetingId,
      'meetingPassword': meetingPassword,
      'organizedBy': organizedBy,
      'organizerName': organizerName,
      'agenda': agenda,
      'title': title,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'durationInSecond': durationInSecond,
      'hasQuickMeeting': hasQuickMeeting,
      'conversationId': conversationId,
      'repeatType': repeatType,
      'participants': jsonEncode(participants),
      'participantsDetail': participantsDetail,
      'participantsId': participantsId,
      'participantCount': participantCount,
      'allDay': allDay,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      if (value.isEmpty) return null;
      final parsed = DateTime.tryParse(value);
      if (parsed == null) return null;
      return parsed.isUtc ? parsed.toLocal() : parsed;
    }
    return null;
  }
}
