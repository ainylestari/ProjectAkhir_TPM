import 'package:flutter/material.dart';
import '../database.dart';
import '../services/session.dart';
import '../services/chat_service.dart';

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
  String? insight;
  bool isInsightLoading = false;

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

      insight = widget.journal!['insight'];
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
        'insight': insight ?? '',
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

  Future<void> generateInsight() async {
    final content = contentController.text.trim();
    if (content.isEmpty) {
      showMessage("Isi jurnal terlebih dahulu untuk dirangkum!");
      return;
    }

    setState(() {
      isInsightLoading = true;
    });

    try {
      final summary = await ChatService().summarizeJournal(content);
      setState(() {
        insight = summary;
      });
    } catch (e) {
      showMessage("Gagal merangkum jurnal: $e");
    } finally {
      setState(() {
        isInsightLoading = false;
      });
    }
  }

  Widget _buildInsightCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.purple.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "MoodMate AI Insight",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.purple,
                ),
              ),
              const Spacer(),
              if (insight != null && !isInsightLoading)
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.purple, size: 20),
                  onPressed: generateInsight,
                  tooltip: "Rangkum Ulang",
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isInsightLoading)
            const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "Sedang merangkum jurnal...",
                  style: TextStyle(
                    color: Colors.purple,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            )
          else if (insight == null || insight!.trim().isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Isi jurnalmu untuk mendapatkan insight dari AI!",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: generateInsight,
                    icon: const Icon(Icons.psychology, size: 18),
                    label: const Text("Rangkum Jurnal dengan AI"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple,
                      side: BorderSide(color: Colors.purple.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              insight!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
        ],
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
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
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

            _buildInsightCard(),

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