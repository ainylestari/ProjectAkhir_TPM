import 'package:flutter/material.dart';

class TimeConverterScreen extends StatefulWidget {
  const TimeConverterScreen({super.key});

  @override
  State<TimeConverterScreen> createState() =>
      _TimeConverterScreenState();
}

class _TimeConverterScreenState
    extends State<TimeConverterScreen> {
  final timeController =
      TextEditingController();

  String fromZone = "WIB";

  Map<String, int> timeOffsets = {
    "WIB": 0,
    "WITA": 1,
    "WIT": 2,
    "London": -6,
    "Singapore": 1,
    "Tokyo": 2,
    "Seoul": 2,
  };

  Map<String, String> convertedTimes = {};

  void convertTime() {
    String input =
        timeController.text.trim();

    if (input.isEmpty ||
        !input.contains(":")) {
      return;
    }

    try {
      List<String> parts =
          input.split(":");

      int hour =
          int.parse(parts[0]);
      int minute =
          int.parse(parts[1]);

      Map<String, String> results = {};

      for (var zone
          in timeOffsets.keys) {
        int diff =
            timeOffsets[zone]! -
                timeOffsets[fromZone]!;

        int newHour =
            (hour + diff) % 24;

        if (newHour < 0) {
          newHour += 24;
        }

        results[zone] =
            "${newHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
      }

      setState(() {
        convertedTimes = results;
      });
    } catch (e) {
      print(e);
    }
  }

  Widget resultCard(
    String zone,
    String time,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
              bottom: 12),
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.05),
            blurRadius: 10,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Text(
            zone,
            style: const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.purple,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F2FA),
      appBar: AppBar(
        title:
            const Text("Time Converter"),
        backgroundColor:
            Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Convert Local Time",
              style: TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Convert time across countries",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            /// input time
            TextField(
              controller:
                  timeController,
              keyboardType:
                  TextInputType.datetime,
              decoration:
                  InputDecoration(
                labelText:
                    "Enter Time",
                hintText:
                    "Example: 07:00",
                filled: true,
                fillColor:
                    Colors.white,
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          18),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// from timezone
            DropdownButtonFormField<String>(
              value: fromZone,
              decoration:
                  InputDecoration(
                labelText:
                    "From Time Zone",
                filled: true,
                fillColor:
                    Colors.white,
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          18),
                  borderSide:
                      BorderSide.none,
                ),
              ),
              items: timeOffsets.keys
                  .map(
                    (zone) =>
                        DropdownMenuItem(
                      value: zone,
                      child: Text(zone),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  fromZone =
                      value!;
                });
              },
            ),

            const SizedBox(height: 30),

            /// convert button
            SizedBox(
              width:
                  double.infinity,
              child:
                  ElevatedButton(
                onPressed:
                    convertTime,
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
                            18),
                  ),
                ),
                child: const Text(
                  "Convert Time",
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// result
            if (convertedTimes
                .isNotEmpty)
              const Text(
                "Converted Results",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

            const SizedBox(height: 16),

            ...convertedTimes.entries.map(
              (entry) =>
                  resultCard(
                    entry.key,
                    entry.value,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}