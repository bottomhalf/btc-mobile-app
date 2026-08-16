
// ============================================
// Call Event Types - Client to Server
// ============================================
class CallEvents {
  static const String callInitiate = 'call:initiate';
  static const String callStarted = 'call:started';
  static const String callAccept = 'call:accept';
  static const String callReject = 'call:reject';
  static const String callDismiss = 'call:dismiss';
  static const String callCancel = 'call:cancel';
  static const String callTimeout = 'call:timeout';
  static const String callEnd = 'call:end';
  static const String callInvite = 'call:invite';
  static const String joiningRequest = 'call:raise-joining-request';
  static const String eventGroupNotification = 'call:group-notification';
  static const String callTestSignal = 'call:test-signal';
}

// ============================================
// Call Event Types - Server to Client
// ============================================
class CallServerEvents {
  static const String callIncoming = 'call:incoming';
  static const String initUserlist = 'init_userlist';
  static const String callJoiningRequest = 'call:joining_request';
  static const String callRaisedRequest = 'call:raise-joining-request';
  static const String callAccepted = 'call:accepted';
  static const String callRejected = 'call:rejected';
  static const String callDismissed = 'call:dismissed';
  static const String callCancelled = 'call:cancelled';
  static const String callTimedOut = 'call:timed_out';
  static const String callEnded = 'call:ended';
  static const String callBusy = 'call:busy';
  static const String callError = 'call:error';
  static const String callGroupNotification = 'call:group-notification';
}

// ============================================
// Group Notification Types
// ============================================
class NotificationEventType {
  static const String gnGroupCreated = 'group:created';
  static const String gnGroupDeleted = 'group:deleted';
  static const String gnGroupRenamed = 'group:renamed';
  static const String gnGroupMemberAdded = 'group:member_added';
}

// ============================================
// Call Types
// ============================================
class CallType {
  static const String audio = 'audio';
  static const String video = 'video';
}

// ============================================
// Participant Status Constants
// ============================================
class ParticipantStatus {
  static const int ringing = 1;
  static const int accepted = 2;
  static const int rejected = 3;
  static const int timeout = 4;
  static const int left = 5;
  static const int dismiss = 6;
}

// ============================================
// Call Status Constants
// ============================================
class CallStatus {
  static const int initiated = 1;
  static const int ringing = 2;
  static const int accepted = 3;
  static const int rejected = 4;
  static const int cancelled = 5;
  static const int timeout = 6;
  static const int ended = 7;
  static const int busy = 8;
  static const int failed = 9;
  static const int missed = 10;
  static const int joiningRequest = 11;
  static const int dismissed = 12;
  static const int raisedJoiningRequest = 13;
}

// ============================================
// Call End Reasons
// ============================================
class CallEndReason {
  static const String normal = 'normal';
  static const String busy = 'busy';
  static const String timeout = 'timeout';
  static const String rejected = 'rejected';
  static const String cancelled = 'cancelled';
  static const String error = 'error';
  static const String noNetwork = 'no_network';
}

// ============================================
// Call Configuration
// ============================================
class CallConfig {
  static const int defaultTimeout = 40;
  static const int maxTimeout = 120;
}

// ============================================
// Event Type Constants (Low Level Socket)
// ============================================
class WsEvents {
  // Client -> Server
  static const String sendMessage = 'send_message';
  static const String markDelivered = 'mark_delivered';
  static const String markSeen = 'mark_seen';
  static const String typing = 'typing';
  static const String audioCallRequest = 'audio_call_request';
  static const String reactMessage = 'react_message';
  static const String heartbeat = 'heartbeat';
  static const String initUserlist = 'init_userlist';
  static const String updateStatus = 'update_status';

  // Server -> Client
  static const String newMessage = 'new_message';
  static const String messageSent = 'message_sent';
  static const String messageReacted = 'message_reacted';
  static const String delivered = 'delivered';
  static const String seen = 'mark_seen';
  static const String userTyping = 'user_typing';
  static const String userStatus = 'user_status';
  static const String error = 'error';
  static const String pong = 'pong';
}

// ============================================
// Low Level WS Event Wrapper
// ============================================
class WsEvent {
  final String event;
  final dynamic payload;

  WsEvent({required this.event, required this.payload});

