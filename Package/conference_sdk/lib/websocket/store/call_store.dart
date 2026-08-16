import 'package:flutter/foundation.dart';
import '../models/call_model.dart';

class CallStore {
  // ─── Singleton Pattern ──────────────────────────────────────────
  CallStore._();
  static final CallStore instance = CallStore._();

  // ─── State Properties (using ValueNotifier for reactivity) ──────
  final ValueNotifier<int?> callStatus = ValueNotifier<int?>(null);
  final ValueNotifier<List<CallParticipant>> participantsInRoom = ValueNotifier<List<CallParticipant>>([]);
  final ValueNotifier<bool> hasIncomingCall = ValueNotifier<bool>(false);
  final ValueNotifier<bool> hasJoiningRequest = ValueNotifier<bool>(false);
  final ValueNotifier<CallIncomingEvent?> incomingCall = ValueNotifier<CallIncomingEvent?>(null);
  final ValueNotifier<GroupNotificationEvent?> groupNotification = ValueNotifier<GroupNotificationEvent?>(null);

  // ─── State Mutation Methods ─────────────────────────────────────

  void setRinging(CallIncomingEvent event, int status) {
    incomingCall.value = event;
    hasIncomingCall.value = true;
    callStatus.value = status;
  }

  void setJoiningRequest(CallIncomingEvent event, int status) {
    incomingCall.value = event;
    hasJoiningRequest.value = true;
    callStatus.value = status;
  }

  void setParticipantsInRoom(Map<String, CallParticipant> participants) {
    participantsInRoom.value = participants.values.toList();
  }

  void setAccepted(int status) {
    callStatus.value = status;
  }

  void setRejected(int status) {
    callStatus.value = status;
    hasIncomingCall.value = false;
    incomingCall.value = null;
  }

  void setCancelled(int status) {
    callStatus.value = status;
    hasIncomingCall.value = false;
    incomingCall.value = null;
  }

  void setTimedOut(int status) {
    callStatus.value = status;
    hasIncomingCall.value = false;
    incomingCall.value = null;
  }

  void setEnded(int status) {
    callStatus.value = status;
    hasIncomingCall.value = false;
    incomingCall.value = null;
  }

  void setBusy(int status) {
    callStatus.value = status;
    hasIncomingCall.value = false;
    incomingCall.value = null;
  }

  void setFailed(int status) {
    callStatus.value = status;
    hasIncomingCall.value = false;
    incomingCall.value = null;
  }

  void setDismissed() {
    // Intentionally empty; extend if UI needs to react to this
  }

  void setGroupNotification(GroupNotificationEvent event) {
    groupNotification.value = event;
  }

  void reset() {
    callStatus.value = null;
    participantsInRoom.value = [];
    hasIncomingCall.value = false;
    hasJoiningRequest.value = false;
    incomingCall.value = null;
    groupNotification.value = null;
  }
}
