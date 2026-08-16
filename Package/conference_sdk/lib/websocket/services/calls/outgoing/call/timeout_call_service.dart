import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/btcmeet_socket_service.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class TimeoutCallService {
  void execute(String conversationId, String callerId) {
    BtcMeetSocketService.instance.sendEvent(
      CallEvents.callTimeout,
      CallTimeoutPayload(conversationId: conversationId, callerId: callerId).toJson(),
    );
    ServerEventService.instance.store.callStatus.value = CallStatus.timeout;
  }
}

