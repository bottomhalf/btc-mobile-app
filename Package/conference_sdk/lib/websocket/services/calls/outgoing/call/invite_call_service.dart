import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/btcmeet_socket_service.dart';

class InviteCallService {
  void execute(
    String targetUserId,
    String conversationId,
    String callType, {
    int timeout = 120,
  }) {
    final currentUser = BtcMeetSocketService.instance.localUser;
    final callerId = currentUser?.userId ?? '';
    final callerName = currentUser?.fullName ?? '';
    final callerAvatar = currentUser?.avatar ?? '';

    final payload = CallInvitePayload(
      targetUserId: targetUserId,
      callerId: callerId,
      callerName: callerName,
      callerAvatar: callerAvatar,
      conversationId: conversationId,
      callType: callType,
      timeout: timeout,
    );

    BtcMeetSocketService.instance.sendEvent(CallEvents.callInvite, payload.toJson());
  }
}

