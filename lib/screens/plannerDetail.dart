import 'package:flutter/material.dart';

class PlannerDetailScreen extends StatefulWidget {
  final DateTime detail;

  const PlannerDetailScreen({super.key, required this.detail});

  @override
  State<PlannerDetailScreen> createState() => _PlannerDetailScreenState();
}

class _PlannerDetailScreenState extends State<PlannerDetailScreen> {
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