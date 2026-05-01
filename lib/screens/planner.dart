import 'package:flutter/material.dart';
import '/screens/plannerDetail.dart';
import 'package:intl/intl.dart';
import '../database.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() =>
      _PlannerScreenState();
}

class _PlannerScreenState
    extends State<PlannerScreen> {
  final DatabaseHelper dbHelper =
      DatabaseHelper.instance;

  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> planners = [];

  @override
  void initState() {
    super.initState();
    loadPlanners();
  }

  Future<void> loadPlanners() async {
    final data =
        await dbHelper.getPlanners();

    setState(() {
      planners = data;
    });
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(
        Duration(days: days),
      );
    });
  }

  Future<void> deletePlanner(int id) async {
    await dbHelper.deletePlanner(id);

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Planner berhasil dihapus",
        ),
      ),
    );

    loadPlanners();
  }

  List<Map<String, dynamic>> getByPeriod(
      String period) {
    return planners.where((item) {
      return item['period'] == period &&
          item['date'] ==
              DateFormat(
                'yyyy-MM-dd',
              ).format(_selectedDate);
    }).toList();
  }

  Widget buildPlannerSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required List<Map<String, dynamic>>
        items,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
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
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                          18),
                ),
                child: Icon(icon),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (items.isEmpty)
            const Text(
              "Belum ada activity",
            ),

          ...items.map(
            (planner) => Container(
              margin:
                  const EdgeInsets.only(
                      bottom: 14),
              padding:
                  const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius:
                    BorderRadius.circular(
                        22),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                    child: Text(
                      planner['time'] ??
                          '',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Colors.purple,
                      ),
                    ),
                  ),

                  const SizedBox(width: 18),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          planner['title'] ??
                              '',
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        const SizedBox(
                            height: 6),
                        Text(
                          planner['description'] ??
                              '',
                          style:
                              const TextStyle(
                            color:
                                Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  PopupMenuButton(
                    onSelected:
                        (value) async {
                      if (value ==
                          'delete') {
                        deletePlanner(
                          planner['id'],
                        );
                      } else {
                        final result =
                            await Navigator
                                .push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    PlannerDetailScreen(
                              plannerdetail:
                                  _selectedDate,
                              planner:
                                  planner,
                            ),
                          ),
                        );

                        if (result ==
                            true) {
                          loadPlanners();
                        }
                      }
                    },
                    itemBuilder:
                        (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child:
                            Text("Edit"),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child:
                            Text("Delete"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            /// HEADER LAMA TETAP ADA
            const Text(
              "Mood Plan",
              style: TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Plan your activities day by day",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            /// DATE SWITCHER LAMA TETAP ADA
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                        30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.1),
                    blurRadius: 10,
                    offset:
                        const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  IconButton(
                    onPressed:
                        () =>
                            _changeDate(-1),
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.red,
                    ),
                    style:
                        IconButton.styleFrom(
                      backgroundColor:
                          Colors.red
                              .withOpacity(
                                  0.1),
                    ),
                  ),

                  Column(
                    children: [
                      Text(
                        DateFormat(
                                    'yyyyMMdd')
                                .format(
                                    _selectedDate) ==
                            DateFormat(
                                    'yyyyMMdd')
                                .format(
                                    DateTime
                                        .now())
                        ? "Today"
                        : DateFormat(
                                'EEEE')
                            .format(
                                _selectedDate),
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                      Text(
                        DateFormat(
                                'MMMM d, yyyy')
                            .format(
                                _selectedDate),
                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  IconButton(
                    onPressed:
                        () =>
                            _changeDate(1),
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Colors.red,
                    ),
                    style:
                        IconButton.styleFrom(
                      backgroundColor:
                          Colors.red
                              .withOpacity(
                                  0.1),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// BUTTON LAMA TETAP ADA
            regCard(
              "Schedule Activity",
              onTap: () async {
                final result =
                    await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) =>
                            PlannerDetailScreen(
                      plannerdetail:
                          _selectedDate,
                    ),
                  ),
                );

                if (result == true) {
                  loadPlanners();
                }
              },
              elementColor:
                  Colors.white,
              bgColor: Colors.purple,
              bg2Color:
                  Colors.pinkAccent,
            ),

            const SizedBox(height: 20),

            /// UI BARU
            buildPlannerSection(
              title: "Morning",
              subtitle:
                  "6:00 AM - 12:00 PM",
              icon:
                  Icons.wb_sunny_outlined,
              bgColor:
                  const Color(0xFFF8EFCB),
              items:
                  getByPeriod("Morning"),
            ),

            buildPlannerSection(
              title: "Afternoon",
              subtitle:
                  "12:00 PM - 6:00 PM",
              icon: Icons.sunny,
              bgColor:
                  const Color(0xFFDCEFFC),
              items: getByPeriod(
                  "Afternoon"),
            ),

            buildPlannerSection(
              title: "Evening",
              subtitle:
                  "6:00 PM - 9:00 PM",
              icon:
                  Icons.dark_mode_outlined,
              bgColor:
                  const Color(0xFFFFE0E0),
              items:
                  getByPeriod("Evening"),
            ),

            buildPlannerSection(
              title: "Night",
              subtitle:
                  "9:00 PM - 12:00 AM",
              icon:
                  Icons.nightlight_round,
              bgColor:
                  const Color(0xFFE9E1FF),
              items:
                  getByPeriod("Night"),
            ),
          ],
        ),
      ),
    );
  }
}

/// CARD LAMA TETAP ADA
Widget regCard(
  String title, {
  required VoidCallback onTap,
  Color elementColor =
      Colors.purple,
  Color bgColor = Colors.white,
  Color bg2Color = Colors.white,
}) {
  return Container(
    margin:
        const EdgeInsets.only(bottom: 15),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(16),
        child: Container(
          padding:
              const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                bgColor,
                bg2Color,
              ],
              begin:
                  Alignment.centerLeft,
              end:
                  Alignment.centerRight,
            ),
            borderRadius:
                BorderRadius.circular(
                    20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey
                    .withOpacity(0.05),
                blurRadius: 10,
                offset:
                    const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              Icon(
                Icons.add,
                color: elementColor,
              ),
              const SizedBox(
                  width: 15),
              Text(
                title,
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                  color:
                      elementColor,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}