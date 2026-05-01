import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'plannerDetail.dart';
import '../database.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  DateTime selectedDate = DateTime.now();

  String selectedCurrency = "IDR";
  String selectedTimezone = "WIB";

  List<Map<String, dynamic>> plannerList = [];

  final List<String> currencyList = [
    "IDR",
    "USD",
    "SGD",
    "EUR",
    "JPY",
    "KRW",
  ];

  final Map<String, double> currencyRates = {
    "IDR": 1,
    "USD": 16000,
    "SGD": 12000,
    "EUR": 17000,
    "JPY": 110,
    "KRW": 12,
  };

  final List<String> timezoneList = [
    "WIB",
    "WITA",
    "WIT",
    "London",
    "Singapore",
    "Tokyo",
    "Seoul",
  ];

  final Map<String, int> timezoneOffset = {
    "WIB": 7,
    "WITA": 8,
    "WIT": 9,
    "London": 0,
    "Singapore": 8,
    "Tokyo": 9,
    "Seoul": 9,
  };

  @override
  void initState() {
    super.initState();
    loadPlanner();
  }

  Future<void> loadPlanner() async {
    final data = await dbHelper.getPlannerByDate(
      DateFormat("dd/MM/yyyy").format(selectedDate),
    );

    setState(() {
      plannerList = data;
    });
  }

  void changeDate(int day) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: day));
    });

    loadPlanner();
  }

  String convertBudget(
    String amount,
    String fromCurrency,
  ) {
    try {
      double value =
          double.tryParse(amount) ?? 0;

      double fromRate =
          currencyRates[fromCurrency] ?? 1;

      double toRate =
          currencyRates[selectedCurrency] ?? 1;

      /// convert ke IDR dulu
      double idrValue =
          value * fromRate;

      /// lalu ke target currency
      double finalValue =
          idrValue / toRate;

      return finalValue
          .toStringAsFixed(0);
    } catch (e) {
      return amount;
    }
  }

  String convertTime(
    String originalTime,
    String fromTimezone,
  ) {
    try {
      final parts = originalTime.split(":");
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      int fromOffset = timezoneOffset[fromTimezone] ?? 7;
      int toOffset = timezoneOffset[selectedTimezone] ?? 7;

      int diff = toOffset - fromOffset;

      hour += diff;

      if (hour >= 24) hour -= 24;
      if (hour < 0) hour += 24;

      return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return originalTime;
    }
  }

  String getPeriodFromTime(String time) {
    try {
      int hour = int.parse(time.split(":")[0]);

      if (hour >= 5 && hour < 11) {
        return "Morning";
      } else if (hour >= 11 && hour < 15) {
        return "Afternoon";
      } else if (hour >= 15 && hour < 18) {
        return "Evening";
      } else {
        return "Night";
      }
    } catch (e) {
      return "Morning";
    }
  }

  List<Map<String, dynamic>> getPlannerByPeriod(
    String period,
  ) {
    return plannerList.where((item) {
      final convertedTime = convertTime(
        item['time'] ?? "09:00",
        item['timezone'] ?? "WIB",
      );

      final autoPeriod =
          getPeriodFromTime(convertedTime);

      return autoPeriod == period;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              /// TITLE
              const Text(
                "My Mood Plan",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Plan your activities day by day",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              /// DATE CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.05),
                      blurRadius: 12,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    circleButton(
                      icon:
                          Icons.chevron_left,
                      onTap: () =>
                          changeDate(-1),
                    ),
                    Column(
                      children: [
                        Text(
                          DateFormat(
                                      "dd/MM/yyyy")
                                  .format(
                                      selectedDate) ==
                              DateFormat(
                                      "dd/MM/yyyy")
                                  .format(
                                      DateTime
                                          .now())
                              ? "Today"
                              : DateFormat(
                                      "EEEE")
                                  .format(
                                      selectedDate),
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          DateFormat(
                                  "MMMM d, yyyy")
                              .format(
                                  selectedDate),
                          style:
                              const TextStyle(
                            color:
                                Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    circleButton(
                      icon:
                          Icons.chevron_right,
                      onTap: () =>
                          changeDate(1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// DROPDOWN CONVERT
              Row(
                children: [
                  Expanded(
                    child: topDropdownCard(
                      icon:
                          Icons.public,
                      value:
                          selectedTimezone,
                      items:
                          timezoneList,
                      onChanged:
                          (value) {
                        setState(() {
                          selectedTimezone =
                              value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: topDropdownCard(
                      icon:
                          Icons.attach_money,
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
                ],
              ),

              const SizedBox(height: 20),

              buildSection(
                title: "Morning",
                subtitle:
                    "05:00 AM - 10:59 AM",
                period: "Morning",
                bgColor:
                    const Color(0xFFF8EDB8),
                icon:
                    Icons.wb_sunny_outlined,
              ),

              buildSection(
                title: "Afternoon",
                subtitle:
                    "11:00 AM - 02:59 PM",
                period: "Afternoon",
                bgColor:
                    const Color(0xFFDDF4FF),
                icon:
                    Icons.light_mode_outlined,
              ),

              buildSection(
                title: "Evening",
                subtitle:
                    "03:00 PM - 05:59 PM",
                period: "Evening",
                bgColor:
                    const Color(0xFFFFE5CC),
                icon:
                    Icons.wb_twilight_outlined,
              ),

              buildSection(
                title: "Night",
                subtitle:
                    "06:00 PM - 04:59 AM",
                period: "Night",
                bgColor:
                    const Color(0xFFE8E5FF),
                icon:
                    Icons.nightlight_outlined,
              ),

              const SizedBox(height: 20),

              /// ADD PLAN BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result =
                        await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PlannerDetailScreen(
                          plannerdetail:
                              selectedDate,
                        ),
                      ),
                    );

                    if (result == true) {
                      loadPlanner();
                    }
                  },
                  style:
                      ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 18,
                    ),
                    backgroundColor:
                        Colors.purple,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  20),
                    ),
                  ),
                  child: const Text(
                    "+ Add to Mood Plan",
                    style: TextStyle(
                      color: Colors.white,
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

  Widget buildSection({
    required String title,
    required String subtitle,
    required String period,
    required Color bgColor,
    required IconData icon,
  }) {
    final items =
        getPlannerByPeriod(period);

    return Container(
      margin:
          const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius:
            BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius
                          .circular(16),
                ),
                child: Icon(icon),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        color:
                            Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...items.map((item) {
            final convertedTime = convertTime(
              item['time'] ?? "09:00",
              item['timezone'] ?? "WIB",
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TIME BOX
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      convertedTime,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  /// CONTENT
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] ?? "-",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          item['description'] ?? "",
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// BUDGET
                        Text(
                            item['budget'] == null ||
                                    item['budget']
                                        .toString()
                                        .isEmpty
                                ? "-"
                                : "$selectedCurrency ${convertBudget(
                                    item['budget'].toString(),
                                    item['currency'] ?? "IDR",
                                  )}",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(221, 57, 46, 215),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// MENU TITIK 3
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.black54,
                    ),
                    onSelected: (value) async {
                      if (value == "edit") {
                        final result =
                            await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PlannerDetailScreen(
                              plannerdetail:
                                  selectedDate,
                              planner: item,
                            ),
                          ),
                        );

                        if (result == true) {
                          loadPlanner();
                        }
                      }

                      if (value == "delete") {
                        await dbHelper.deletePlanner(
                          item['id'],
                        );

                        loadPlanner();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "edit",
                        child: Text("Edit"),
                      ),
                      const PopupMenuItem(
                        value: "delete",
                        child: Text("Delete"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget topDropdownCard({
    required IconData icon,
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
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.04),
            blurRadius: 8,
          )
        ],
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon:
            const Icon(Icons.keyboard_arrow_down),
        items: items.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: Colors.purple,
                ),
                const SizedBox(width: 8),
                Text(e),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF3E8FF),
          borderRadius:
              BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: Colors.purple,
        ),
      ),
    );
  }
}