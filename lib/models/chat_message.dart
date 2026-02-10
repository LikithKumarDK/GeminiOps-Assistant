enum MessageRole { user, model }

class ChatMessage {
  final String text;
  final MessageRole role;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.role, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  // For serialization if needed
  Map<String, dynamic> toJson() => {
    'text': text,
    'role': role.name,
    'timestamp': timestamp.toIso8601String(),
  };
}
