import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() =>
      _ExploreScreenState();
}

class _ExploreScreenState
    extends State<ExploreScreen> {
  String selectedCategory = "All";

  final List<String> categories = [
    "All",
    "Trending",
    "Popular",
    "Beaches",
    "Mountains",
    "Hidden Gems",
    "Wellness",
  ];

  final List<Map<String, dynamic>> places = [
    {
      "name": "Bali Beach",
      "category": "Beaches",
      "rating": 4.8,
      "image":
          "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
    },
    {
      "name": "Mount Bromo",
      "category": "Mountains",
      "rating": 4.9,
      "image":
          "https://images.unsplash.com/photo-1549880338-65ddcdfd017b",
    },
    {
      "name": "Ubud Retreat",
      "category": "Wellness",
      "rating": 4.7,
      "image":
          "https://images.unsplash.com/photo-1506126613408-eca07ce68773",
    },
    {
      "name": "Hidden Waterfall",
      "category": "Hidden Gems",
      "rating": 4.6,
      "image":
          "https://images.unsplash.com/photo-1501785888041-af3ef285b470",
    },
    {
      "name": "Tokyo City",
      "category": "Trending",
      "rating": 4.8,
      "image":
          "https://images.unsplash.com/photo-1549692520-acc6669e2f0c",
    },
  ];

  List<Map<String, dynamic>> get filteredPlaces {
    if (selectedCategory == "All") return places;
    return places
        .where((p) => p['category'] == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              const Text(
                "Explore Places",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Discover amazing destinations around the world",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              /// SEARCH BAR
              TextField(
                decoration: InputDecoration(
                  hintText: "Search places...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// CATEGORY
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];

                    final isSelected =
                        selectedCategory == cat;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = cat;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFA855F7),
                                    Color(0xFFFF4FA3),
                                  ],
                                )
                              : null,
                          color: isSelected
                              ? null
                              : Colors.white,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              /// GRID PLACES
              Expanded(
                child: GridView.builder(
                  itemCount: filteredPlaces.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final place = filteredPlaces[index];

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage(
                              place['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.end,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              place['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  place['rating']
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}