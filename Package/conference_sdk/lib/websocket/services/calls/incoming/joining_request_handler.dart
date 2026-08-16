import 'package:flutter/foundation.dart';
import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/btcmeet_socket_service.dart';
import 'package:conference_sdk/websocket/services/server_event_service.dart';

class JoiningRequestHandler {
  void execute(ServerEventService service, CallIncomingEvent event) {
    final currentUser = BtcMeetSocketService.instance.localUser;

    service.store.setParticipantsInRoom(event.participants);

    if (currentUser != null && event.callerId == currentUser.userId) {
      debugPrint('[ServerEvents] Ignoring joining request — I am the caller');
      return;
    }

    service.store.setJoiningRequest(event, CallStatus.joiningRequest);
    debugPrint('[ServerEvents] Joining request from: ${event.callerId}');
  }
}

