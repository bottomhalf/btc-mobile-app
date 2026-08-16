/// Model representing a quick meeting.
class QuickMeetings {
  final int meetingDetailId;
  final String meetingId;
  final String meetingPassword;
  final int organizedBy;
  final String? agenda;
  final String title;
  final DateTime? startDate;
  final int durationInSecond;
  final String organizerName;
  final bool hasQuickMeeting;
  final String conversationId;
  final int repeatType;
  final List<dynamic>? participants;
  final List<dynamic>? participantsId;
  final bool allDay;

  QuickMeetings({
    this.meetingDetailId = 0,
    this.meetingId = '',
    this.meetingPassword = '',
    this.organizedBy = 0,
    this.agenda,
    this.title = '',
    this.startDate,
    this.durationInSecond = 0,
    this.organizerName = '',
    this.hasQuickMeeting = false,
    this.conversationId = '',
    this.repeatType = 0,
    this.participants,
    this.participantsId,
    this.allDay = false,
  });

  factory QuickMeetings.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['startDate'] != null) {
      if (json['startDate'] is int) {
        parsedDate = DateTime.fromMillisecondsSinceEpoch(json['startDate'] as int);
      } else if (json['startDate'] is String) {
        parsedDate = DateTime.tryParse(json['startDate'] as String);
      }
    }

    return QuickMeetings(
      meetingDetailId: json['meetingDetailId'] as int? ?? 0,
      meetingId: json['meetingId'] as String? ?? '',
      meetingPassword: json['meetingPassword'] as String? ?? '',
      organizedBy: json['organizedBy'] as int? ?? 0,
      agenda: json['agenda'] as String?,
      title: json['title'] as String? ?? '',
      startDate: parsedDate,
      durationInSecond: json['durationInSecond'] as int? ?? 0,
      organizerName: json['organizerName'] as String? ?? '',
      hasQuickMeeting: json['hasQuickMeeting'] as bool? ?? false,
      conversationId: json['conversationId'] as String? ?? '',
      repeatType: json['repeatType'] as int? ?? 0,
      participants: json['participants'] as List<dynamic>?,
      participantsId: json['participantsId'] as List<dynamic>?,
      allDay: json['allDay'] as bool? ?? false,
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
      'durationInSecond': durationInSecond,
      'organizerName': organizerName,
      'hasQuickMeeting': hasQuickMeeting,
      'conversationId': conversationId,
      'repeatType': repeatType,
      'participants': participants,
      'participantsId': participantsId,
      'allDay': allDay,
    };
  }
}