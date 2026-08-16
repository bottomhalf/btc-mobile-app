import 'package:flutter/foundation.dart';
import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/btcmeet_socket_service.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class IncomingCallHandler {
  void execute(ServerEventService service, CallIncomingEvent event) {
    final currentUser = BtcMeetSocketService.instance.localUser;

    if (currentUser != null && event.callerId == currentUser.userId) {
      debugPrint('[ServerEvents] Ignoring incoming call — I am the caller');
      return;
    }

    service.store.setRinging(event, CallStatus.ringing);
    debugPrint('[ServerEvents] Incoming call from: ${event.callerId}');
  }
}

