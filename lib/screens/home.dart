import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MoodMate"),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            onPressed: () {
              /// LOGOUT
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// GREETING
            const Text(
              "Hi there 👋",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "How are you feeling today?",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// MOOD SELECTOR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                moodItem("😄", "Happy"),
                moodItem("😐", "Neutral"),
                moodItem("😢", "Sad"),
                moodItem("😡", "Angry"),
              ],
            ),

            const SizedBox(height: 30),

            /// FEATURE CARDS
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                featureCard(Icons.book, "Journal"),
                featureCard(Icons.self_improvement, "Meditation"),
                featureCard(Icons.music_note, "Music"),
                featureCard(Icons.sports_esports, "Activities"),
              ],
            ),

            const SizedBox(height: 30),

            /// RECOMMENDATION
            const Text(
              "Recommended for you",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            recommendationCard(
              "Take a short walk",
              "Fresh air can boost your mood",
            ),
            recommendationCard(
              "Listen to relaxing music",
              "Calm your mind with soft tunes",
            ),
          ],
        ),
      ),
    );
  }

  /// WIDGET: Mood Item
  Widget moodItem(String emoji, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }

  /// WIDGET: Feature Card
  Widget featureCard(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.purple),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }

  /// WIDGET: Recommendation Card
  Widget recommendationCard(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.purple),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}