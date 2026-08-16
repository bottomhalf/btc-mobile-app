import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/btcmeet_socket_service.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class RejectCallService {
  void execute(String conversationId, String callerId, {String? reason}) {
    BtcMeetSocketService.instance.sendEvent(
      CallEvents.callReject,
      CallRejectPayload(conversationId: conversationId, callerId: callerId, reason: reason).toJson(),
    );
    ServerEventService.instance.store.hasIncomingCall.value = false;
    ServerEventService.instance.store.callStatus.value = CallStatus.rejected;
  }
}

