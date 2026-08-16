import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/btcmeet_socket_service.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class AcceptCallService {
  void execute(String conversationId, String callerId) {
    BtcMeetSocketService.instance.sendEvent(
      CallEvents.callAccept,
      CallAcceptPayload(conversationId: conversationId, callerId: callerId).toJson(),
    );
    ServerEventService.instance.store.hasIncomingCall.value = false;
    ServerEventService.instance.store.callStatus.value = CallStatus.accepted;
  }
}

