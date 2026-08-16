import '../../../models/call_model.dart';
import '../../btcmeet_socket_service.dart';

Stream<Message> buildOutgoingMessageStream(BtcMeetSocketService service) {
  return service.messages$
      .where((e) => e.event == WsEvents.messageSent)
      .map((e) => Message.fromJson(e.payload as Map<String, dynamic>));
}
