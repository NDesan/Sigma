enum MessageSender { user, coach }

class CoachMessage {
  final String text;
  final MessageSender sender;
  final DateTime timestamp;

  CoachMessage({
    required this.text,
    required this.sender,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
