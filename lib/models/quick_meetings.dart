import 'dart:convert';

/// Model representing a meeting (Quick or Scheduled).
class QuickMeetings {
  final int meetingDetailId;
  final String meetingId;
  final String meetingPassword;
  final int organizedBy;
  final String? agenda;
  final String title;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? startTime;
  final String? endTime;
  final int durationInSecond;
  final String organizerName;
  final bool hasQuickMeeting;
  final String conversationId;
  final int repeatType;
  final List<dynamic>? participants;
  final List<dynamic>? participantsId;
  final int participantCount;
  final dynamic participantsDetail;
  final bool allDay;
  final bool isAllDay;

  QuickMeetings({
    this.meetingDetailId = 0,
    this.meetingId = '',
    this.meetingPassword = '',
    this.organizedBy = 0,
    this.agenda,
    this.title = '',
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.durationInSecond = 0,
    this.organizerName = '',
    this.hasQuickMeeting = false,
    this.conversationId = '',
    this.repeatType = 0,
    this.participants,
    this.participantsId,
    this.participantCount = 0,
    this.participantsDetail,
    this.allDay = false,
    this.isAllDay = false,
  });

  /// Whether this is a scheduled meeting
  bool get isScheduled => !hasQuickMeeting;

  /// Whether this is an instant quick meeting
  bool get isQuickMeeting => hasQuickMeeting;

  /// Total count of participants
  int get totalParticipants {
    if (participantCount > 0) return participantCount;
    if (participants != null && participants!.isNotEmpty) return participants!.length;
    if (participantsId != null && participantsId!.isNotEmpty) return participantsId!.length;
    return 0;
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

  /// Formatted time range, e.g. "10:00 A.M - 11:00 A.M" or "10:00 A.M"
  String get timeRangeLabel {
    if (startTime != null && startTime!.isNotEmpty) {
      if (endTime != null && endTime!.isNotEmpty && endTime != startTime) {
        return '$startTime - $endTime';
      }
      return startTime!;
    }
    return '';
  }

  factory QuickMeetings.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['startDate'] != null) {
      if (json['startDate'] is int) {
        parsedDate = DateTime.fromMillisecondsSinceEpoch(json['startDate'] as int);
      } else if (json['startDate'] is String) {
        parsedDate = DateTime.tryParse(json['startDate'] as String);
      }
    }

    DateTime? parsedEndDate;
    if (json['endDate'] != null) {
      if (json['endDate'] is int) {
        parsedEndDate = DateTime.fromMillisecondsSinceEpoch(json['endDate'] as int);
      } else if (json['endDate'] is String) {
        parsedEndDate = DateTime.tryParse(json['endDate'] as String);
      }
    }

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
        repeat = 0;
      }
    }

    // participants can be either a List<dynamic> or a JSON string like "[\"BOT00004\"]"
    List<dynamic>? parsedParticipants;
    if (json['participants'] != null) {
      if (json['participants'] is List) {
        parsedParticipants = json['participants'] as List<dynamic>;
      } else if (json['participants'] is String) {
        try {
          final decoded = jsonDecode(json['participants'] as String);
          if (decoded is List) {
            parsedParticipants = decoded;
          }
        } catch (_) {}
      }
    }

    // participantsId can be either a List<dynamic> or a JSON string
    List<dynamic>? parsedParticipantsId;
    if (json['participantsId'] != null) {
      if (json['participantsId'] is List) {
        parsedParticipantsId = json['participantsId'] as List<dynamic>;
      } else if (json['participantsId'] is String) {
        try {
          final decoded = jsonDecode(json['participantsId'] as String);
          if (decoded is List) {
            parsedParticipantsId = decoded;
          }
        } catch (_) {}
      }
    }

    final int pCount = json['participantCount'] as int? ??
        (parsedParticipants?.length ?? (parsedParticipantsId?.length ?? 0));

    final bool allDayValue = json['isAllDay'] as bool? ?? json['allDay'] as bool? ?? false;

    return QuickMeetings(
      meetingDetailId: json['meetingDetailId'] as int? ?? 0,
      meetingId: json['meetingId'] as String? ?? '',
      meetingPassword: json['meetingPassword'] as String? ?? '',
      organizedBy: json['organizedBy'] as int? ?? 0,
      agenda: json['agenda'] as String?,
      title: json['title'] as String? ?? '',
      startDate: parsedDate,
      endDate: parsedEndDate,
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      durationInSecond: json['durationInSecond'] as int? ?? 0,
      organizerName: json['organizerName'] as String? ?? '',
      hasQuickMeeting: json['hasQuickMeeting'] as bool? ?? false,
      conversationId: json['conversationId'] as String? ?? '',
      repeatType: repeat,
      participants: parsedParticipants,
      participantsId: parsedParticipantsId,
      participantCount: pCount,
      participantsDetail: json['participantsDetail'],
      allDay: allDayValue,
      isAllDay: allDayValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meetingDetailId': meetingDetailId,
      'meetingId': meetingId,
      'meetingPassword': meetingPassword,
      'organizedBy': organizedBy,
      'agenda': agenda,
      'title': title,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'durationInSecond': durationInSecond,
      'organizerName': organizerName,
      'hasQuickMeeting': hasQuickMeeting,
      'conversationId': conversationId,
      'repeatType': repeatType,
      'participants': participants,
      'participantsId': participantsId,
      'participantCount': participantCount,
      'participantsDetail': participantsDetail,
      'allDay': allDay,
      'isAllDay': isAllDay,
    };
  }
}