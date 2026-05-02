import 'package:tpm_tugasakhir/database.dart';
import 'package:flutter/material.dart';
import '../services/session.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';
import '../models/chat_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();

  UserModel? currentUser;
  bool _isLoading = false;
  

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  String _formatDateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dt.year, dt.month, dt.day);

    if (msgDate == today) return "Hari ini";
    if (msgDate == yesterday) return "Kemarin";
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  bool _isDifferentDay(int index) {
    if (index == 0) return true;
    final curr = _messages[index].timestamp;
    final prev = _messages[index - 1].timestamp;
    return DateTime(curr.year, curr.month, curr.day) !=
        DateTime(prev.year, prev.month, prev.day);
  }


  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = await SessionManager().getUser();
    if (!mounted) return;
    
    // load history dari database
    final history = await DatabaseHelper.instance.getChatHistory(user?.email ?? '');
    
    setState(() {
      currentUser = user;
      _messages.addAll(history.map((e) => ChatMessage(
        text: e['message'] as String,
        role: e['role'] as String,
        timestamp: DateTime.now(),
      )));
    });

    if (_messages.isEmpty) {
      final welcomeMsg = "Halo ${user?.username ?? 'User'}, apa yang kamu rasakan hari ini?";
    
      await DatabaseHelper.instance.insertChat({
        'email': user?.email ?? '',
        'role': 'ai',
        'message': welcomeMsg,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: welcomeMsg,
          role: "ai",
          timestamp: DateTime.now(),
        ));
      });
    };
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String userMsg = _messageController.text.trim();
    setState(() {
      _messages.add(ChatMessage(
        text: userMsg,
        role: "user",
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    final reply = await _chatService.sendMessage(userMsg);
    
    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(
        text: reply,
        role: "ai",
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
    });

    // simpan ke DB
    await DatabaseHelper.instance.insertChat({
      'email': currentUser?.email ?? '',
      'role': 'user',
      'message': userMsg,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await DatabaseHelper.instance.insertChat({
      'email': currentUser?.email ?? '',
      'role': 'ai',
      'message': reply,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _clearHistory() async {
    await DatabaseHelper.instance.clearChat(currentUser?.email ?? '');
    _chatService.clearHistory();
    
    final welcomeMsg = "Halo ${currentUser?.username ?? 'User'}, apa yang kamu rasakan hari ini?";
    
    await DatabaseHelper.instance.insertChat({
      'email': currentUser?.email ?? '',
      'role': 'ai',
      'message': welcomeMsg,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;
    setState(() {
      _messages.clear();
      _messages.add(ChatMessage(
        text: welcomeMsg,
        role: "ai",
        timestamp: DateTime.now(),
      ));
    });
  }

  // animasi scroll bawah
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MoodMate AI", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.purple,

        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Hapus History"),
                  content: const Text("Yakin mau hapus semua chat?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearHistory();
                      },
                      child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true, // biar scroll dari bawah
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[_messages.length - 1 - index];
                final isUser = msg.role == "user";
                return Column(
                  children: [
                    if (_isDifferentDay(_messages.length - 1 - index))
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                _formatDateLabel(msg.timestamp),
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                      ),
                    _buildChatBubble(msg.text, isUser, msg.timestamp),
                  ],
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(color: Colors.purple),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser, DateTime timestamp) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(  
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? Colors.purple : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 0),
                bottomRight: Radius.circular(isUser ? 0 : 20),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(color: isUser ? Colors.white : Colors.black87),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
            child: Text(
              _formatTime(timestamp),
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)
      ]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Ketik pesan...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.purple,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}