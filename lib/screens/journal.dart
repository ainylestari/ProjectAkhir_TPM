import 'package:flutter/material.dart';
import '/screens/journalDetail.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            regCard(
              "Write New Journal", 
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => JournalDetailScreen(journaldetail: DateTime.now())));
              },
              elementColor: Colors.white, 
              bgColor: Colors.purple, 
              bg2Color: Colors.purple.shade300
            ),
          ],
        ),
      ),
    );
  }
}


// card
Widget regCard(String title, {
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