import 'package:conference_sdk/websocket/models/call_model.dart';
import 'package:conference_sdk/websocket/services/btcmeet_socket_service.dart';

class TestSignalService {
  void execute() {
    BtcMeetSocketService.instance.sendEvent(CallEvents.callTestSignal, {});
  }
}

