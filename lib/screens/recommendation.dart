import 'package:flutter/material.dart';

class RecommendationScreen extends StatelessWidget {
  final String mood;

  const RecommendationScreen({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {
    List<Widget> recommendations = [];

    switch (mood) {
      case "Happy":
        recommendations = [
          recommendationCard(
            icon: Icons.music_note,
            color: const Color(0xFFFFF3B0),
            title: "Listen to upbeat music",
            subtitle: "Boost your mood with energetic songs",
          ),
          recommendationCard(
            icon: Icons.directions_walk,
            color: const Color(0xFFD7F9F1),
            title: "Take a walk outside",
            subtitle: "Fresh air can improve your mood",
          ),
          recommendationCard(
            icon: Icons.people,
            color: const Color(0xFFFFE5D9),
            title: "Meet a friend",
            subtitle: "Spend time with someone you like",
          ),
        ];
        break;

      case "Sad":
        recommendations = [
          recommendationCard(
            icon: Icons.fastfood,
            color: const Color(0xFFFFF3B0),
            title: "Comfort food or drink",
            subtitle: "Treat yourself gently",
          ),
          recommendationCard(
            icon: Icons.favorite,
            color: const Color(0xFFFFE5D9),
            title: "Connect with loved ones",
            subtitle: "Talk to someone you trust",
          ),
          recommendationCard(
            icon: Icons.edit,
            color: const Color(0xFFD7F9F1),
            title: "Journaling",
            subtitle: "Write what you feel",
          ),
        ];
        break;

      case "Angry":
        recommendations = [
          recommendationCard(
            icon: Icons.fitness_center,
            color: const Color(0xFFFFE5D9),
            title: "Intense exercise",
            subtitle: "Release your energy physically",
          ),
          recommendationCard(
            icon: Icons.spa,
            color: const Color(0xFFD7F9F1),
            title: "Grounding technique",
            subtitle: "Calm your mind step by step",
          ),
          recommendationCard(
            icon: Icons.shower,
            color: const Color(0xFFFFF3B0),
            title: "Cold shower",
            subtitle: "Reset your mind and body",
          ),
        ];
        break;

      default:
        recommendations = [
          recommendationCard(
            icon: Icons.menu_book,
            color: const Color(0xFFFFF3B0),
            title: "Read a book",
            subtitle: "Gain new perspective",
          ),
          recommendationCard(
            icon: Icons.music_note,
            color: const Color(0xFFD7F9F1),
            title: "Listen to music",
            subtitle: "Relax and enjoy",
          ),
          recommendationCard(
            icon: Icons.school,
            color: const Color(0xFFFFE5D9),
            title: "Study time",
            subtitle: "Boost your productivity",
          ),
        ];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FF),
      appBar: AppBar(
        title: Text("Recommendations"),
        backgroundColor: const Color(0xFFF8F3FF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // HEADER
            Column(
              children: [
                Text(
                  moodEmoji(mood),
                  style: const TextStyle(fontSize: 50),
                ),
                const SizedBox(height: 10),
                Text(
                  "You're feeling $mood!",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Here’s what we recommend",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 25),

            ...recommendations,
          ],
        ),
      ),
    );
  }

  String moodEmoji(String mood) {
    switch (mood) {
      case "Happy":
        return "😄";
      case "Sad":
        return "😢";
      case "Angry":
        return "😠";
      default:
        return "😐";
    }
  }
}

Widget recommendationCard({
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black87),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),

      ],
    ),
  );
}