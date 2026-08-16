import 'package:flutter/foundation.dart';
import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class CallRejectedHandler {
  void execute(ServerEventService service, CallRejectedEvent event) {
    service.store.setRejected(CallStatus.rejected);
    debugPrint('[ServerEvents] Call rejected by: ${event.rejectedBy}');
  }
}

