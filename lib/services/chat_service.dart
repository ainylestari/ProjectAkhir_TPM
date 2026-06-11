import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatService {
  final String apiKey = dotenv.env['groq_api'] ?? '';
  
  final List<Map<String, String>> _history = [
    {
      "role": "system",
      "content": "Nama kamu adalah MoodMate AI. Kamu adalah asisten yang empati, "
          "mendukung, dan ramah untuk membantu pengguna mengelola suasana hati mereka. "
          "Gunakan bahasa Indonesia yang santai tapi sopan."
    }
  ];

  void clearHistory() {
  _history.removeWhere((e) => e['role'] != 'system');
  }

  Future<String> sendMessage(String message) async {
    _history.add({"role": "user", "content": message});

    try {
      final response = await http.post(
        Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": _history,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        _history.add({"role": "assistant", "content": reply});
        return reply;
      } else {
        print("GROQ ERROR: ${response.body}");
        return "Maaf, ada masalah koneksi. Coba lagi ya!";
      }
    } catch (e) {
      print("GROQ ERROR: $e");
      return "Waduh, koneksi ke MoodMate AI lagi bermasalah nih. Coba lagi ya!";
    }
  }

  Future<String> summarizeJournal(String content) async {
    try {
      final response = await http.post(
        Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content": "Kamu adalah asisten AI yang empati. Tugasmu adalah membuat rangkuman singkat (maksimal 2-3 kalimat) dari jurnal harian berikut. Kemudian berikan refleksi positif atau saran yang membina di akhir rangkuman. Gunakan bahasa Indonesia yang ramah. Jangan membuat paragraf terlalu panjang."
            },
            {
              "role": "user",
              "content": content,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        return reply.trim();
      } else {
        print("GROQ ERROR: ${response.body}");
        return "Gagal mendapatkan insight dari Groq AI.";
      }
    } catch (e) {
      print("GROQ ERROR: $e");
      return "Koneksi ke Groq AI bermasalah.";
    }
  }
}