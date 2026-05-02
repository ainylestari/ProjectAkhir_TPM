import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database.dart';
import '../services/session.dart';
import '../models/user_model.dart';

class JournalDetailScreen extends StatefulWidget {
  final DateTime journaldetail;
  final Map<String, dynamic>? journal; // null = add, ada data = edit

  const JournalDetailScreen({
    super.key,
    required this.journaldetail,
    this.journal,
  });

  @override
  State<JournalDetailScreen> createState() =>
      _JournalDetailScreenState();
}

class _JournalDetailScreenState
    extends State<JournalDetailScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  bool isLoading = false;

  /// cek apakah mode edit
  bool get isEdit => widget.journal != null;

  @override
  void initState() {
    super.initState();

    /// kalau edit → isi field dengan data lama
    if (isEdit) {
      titleController.text =
          widget.journal!['title'] ?? '';

      contentController.text =
          widget.journal!['content'] ?? '';
    }
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> saveJournal() async {
    String title = titleController.text.trim();
    String content = contentController.text.trim();

    /// kalau edit → pakai tanggal lama
    /// kalau add → pakai tanggal sekarang
    String date = isEdit
        ? (widget.journal!['date'] ?? '')
        : formatDate(widget.journaldetail);

    if (title.isEmpty || content.isEmpty) {
      showMessage("Semua field wajib diisi");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      /// ambil user login dari session
      final user = await SessionManager().getUser();

      if (user == null) {
        showMessage("User belum login");
        return;
      }

      Map<String, dynamic> data = {
        'title': title,
        'content': content,
        'date': date,
        'image': '',
        'user_id': int.parse(user.id),
      };

      /// kalau edit → update
      if (isEdit) {
        await dbHelper.updateJournal(
          widget.journal!['id'],
          data,
        );

        showMessage("Journal berhasil diupdate");
      }

      /// kalau add → insert
      else {
        await dbHelper.insertJournal(data);

        showMessage("Journal berhasil disimpan");
      }

      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      showMessage(
        isEdit
            ? "Gagal mengupdate journal"
            : "Gagal menyimpan journal",
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String date = isEdit
        ? (widget.journal!['date'] ?? '')
        : formatDate(widget.journaldetail);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? "Edit Journal"
              : "Write Journal",
        ),
        backgroundColor: Color.fromARGB(255, 255, 244, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              "Date: $date",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            /// TITLE
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Journal Title",
                hintText: "How was your day?",
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// CONTENT
            TextField(
              controller: contentController,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: "Write your thoughts...",
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// SAVE / UPDATE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isLoading ? null : saveJournal,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            20),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        isEdit
                            ? "Update Journal"
                            : "Save Journal",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}