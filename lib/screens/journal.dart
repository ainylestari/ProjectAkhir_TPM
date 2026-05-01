import 'package:flutter/material.dart';
import '../database.dart';
import 'journal_detail.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  List<Map<String, dynamic>> journals = [];

  @override
  void initState() {
    super.initState();
    fetchJournals();
  }

  Future<void> fetchJournals() async {
    final data = await dbHelper.getJournals();

    setState(() {
      journals = data;
    });
  }

  Future<void> deleteJournal(int id) async {
    await dbHelper.deleteJournal(id);

    fetchJournals();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Journal berhasil dihapus"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 30),

            const Text(
              "Journals",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Write down your thoughts and feelings",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            /// ADD NEW JOURNAL
            regCard(
              "Write New Journal",
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JournalDetailScreen(
                      journaldetail: DateTime.now(),
                    ),
                  ),
                );

                fetchJournals();
              },
              elementColor: Colors.white,
              bgColor: Colors.purple,
              bg2Color: Colors.pinkAccent,
            ),

            const SizedBox(height: 20),

            /// JOURNAL LIST
            journals.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada journal",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: journals.length,
                    itemBuilder: (context, index) {
                      final journal = journals[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(18),

                            /// ICON MOOD
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.auto_stories,
                                color: Colors.purple,
                                size: 28,
                              ),
                            ),

                            /// TITLE + CONTENT
                            title: Text(
                              journal['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    journal['content'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        journal['date'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            /// MENU EDIT DELETE
                            trailing: PopupMenuButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text("Edit"),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text("Hapus"),
                                ),
                              ],
                              onSelected: (value) async {
                                if (value == 'delete') {
                                  deleteJournal(journal['id']);
                                } else if (value == 'edit') {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => JournalDetailScreen(
                                        journaldetail: DateTime.now(),
                                        journal: journal,
                                      ),
                                    ),
                                  );

                                  fetchJournals();
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

/// CARD
Widget regCard(
  String title, {
  required VoidCallback onTap,
  Color elementColor = Colors.purple,
  Color bgColor = Colors.white,
  Color bg2Color = Colors.white,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 15),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [bgColor, bg2Color],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: elementColor,
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: elementColor,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}