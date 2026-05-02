import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database.dart';
import '../services/session.dart';
import '../services/notification_service.dart';

class PlannerDetailScreen extends StatefulWidget {
  final DateTime plannerdetail;
  final Map<String, dynamic>? planner;

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
  final DatabaseHelper dbHelper =
      DatabaseHelper.instance;

  final titleController =
      TextEditingController();
  final descriptionController =
      TextEditingController();
  final timeController =
      TextEditingController();
  final budgetController =
      TextEditingController();

  String selectedCurrency = "IDR";
  String selectedTimezone = "WIB";
  String selectedPeriod = "Morning";

  bool isLoading = false;

  final List<String> currencyList = [
    "IDR",
    "USD",
    "SGD",
    "EUR",
    "JPY",
    "KRW",
  ];

  final List<String> timezoneList = [
    "WIB",
    "WITA",
    "WIT",
    "London",
    "Singapore",
    "Tokyo",
    "Seoul",
  ];

  bool get isEdit =>
      widget.planner != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      titleController.text =
          widget.planner!['title'] ?? '';

      descriptionController.text =
          widget.planner!['description'] ?? '';

      timeController.text =
          widget.planner!['time'] ?? '';

      budgetController.text =
          widget.planner!['budget']?.toString() ??
              '';

      selectedCurrency =
          widget.planner!['currency'] ??
              "IDR";

      selectedTimezone =
          widget.planner!['timezone'] ??
              "WIB";

      selectedPeriod =
          widget.planner!['period'] ??
              "Morning";
    }
  }

  String formatDate(DateTime date) {
    return DateFormat(
      "dd/MM/yyyy",
    ).format(date);
  }

  Future<void> pickTime() async {
    TimeOfDay? picked =
        await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.now(),
    );

    if (picked != null) {
      final now = DateTime.now();

      final selected = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      final formatted =
          DateFormat("HH:mm")
              .format(selected);

      setState(() {
        timeController.text =
            formatted;

        if (picked.hour >= 5 &&
            picked.hour < 11) {
          selectedPeriod =
              "Morning";
        } else if (picked.hour >= 11 &&
            picked.hour < 15) {
          selectedPeriod =
              "Afternoon";
        } else if (picked.hour >= 15 &&
            picked.hour < 18) {
          selectedPeriod =
              "Evening";
        } else {
          selectedPeriod =
              "Night";
        }
      });
    }
  }

  Future<void> savePlanner() async {
    if (titleController.text.isEmpty ||
        timeController.text.isEmpty) {
      showMessage(
        "Please fill required fields",
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = await SessionManager().getUser();

      if (user == null) {
        showMessage("User belum login");
        return;
      }

      final String plannerDate = isEdit 
        ? widget.planner!['date'] 
        : formatDate(widget.plannerdetail);

      final Map<String, dynamic> data = {
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "time": timeController.text.trim(),
        "period": selectedPeriod,
        "budget": budgetController.text.trim(),
        "currency": selectedCurrency,
        "timezone": selectedTimezone,
        "date": plannerDate,
        "user_id": int.parse(user.id),
      };

      int result;
      
      if (isEdit) {
        result = await dbHelper.updatePlanner(widget.planner!['id'], data);
      } else {
        result = await dbHelper.insertPlanner(data);
      }

      if (result > 0) {
        await NotificationService.schedulePlannerNotification(
          id: result, // pakai result sebagai id notifikasi
          title: titleController.text.trim(),
          date: plannerDate,
          time: timeController.text.trim(),
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      print(
          "ERROR SAVE PLANNER: $e");
      showMessage(
        "Failed to save planner",
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = isEdit
        ? widget.planner!['date']
        : formatDate(
            widget.plannerdetail);

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F3FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              /// BACK
              GestureDetector(
                onTap: () {
                  Navigator.pop(
                      context);
                },
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                    ),
                    Text(
                      "Back to Mood Plan",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// TITLE
              Text(
                isEdit
                    ? "Edit Activity"
                    : "Add Activity",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Plan your daily activities for better mood",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              /// DATE
              buildLabel("Date"),

              buildReadOnlyCard(date),

              const SizedBox(height: 20),

              /// TIME
              buildLabel("Time"),

              GestureDetector(
                onTap: pickTime,
                child: buildReadOnlyCard(
                  timeController
                          .text.isEmpty
                      ? "Select Time"
                      : timeController.text,
                ),
              ),

              const SizedBox(height: 20),

              /// TIMEZONE
              buildLabel("Timezone"),

              buildDropdownCard(
                value: selectedTimezone,
                items: timezoneList,
                onChanged: (value) {
                  setState(() {
                    selectedTimezone =
                        value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              /// PERIOD AUTO
              buildLabel(
                "Period (Auto-detected)",
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: periodCard(
                      "Morning",
                      "5AM - 10:59AM",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: periodCard(
                      "Afternoon",
                      "11AM - 2:59PM",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: periodCard(
                      "Evening",
                      "3PM - 5:59PM",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: periodCard(
                      "Night",
                      "6PM - 4:59AM",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// TITLE INPUT
              buildLabel("Activity Name"),

              buildTextField(
                controller:
                    titleController,
                hint:
                    "e.g. Morning yoga session",
              ),

              const SizedBox(height: 20),

              /// DESCRIPTION
              buildLabel(
                "Description (Optional)",
              ),

              buildTextField(
                controller:
                    descriptionController,
                hint:
                    "Add notes or details...",
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              /// BUDGET
              buildLabel(
                "Budget (Optional)",
              ),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child:
                        buildDropdownCard(
                      value:
                          selectedCurrency,
                      items:
                          currencyList,
                      onChanged:
                          (value) {
                        setState(() {
                          selectedCurrency =
                              value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child:
                        buildTextField(
                      controller:
                          budgetController,
                      hint:
                          "100000",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// SAVE BUTTON
              SizedBox(
                width:
                    double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : savePlanner,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.purple,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 18,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  20),
                    ),
                  ),
                  child: Text(
                    isLoading
                        ? "Saving..."
                        : isEdit
                            ? "Update Activity"
                            : "+ Add to Mood Plan",
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontWeight:
                          FontWeight.bold,
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

  Widget buildLabel(String title) {
    return Padding(
      padding:
          const EdgeInsets.only(
              bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight:
              FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget buildReadOnlyCard(
      String text) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(text),
    );
  }

  Widget buildTextField({
    required TextEditingController
        controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  20),
          borderSide:
              BorderSide.none,
        ),
      ),
    );
  }

  Widget buildDropdownCard({
    required String value,
    required List<String> items,
    required Function(String?)
        onChanged,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child:
          DropdownButtonHideUnderline(
        child:
            DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(e),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget periodCard(
    String title,
    String time,
  ) {
    final isActive =
        selectedPeriod == title;

    return Container(
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(
                0xFFF8EDB8)
            : Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? Colors.purple
              : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}