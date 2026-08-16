import '../../../models/call_model.dart';
import '../../btcmeet_socket_service.dart';

Stream<Message> buildIncomingMessageStream(BtcMeetSocketService service) {
  return service.messages$
      .where((e) => e.event == WsEvents.newMessage)
      .map((e) => Message.fromJson(e.payload as Map<String, dynamic>));
}

Stream<MessageDelivered> buildDeliveredStream(BtcMeetSocketService service) {
  return service.messages$
      .where((e) => e.event == WsEvents.delivered)
      .map((e) => MessageDelivered.fromJson(e.payload as Map<String, dynamic>));
}

Stream<MessageSeen> buildSeenStream(BtcMeetSocketService service) {
  return service.messages$
      .where((e) => e.event == WsEvents.seen)
      .map((e) => MessageSeen.fromJson(e.payload as Map<String, dynamic>));
}

Stream<TypingIndicator> buildUserTypingStream(BtcMeetSocketService service) {
  return service.messages$
      .where((e) => e.event == WsEvents.userTyping)
      .map((e) => TypingIndicator.fromJson(e.payload as Map<String, dynamic>));
}

Stream<ErrorPayload> buildErrorStream(BtcMeetSocketService service) {
  return service.messages$
      .where((e) => e.event == WsEvents.error)
      .map((e) => ErrorPayload.fromJson(e.payload as Map<String, dynamic>));
}

Stream<PongPayload> buildPongStream(BtcMeetSocketService service) {
  return service.messages$
      .where((e) => e.event == WsEvents.pong)
      .map((e) => PongPayload.fromJson(e.payload as Map<String, dynamic>));
}

Stream<Map<String, dynamic>> buildInitUserListStream(BtcMeetSocketService service) {
  return service.messages$
      .where((e) => e.event == WsEvents.initUserlist)
      .map((e) => e.payload as Map<String, dynamic>);
}

Stream<dynamic> buildMessageReactedStream(BtcMeetSocketService service) {
  return service.messages$
      .where((e) => e.event == WsEvents.messageReacted)
      .map((e) => e.payload);
}

Stream<dynamic> buildUserStatusStream(BtcMeetSocketService service) {
  return service.messages$
      .where((e) => e.event == WsEvents.userStatus)
      .map((e) => e.payload);
}
