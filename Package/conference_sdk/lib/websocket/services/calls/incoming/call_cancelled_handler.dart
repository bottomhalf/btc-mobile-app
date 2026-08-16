import 'package:flutter/foundation.dart';
import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class CallCancelledHandler {
  void execute(ServerEventService service, CallCancelledEvent event) {
    service.store.setCancelled(CallStatus.cancelled);
    debugPrint('[ServerEvents] Call cancelled by: ${event.cancelledBy}');
  }
}

