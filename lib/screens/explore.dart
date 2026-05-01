import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../models/destination_model.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final LocationService _locationService = LocationService();
  String selectedCategory = "All";
  String searchQuery = "";

  final List<String> categories = [
    "All",
    "Restaurant",
    "Cafe",
    "Park",
    "Gym",
    "Shopping Mall",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              
              const Text(
                "Explore Places",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Discover amazing destinations around you",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              /// SEARCH BAR
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                }, // realtime search, langsung filter saat user ketik
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
                                    Colors.purple,
                                    Colors.pinkAccent,
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
                child: FutureBuilder<List<Destination>>(
                  future: _locationService.getNearbyRecommendations(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(child: Text("Gagal mengambil data."));
                    }

                    // filter berdasarkan kata kunci kategori & search
                    final filteredPlaces = snapshot.data!.where((p) {
                      // cek apakah kategori dari DB mengandung kata kunci dari tombol yang diklik
                      final matchesCategory = selectedCategory == "All" || 
                          p.category.toLowerCase().contains(selectedCategory.toLowerCase());

                      // cek apakah nama tempat mengandung kata kunci pencarian
                      final matchesSearch = p.name.toLowerCase().contains(searchQuery);

                      return matchesCategory && matchesSearch;
                    }).toList();

                    if (filteredPlaces.isEmpty) {
                      return const Center(child: Text("Tidak ditemukan tempat yang cocok di sekitar Anda."));
                    }

                    return GridView.builder(
                      itemCount: filteredPlaces.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),

                      itemBuilder: (context, index) {
                        final place = filteredPlaces[index];
                        
                        return GestureDetector(
                          onTap: () {
                            // navigasi ke detail bisa ditaruh di sini nanti
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    place.imagePath,
                                    fit: BoxFit.cover,
                                    // gambar gagal dimuat, tampilkan placeholder
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=500&auto=format&fit=crop',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      );
                                    },
                                  ),
                                  
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.8),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          place.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${place.distance?.toStringAsFixed(1)} km",
                                              style: const TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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