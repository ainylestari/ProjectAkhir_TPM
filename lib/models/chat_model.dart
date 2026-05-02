class ChatMessage {
  final String text;
  final String role; // 'user' atau 'ai'
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.role,
    required this.timestamp,
  });

  // Untuk simpan ke database atau log
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'role': role,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Untuk ambil data dari database
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'],
      role: map['role'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}