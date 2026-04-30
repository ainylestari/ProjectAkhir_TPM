import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database.dart';

class PlannerDetailScreen extends StatefulWidget {
  final DateTime plannerdetail;
  final Map<String, dynamic>? planner; // null = add, ada data = edit

  const PlannerDetailScreen({
    super.key,
    required this.plannerdetail,
    this.planner,
  });

  @override
  State<PlannerDetailScreen> createState() =>
      _PlannerDetailScreenState();
}

class _PlannerDetailScreenState
    extends State<PlannerDetailScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final timeController = TextEditingController();

  String selectedPeriod = "Morning";

  bool isLoading = false;

  /// mode edit
  bool get isEdit => widget.planner != null;

  @override
  void initState() {
    super.initState();

    /// kalau edit → isi data lama
    if (isEdit) {
      titleController.text =
          widget.planner!['title'] ?? '';

      descriptionController.text =
          widget.planner!['description'] ?? '';

      timeController.text =
          widget.planner!['time'] ?? '';

      selectedPeriod =
          widget.planner!['period'] ?? 'Morning';
    }
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> savePlanner() async {
    String title = titleController.text.trim();
    String description =
        descriptionController.text.trim();
    String time = timeController.text.trim();

    /// edit → pakai tanggal lama
    /// add → pakai tanggal baru
    String date = isEdit
        ? (widget.planner!['date'] ?? '')
        : formatDate(widget.plannerdetail);

    if (title.isEmpty ||
        description.isEmpty ||
        time.isEmpty) {
      showMessage("Semua field wajib diisi");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      /// ambil session login
      final prefs =
          await SharedPreferences.getInstance();

      int userId =
          prefs.getInt('user_id') ?? 0;

      if (userId == 0) {
        showMessage("User belum login");
        return;
      }

      Map<String, dynamic> data = {
        'title': title,
        'description': description,
        'time': time,
        'period': selectedPeriod,
        'date': date,
        'user_id': userId,
      };

      /// UPDATE
      if (isEdit) {
        await dbHelper.updatePlanner(
          widget.planner!['id'],
          data,
        );

        showMessage(
          "Planner berhasil diupdate",
        );
      }

      /// INSERT
      else {
        await dbHelper.insertPlanner(data);

        showMessage(
          "Planner berhasil disimpan",
        );
      }

      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      showMessage(
        isEdit
            ? "Gagal update planner"
            : "Gagal simpan planner",
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
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String date = isEdit
        ? (widget.planner!['date'] ?? '')
        : formatDate(widget.plannerdetail);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? "Edit Activity"
              : "Add Activity",
        ),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
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
                  labelText: "Activity Title",
                  hintText:
                      "Example: Morning Walk",
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                            16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// DESCRIPTION
              TextField(
                controller:
                    descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Description",
                  hintText:
                      "Describe your activity...",
                  alignLabelWithHint: true,
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                            16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// TIME
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: "Time",
                  hintText:
                      "Example: 07:00",
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                            16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// PERIOD DROPDOWN
              DropdownButtonFormField<String>(
                value: selectedPeriod,
                decoration: InputDecoration(
                  labelText: "Period",
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                            16),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Morning",
                    child: Text("Morning"),
                  ),
                  DropdownMenuItem(
                    value: "Afternoon",
                    child: Text("Afternoon"),
                  ),
                  DropdownMenuItem(
                    value: "Evening",
                    child: Text("Evening"),
                  ),
                  DropdownMenuItem(
                    value: "Night",
                    child: Text("Night"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedPeriod = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : savePlanner,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red,
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
                          color:
                              Colors.white,
                        )
                      : Text(
                          isEdit
                              ? "Update Activity"
                              : "Save Activity",
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}