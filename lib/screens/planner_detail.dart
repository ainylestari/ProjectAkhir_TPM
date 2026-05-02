import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database.dart';
import '../services/session.dart';
import '../services/notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

class PlannerDetailScreen extends StatefulWidget {
  final DateTime plannerdetail;
  final Map<String, dynamic>? planner;

  const PlannerDetailScreen({
    super.key,
    required this.plannerdetail,
    this.planner,
  });

  @override
  State<PlannerDetailScreen> createState() => _PlannerDetailScreenState();
}

class _PlannerDetailScreenState extends State<PlannerDetailScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final timeController = TextEditingController();
  final budgetController = TextEditingController();

  String selectedCurrency = "IDR";
  String selectedTimezone = "Asia/Jakarta";
  String selectedPeriod = "Morning";

  bool isLoading = false;

  List<String> currencyList = ["IDR"];
  List<String> timezoneList = ["Asia/Jakarta"];

  bool get isEdit => widget.planner != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      titleController.text = widget.planner!['title'] ?? '';
      descriptionController.text = widget.planner!['description'] ?? '';
      timeController.text = widget.planner!['time'] ?? '';
      budgetController.text = widget.planner!['budget']?.toString() ?? '';
      selectedPeriod = widget.planner!['period'] ?? "Morning";
    

      selectedTimezone = widget.planner!['timezone'] ?? "Asia/Jakarta";
      selectedCurrency = widget.planner!['currency'] ?? "IDR";
    }
    _initDynamicData();
  }

  Future<void> _initDynamicData() async {
   // time zone
    tzdata.initializeTimeZones();
    List<String> loadedTimezones = tz.timeZoneDatabase.locations.keys.toList();

    String detectedZone = "Asia/Jakarta";

    List<String> loadedCurrencies = ["IDR"];
      try {
        final response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/IDR'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          loadedCurrencies = (data['rates'] as Map<String, dynamic>).keys.toList();
        }
      } catch (e) {
        debugPrint("Gagal load API Mata Uang di Detail: $e");
      }

      if (mounted) {
        setState(() {
          timezoneList = loadedTimezones;
          currencyList = loadedCurrencies;

          if (!isEdit) {
            selectedTimezone = timezoneList.contains(detectedZone) ? detectedZone : "Asia/Jakarta";
          } else {
            if (!timezoneList.contains(selectedTimezone)) timezoneList.add(selectedTimezone);
            if (!currencyList.contains(selectedCurrency)) currencyList.add(selectedCurrency);
          }
        });
      }
    }

  String formatDate(DateTime date) {
    return DateFormat("dd/MM/yyyy").format(date);
  }

  Future<void> pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
      final formatted = DateFormat("HH:mm").format(selected);

      setState(() {
        timeController.text = formatted;

        if (picked.hour >= 5 && picked.hour < 11) {
          selectedPeriod = "Morning";
        } else if (picked.hour >= 11 && picked.hour < 15) {
          selectedPeriod = "Afternoon";
        } else if (picked.hour >= 15 && picked.hour < 18) {
          selectedPeriod = "Evening";
        } else {
          selectedPeriod = "Night";
        }
      });
    }
  }

  Future<void> savePlanner() async {
    if (titleController.text.isEmpty || timeController.text.isEmpty) {
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
      debugPrint("ERROR SAVE PLANNER: $e");
      showMessage("Failed to save planner");
    }

    setState(() {
      isLoading = false;
    });
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final date = isEdit
        ? widget.planner!['date']
        : formatDate(
            widget.plannerdetail);

    return Scaffold(
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
                    Icon(Icons.arrow_back_ios, size: 16),
                    Text("Back to Mood Plan"),
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
              /// TIMEZONE
              buildLabel("Timezone"),

              _searchableButton(
                icon: Icons.access_time,
                value: selectedTimezone,
                onTap: () => _showSearchDialog(
                  title: "Pilih Timezone",
                  items: timezoneList,
                  selected: selectedTimezone,
                  onSelected: (value) => setState(() => selectedTimezone = value),
                ),
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
                    child: _searchableButton(
                      icon: Icons.attach_money,
                      value: selectedCurrency,
                      onTap: () => _showSearchDialog(
                        title: "Pilih Currency",
                        items: currencyList,
                        selected: selectedCurrency,
                        onSelected: (value) => setState(() => selectedCurrency = value),
                      ),
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

  // search timezone dan currency
  void _showSearchDialog({
  required String title,
  required List<String> items,
  required String selected,
  required Function(String) onSelected,
}) {
  String searchQuery = '';
  List<String> filtered = List.from(items);

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        searchQuery = value.toLowerCase();
                        filtered = items
                            .where((e) => e.toLowerCase().contains(searchQuery))
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return ListTile(
                          title: Text(item),
                          selected: item == selected,
                          selectedColor: Colors.purple,
                          onTap: () {
                            onSelected(item);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  Widget _searchableButton({
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.purple),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
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
          menuMaxHeight: 300,
          items: items.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(
                e, 
                overflow: TextOverflow.ellipsis, // Menahan teks meluber
              ),
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
