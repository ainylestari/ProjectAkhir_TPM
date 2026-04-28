import 'package:flutter/material.dart';
import '/screens/plannerDetail.dart';
import 'package:intl/intl.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  DateTime _selectedDate = DateTime.now();

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mood Plan",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Plan your activities day by day",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
              
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  //kiri
                  IconButton(
                    onPressed: () => _changeDate(-1),
                    icon: const Icon(Icons.chevron_left, color: Colors.purple),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.purple.withOpacity(0.1),
                    ),
                  ),
                  
                  Column(
                    children: [
                      Text(
                        DateFormat('yyyyMMdd').format(_selectedDate) == DateFormat('yyyyMMdd').format(DateTime.now())
                          ? "Today"
                          : DateFormat('EEEE').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2E44),
                        ),
                      ),
                      Text(
                        DateFormat('MMMM d, yyyy').format(_selectedDate),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  //kanan
                  IconButton(
                    onPressed: () => _changeDate(1),
                    icon: const Icon(Icons.chevron_right, color: Colors.purple),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.purple.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
              
            recommendationCard(
              "Schedule Activity", 
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PlannerDetailScreen(detail: _selectedDate)));
              },
              elementColor: Colors.white, 
              bgColor: Colors.purple, 
              bg2Color: Colors.purple.shade300),
          ],
        ),
      ),
    );
  }
}

// card
Widget recommendationCard(String title, {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: elementColor),

              const SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16, color: elementColor
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}