  factory WsEvent.fromJson(Map<String, dynamic> json) {
    return WsEvent(
      event: json['event'] as String? ?? '',
      payload: json['payload'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'payload': payload,
    };
  }
}

// ============================================
// Chat Message Models
// ============================================
class Message {
  final String? id;
  final String messageId;
  final String conversationId;
  final String senderId;
  final String type; // 'text' | 'audio' | 'video' | 'image' | 'file'
  final String content;
  final String? fileUrl;
  final String? replyTo;
  final List<dynamic> mentions;
  final List<Reaction> reactions;
  final String clientType; // default 'web' or 'mobile'
  final DateTime? createdAt;
  final DateTime? editedAt;
  final int? status;
  final String? receivedId;
  final bool? isMentioned;
  final List<String>? seenByUserIds;

  Message({
    this.id,
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.content,
    this.fileUrl,
    this.replyTo,
    this.mentions = const [],
    this.reactions = const [],
    this.clientType = 'mobile',
    this.createdAt,
    this.editedAt,
    this.status,
    this.receivedId,
    this.isMentioned,
    this.seenByUserIds,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String?,
      messageId: json['messageId'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      content: json['content'] as String? ?? '',
      fileUrl: json['fileUrl'] as String?,
      replyTo: json['replyTo'] as String?,
      mentions: json['mentions'] as List<dynamic>? ?? [],
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      clientType: json['clientType'] as String? ?? 'mobile',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      editedAt: json['editedAt'] != null
          ? DateTime.tryParse(json['editedAt'] as String)
          : null,
      status: json['status'] as int?,
      receivedId: json['recievedId'] as String?, // Note typo in original: 'recievedId'
      isMentioned: json['isMentioned'] as bool?,
      seenByUserIds: (json['seenByUserIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'type': type,
      'content': content,
      if (fileUrl != null) 'fileUrl': fileUrl,
      if (replyTo != null) 'replyTo': replyTo,
      'mentions': mentions,
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'clientType': clientType,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (editedAt != null) 'editedAt': editedAt!.toIso8601String(),
      if (status != null) 'status': status,
      if (receivedId != null) 'recievedId': receivedId,
      if (isMentioned != null) 'isMentioned': isMentioned,
      if (seenByUserIds != null) 'seenByUserIds': seenByUserIds,
    };
  }
}

class Reaction {
  final String userId;
  final String emoji;

  Reaction({required this.userId, required this.emoji});

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      userId: json['userId'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'emoji': emoji,
    };
  }
}

// ============================================
// Message Event Payloads
// ============================================
class MessageDelivered {
  final String id;
  final String conversationId;
  final String deliveredTo;
  final String deliveredAt;

  MessageDelivered({
    required this.id,
    required this.conversationId,
    required this.deliveredTo,
    required this.deliveredAt,
  });

  factory MessageDelivered.fromJson(Map<String, dynamic> json) {
    return MessageDelivered(
      id: json['id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      deliveredTo: json['deliveredTo'] as String? ?? '',
      deliveredAt: json['deliveredAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'deliveredTo': deliveredTo,
      'deliveredAt': deliveredAt,
    };
  }
}

class MessageSeen {
  final String messageId;
  final String conversationId;
  final String userId;
  final String seenAt;

  MessageSeen({
    required this.messageId,
    required this.conversationId,
    required this.userId,
    required this.seenAt,
  });

  factory MessageSeen.fromJson(Map<String, dynamic> json) {
    return MessageSeen(
      messageId: json['messageId'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      seenAt: json['seenAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'userId': userId,
      'seenAt': seenAt,
    };
  }
}

class TypingIndicator {
  final String conversationId;
  final String userId;
  final bool isTyping;

  TypingIndicator({
    required this.conversationId,
    required this.userId,
    required this.isTyping,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      conversationId: json['conversationId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      isTyping: json['isTyping'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'userId': userId,
      'isTyping': isTyping,
    };
  }
}

class ErrorPayload {
  final int code;
  final String message;

  ErrorPayload({required this.code, required this.message});

  factory ErrorPayload.fromJson(Map<String, dynamic> json) {
    return ErrorPayload(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}

class PongPayload {
  final String timestamp;

  PongPayload({required this.timestamp});

  factory PongPayload.fromJson(Map<String, dynamic> json) {
    return PongPayload(
      timestamp: json['timestamp'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
    };
  }
}

// ============================================
// Call Participant Model
// ============================================
class CallParticipant {
  final String userId;
  final String name;
  final String avatar;
  final String email;
  final int status;
  final DateTime? joinedAt;
  final DateTime? leftAt;
  final String? endReason;

  CallParticipant({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.email,
    required this.status,
    this.joinedAt,
    this.leftAt,
    this.endReason,
  });

  factory CallParticipant.fromJson(Map<String, dynamic> json) {
    return CallParticipant(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      email: json['email'] as String? ?? '',
      status: json['status'] as int? ?? ParticipantStatus.ringing,
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'] as String)
          : null,
      leftAt: json['leftAt'] != null
          ? DateTime.tryParse(json['leftAt'] as String)
          : null,
      endReason: json['endReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'avatar': avatar,
      'email': email,
      'status': status,
      if (joinedAt != null) 'joinedAt': joinedAt!.toIso8601String(),
      if (leftAt != null) 'leftAt': leftAt!.toIso8601String(),
      if (endReason != null) 'endReason': endReason,
    };
  }
}

// ============================================
// Client to Server Call Payloads
// ============================================
class CallInitiatePayload {
  final String? callId;
  final String? callerId;
  final String? callerName;
  final String? callerAvatar;
  final String conversationId;
  final List<String> calleeIds;
  final String callType;
  final int? timeout;

  CallInitiatePayload({
    this.callId,
    this.callerId,
    this.callerName,
    this.callerAvatar,
    required this.conversationId,
    required this.calleeIds,
    required this.callType,
    this.timeout,
  });

  factory CallInitiatePayload.fromJson(Map<String, dynamic> json) {
    return CallInitiatePayload(
      callId: json['callId'] as String?,
      callerId: json['callerId'] as String?,
      callerName: json['callerName'] as String?,
      callerAvatar: json['callerAvatar'] as String?,
      conversationId: json['conversationId'] as String? ?? '',
      calleeIds: (json['calleeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      callType: json['callType'] as String? ?? CallType.audio,
      timeout: json['timeout'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (callId != null) 'callId': callId,
      if (callerId != null) 'callerId': callerId,
      if (callerName != null) 'callerName': callerName,
      if (callerAvatar != null) 'callerAvatar': callerAvatar,
      'conversationId': conversationId,
      'calleeIds': calleeIds,
      'callType': callType,
      if (timeout != null) 'timeout': timeout,
    };
  }
}

class CallInvitePayload {
  final String targetUserId;
  final String callerId;
  final String? callerName;
  final String? callerAvatar;
  final String conversationId;
  final String callType;
  final int? timeout;

  CallInvitePayload({
    required this.targetUserId,
    required this.callerId,
    this.callerName,
    this.callerAvatar,
    required this.conversationId,
    required this.callType,
    this.timeout,
  });

  factory CallInvitePayload.fromJson(Map<String, dynamic> json) {
    return CallInvitePayload(
      targetUserId: json['targetUserId'] as String? ?? '',
      callerId: json['callerId'] as String? ?? '',
      callerName: json['callerName'] as String?,
      callerAvatar: json['callerAvatar'] as String?,
      conversationId: json['conversationId'] as String? ?? '',
      callType: json['callType'] as String? ?? CallType.audio,
      timeout: json['timeout'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetUserId': targetUserId,
      'callerId': callerId,
      if (callerName != null) 'callerName': callerName,
      if (callerAvatar != null) 'callerAvatar': callerAvatar,
      'conversationId': conversationId,
      'callType': callType,
      if (timeout != null) 'timeout': timeout,
    };
  }
}

class CallAcceptPayload {
  final String conversationId;
  final String callerId;

  CallAcceptPayload({
    required this.conversationId,
    required this.callerId,
  });

  factory CallAcceptPayload.fromJson(Map<String, dynamic> json) {
    return CallAcceptPayload(
      conversationId: json['conversationId'] as String? ?? '',
      callerId: json['callerId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'callerId': callerId,
    };
  }
}

class CallRejectPayload {
  final String conversationId;
  final String callerId;
  final String? reason;

  CallRejectPayload({
    required this.conversationId,
    required this.callerId,
    this.reason,
  });

  factory CallRejectPayload.fromJson(Map<String, dynamic> json) {
    return CallRejectPayload(
      conversationId: json['conversationId'] as String? ?? '',
      callerId: json['callerId'] as String? ?? '',
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'callerId': callerId,
      if (reason != null) 'reason': reason,
    };
  }
}

class CallDismissPayload {
  final String conversationId;
  final String callerId;
  final String? reason;

  CallDismissPayload({
    required this.conversationId,
    required this.callerId,
    this.reason,
  });

  factory CallDismissPayload.fromJson(Map<String, dynamic> json) {
    return CallDismissPayload(
      conversationId: json['conversationId'] as String? ?? '',
      callerId: json['callerId'] as String? ?? '',
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'callerId': callerId,
      if (reason != null) 'reason': reason,
    };
  }
}

class CallCancelPayload {
  final String conversationId;
  final List<String> calleeIds;

  CallCancelPayload({
    required this.conversationId,
    required this.calleeIds,
  });

  factory CallCancelPayload.fromJson(Map<String, dynamic> json) {
    return CallCancelPayload(
      conversationId: json['conversationId'] as String? ?? '',
      calleeIds: (json['calleeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'calleeIds': calleeIds,
    };
  }
}

class CallTimeoutPayload {
  final String conversationId;
  final String callerId;

  CallTimeoutPayload({
    required this.conversationId,
    required this.callerId,
  });

  factory CallTimeoutPayload.fromJson(Map<String, dynamic> json) {
    return CallTimeoutPayload(
      conversationId: json['conversationId'] as String? ?? '',
      callerId: json['callerId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'callerId': callerId,
    };
  }
}

class CallEndPayload {
  final String conversationId;
  final String? reason;

  CallEndPayload({
    required this.conversationId,
    this.reason,
  });

  factory CallEndPayload.fromJson(Map<String, dynamic> json) {
    return CallEndPayload(
      conversationId: json['conversationId'] as String? ?? '',
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      if (reason != null) 'reason': reason,
    };
  }
}

// ============================================
// Server to Client Call Event Payloads
// ============================================
class CallIncomingEvent {
  final String conversationId;
  final String callerId;
  final String? callerName;
  final String? callerAvatar;
  final String callType;
  final Map<String, CallParticipant> participants;
  final int timeout;
  final int timestamp;

  CallIncomingEvent({
    required this.conversationId,
    required this.callerId,
    this.callerName,
    this.callerAvatar,
    required this.callType,
    required this.participants,
    required this.timeout,
    required this.timestamp,
  });

  factory CallIncomingEvent.fromJson(Map<String, dynamic> json) {
    final participantsMap = <String, CallParticipant>{};
    if (json['participants'] != null) {
      final pJson = json['participants'] as Map<String, dynamic>;
      pJson.forEach((key, value) {
        participantsMap[key] =
            CallParticipant.fromJson(value as Map<String, dynamic>);
      });
    }

    return CallIncomingEvent(
      conversationId: json['conversationId'] as String? ?? '',
      callerId: json['callerId'] as String? ?? '',
      callerName: json['callerName'] as String?,
      callerAvatar: json['callerAvatar'] as String?,
      callType: json['callType'] as String? ?? CallType.audio,
      participants: participantsMap,
      timeout: json['timeout'] as int? ?? CallConfig.defaultTimeout,
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'callerId': callerId,
      if (callerName != null) 'callerName': callerName,
      if (callerAvatar != null) 'callerAvatar': callerAvatar,
      'callType': callType,
      'participants': participants.map((key, value) => MapEntry(key, value.toJson())),
      'timeout': timeout,
      'timestamp': timestamp,
    };
  }
}

class GroupNotificationEvent {
  final String conversationId;
  final String notificationType;
  final String callerId;

  GroupNotificationEvent({
    required this.conversationId,
    required this.notificationType,
    required this.callerId,
  });

  factory GroupNotificationEvent.fromJson(Map<String, dynamic> json) {
    return GroupNotificationEvent(
      conversationId: json['conversationId'] as String? ?? '',
      notificationType: json['notificationType'] as String? ?? '',
      callerId: json['callerId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'notificationType': notificationType,
      'callerId': callerId,
    };
  }
}

class CallAcceptedEvent {
  final String conversationId;
  final String acceptedBy;
  final String roomName;
  final String token;
  final int timestamp;

  CallAcceptedEvent({
    required this.conversationId,
    required this.acceptedBy,
    required this.roomName,
    required this.token,
    required this.timestamp,
  });

  factory CallAcceptedEvent.fromJson(Map<String, dynamic> json) {
    return CallAcceptedEvent(
      conversationId: json['conversationId'] as String? ?? '',
      acceptedBy: json['acceptedBy'] as String? ?? '',
      roomName: json['roomName'] as String? ?? '',
      token: json['token'] as String? ?? '',
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'acceptedBy': acceptedBy,
      'roomName': roomName,
      'token': token,
      'timestamp': timestamp,
    };
  }
}

class CallRejectedEvent {
  final String conversationId;
  final String rejectedBy;
  final String? reason;
  final int timestamp;

  CallRejectedEvent({
    required this.conversationId,
    required this.rejectedBy,
    this.reason,
    required this.timestamp,
  });

  factory CallRejectedEvent.fromJson(Map<String, dynamic> json) {
    return CallRejectedEvent(
      conversationId: json['conversationId'] as String? ?? '',
      rejectedBy: json['rejectedBy'] as String? ?? '',
      reason: json['reason'] as String?,
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'rejectedBy': rejectedBy,
      if (reason != null) 'reason': reason,
      'timestamp': timestamp,
    };
  }
}

class CallDismissedEvent {
  final String callId;
  final String dismissedBy;
  final String? reason;
  final int timestamp;

  CallDismissedEvent({
    required this.callId,
    required this.dismissedBy,
    this.reason,
    required this.timestamp,
  });

  factory CallDismissedEvent.fromJson(Map<String, dynamic> json) {
    return CallDismissedEvent(
      callId: json['callId'] as String? ?? '',
      dismissedBy: json['dismissedBy'] as String? ?? '',
      reason: json['reason'] as String?,
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'callId': callId,
      'dismissedBy': dismissedBy,
      if (reason != null) 'reason': reason,
      'timestamp': timestamp,
    };
  }
}

class CallCancelledEvent {
  final String conversationId;
  final String cancelledBy;
  final int timestamp;

  CallCancelledEvent({
    required this.conversationId,
    required this.cancelledBy,
    required this.timestamp,
  });

  factory CallCancelledEvent.fromJson(Map<String, dynamic> json) {
    return CallCancelledEvent(
      conversationId: json['conversationId'] as String? ?? '',
      cancelledBy: json['cancelledBy'] as String? ?? '',
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'cancelledBy': cancelledBy,
      'timestamp': timestamp,
    };
  }
}

class CallTimedOutEvent {
  final String conversationId;
  final int timestamp;

  CallTimedOutEvent({
    required this.conversationId,
    required this.timestamp,
  });

  factory CallTimedOutEvent.fromJson(Map<String, dynamic> json) {
    return CallTimedOutEvent(
      conversationId: json['conversationId'] as String? ?? '',
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'timestamp': timestamp,
    };
  }
}

class CallEndedEvent {
  final String conversationId;
  final String endedBy;
  final String reason;
  final int duration;
  final int timestamp;

  CallEndedEvent({
    required this.conversationId,
    required this.endedBy,
    required this.reason,
    required this.duration,
    required this.timestamp,
  });

  factory CallEndedEvent.fromJson(Map<String, dynamic> json) {
    return CallEndedEvent(
      conversationId: json['conversationId'] as String? ?? '',
      endedBy: json['endedBy'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'endedBy': endedBy,
      'reason': reason,
      'duration': duration,
      'timestamp': timestamp,
    };
  }
}

class CallBusyEvent {
  final String conversationId;
  final String busyUser;
  final int timestamp;

  CallBusyEvent({
    required this.conversationId,
    required this.busyUser,
    required this.timestamp,
  });

  factory CallBusyEvent.fromJson(Map<String, dynamic> json) {
    return CallBusyEvent(
      conversationId: json['conversationId'] as String? ?? '',
      busyUser: json['busyUser'] as String? ?? '',
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'busyUser': busyUser,
      'timestamp': timestamp,
    };
  }
}

class CallErrorEvent {
  final String conversationId;
  final String error;
  final String? code;
  final int timestamp;

  CallErrorEvent({
    required this.conversationId,
    required this.error,
    this.code,
    required this.timestamp,
  });

  factory CallErrorEvent.fromJson(Map<String, dynamic> json) {
    return CallErrorEvent(
      conversationId: json['conversationId'] as String? ?? '',
      error: json['error'] as String? ?? '',
      code: json['code'] as String?,
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'error': error,
      if (code != null) 'code': code,
      'timestamp': timestamp,
    };
  }
}
