import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/btcmeet_socket_service.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class DismissJoiningRequestService {
  void execute(String conversationId, String callerId, {String? reason}) {
    BtcMeetSocketService.instance.sendEvent(
      CallEvents.callDismiss,
      CallDismissPayload(
        conversationId: conversationId,
        callerId: callerId,
        reason: reason ?? CallEndReason.normal,
      ).toJson(),
    );
    ServerEventService.instance.store.hasIncomingCall.value = false;
    ServerEventService.instance.store.hasJoiningRequest.value = false;
  }
}

