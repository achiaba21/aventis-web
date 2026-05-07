enum NotificationEvent {
  reservation('RERSERVATION'),
  message('MESSAGE'),
  notification('NOTIFICATION');

  const NotificationEvent(this.value);
  final String value;

  static NotificationEvent fromString(String value) {
    return NotificationEvent.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationEvent.notification,
    );
  }
}
