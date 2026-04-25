import 'package:flutter/material.dart';

class Recommendation extends StatelessWidget {
  final String mood;

  const Recommendation({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {

  List<Widget> recommendations = [];

    switch (mood) {
      case "Happy":
        recommendations = [
          recommendationCard("Stroll Outside", "Take a walk or jog at the nearest park."),
          recommendationCard("Try New Recipe", "Experiment with a new dish you've been wanting to try."),
          recommendationCard("Pour Creative Ideas", "Doodling, painting, or crafting to express yourself."),
        ];
        break;
      case "Sad":
        recommendations = [
          recommendationCard("Comfort Food or Drink", "Treat yourself with your favorite comfort food or drink."),
          recommendationCard("Connect with Loved Ones", "Reach out to friends or family for support."),
          recommendationCard("Journaling", "Writing down your thoughts can be therapeutic."),];
        break;
      case "Angry":
        recommendations = [
          recommendationCard("Intense Exercise", "Channel your high energy at the nearest gym."),
          recommendationCard("Grounding", "5-4-3-2-1 technique to calm your mind."),
          recommendationCard("Cold Shower", "A cold shower can help reduce anger and clear your mind."),
        ];
        break;
      default: // Neutral
        recommendations = [
          recommendationCard("Read a Book", "Reading can give you inspiration and new perspectives."),
          recommendationCard("Listen to Music", "Listening to music can improve your mood."),
          recommendationCard("Study Time", "Focus on your studies to boost productivity."),
        ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Recommendations for $mood"),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Here are some recommendations based on your mood!",
              style: TextStyle(fontSize: 18)
            ),

            const SizedBox(height: 20),
            ...recommendations,

          ]
          
          
        ),
      ),
    );
  }
}


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