import 'package:flutter/material.dart';
import '/screens/recommendation.dart';
import '/screens/navigation.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) action;
  
  const HomeScreen({super.key, required this.action});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hi there 👋",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "How are you feeling today?",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// mood
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                moodItem("😄", "Happy", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecommendationScreen(mood: "Happy"),
                    ),
                  );
                }),
                moodItem("😐", "Neutral", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecommendationScreen(mood: "Neutral"),
                    ),
                  );
                }),
                moodItem("😢", "Sad", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecommendationScreen(mood: "Sad"),
                    ),
                  );
                }),
                moodItem("😡", "Angry", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecommendationScreen(mood: "Angry"),
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 30),

            /// rekomen
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

            const SizedBox(height: 30),

            /// Quick action
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Column(
              children: [
                quickActionCard(Icons.auto_awesome_rounded, "AI Mood Chat", [Colors.indigo, Colors.indigoAccent.shade200]),
                
                quickActionCard(
                  onTap: () => widget.action(3),
                  Icons.book, "Journal", 
                  [Colors.purple, Colors.purple.shade300],
                ),
                
                quickActionCard(Icons.music_note, "Music", [Colors.pink, Colors.pink.shade300]),

                quickActionCard(Icons.location_on_rounded, "Explore Places", [Colors.orange.shade600, Colors.orange.shade300]),
              ],
            ),

            

          ],
        ),
      ),
    );
  }

  /// Mood Item
  Widget moodItem(String emoji, String label, VoidCallback onTap) {
    return MouseRegion(
    cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
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
        ),
      ),
    );
  }

  /// Feature Card (sementara ga kepake)
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

  /// recommendation card
  Widget recommendationCard(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
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

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// quick action Card
  Widget quickActionCard(IconData icon, String title, List<Color> colors, {VoidCallback? onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}