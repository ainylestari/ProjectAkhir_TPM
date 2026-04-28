import 'package:flutter/material.dart';

class JournalDetailScreen extends StatefulWidget {
  final DateTime journaldetail;

  const JournalDetailScreen({super.key, required this.journaldetail});

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Back"),
      ),
      body: Center(
        child: Text(
          "tes",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}