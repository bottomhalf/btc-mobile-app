import 'package:flutter/foundation.dart';
import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class CallErrorHandler {
  void execute(ServerEventService service, CallErrorEvent event) {
    service.store.setFailed(CallStatus.failed);
    debugPrint('[ServerEvents] Call error: ${event.error}');
  }
}

