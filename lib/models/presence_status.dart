enum PresenceStatus {
  unspecified(0),
  online(1),
  offline(2),
  away(3),
  busy(4),
  dnd(5),
  invisible(6);

  final int value;
  const PresenceStatus(this.value);

  factory PresenceStatus.fromValue(dynamic value) {
    if (value == null) return PresenceStatus.unspecified;
    if (value is int) {
      return PresenceStatus.values.firstWhere(
        (element) => element.value == value,
        orElse: () => PresenceStatus.unspecified,
      );
    } else if (value is String) {
      final intVal = int.tryParse(value);
      if (intVal != null) {
        return PresenceStatus.values.firstWhere(
          (element) => element.value == intVal,
          orElse: () => PresenceStatus.unspecified,
        );
      }
      final normalized = value.trim().toLowerCase();
      return PresenceStatus.values.firstWhere(
        (element) => element.name.toLowerCase() == normalized,
        orElse: () => PresenceStatus.unspecified,
      );
    }
    return PresenceStatus.unspecified;
  }
}