import 'package:flutter/foundation.dart';
import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class CallEndedHandler {
  void execute(ServerEventService service, CallEndedEvent event) {
    service.store.setEnded(CallStatus.ended);
    debugPrint('[ServerEvents] Call ended by: ${event.endedBy} | Duration: ${event.duration}');
  }
}

