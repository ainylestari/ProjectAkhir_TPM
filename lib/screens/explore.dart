import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../models/destination_model.dart';
import '../services/session.dart';
import '../database.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final LocationService _locationService = LocationService();
  String selectedCategory = "All";
  String searchQuery = "";
  late Future<List<Destination>> _nearbyFuture;

  final List<String> categories = [
    "All",
    "Restaurant",
    "Cafe and Bar",
    "Park",
    "Gym",
    "Shopping",
    "Salon and Spa",
    "Health",
  ];

  @override
  void initState() {
    super.initState();
    _clearAndFetch();
  }

  Future<void> _clearAndFetch() async {
    await DatabaseHelper.instance.clearExplore();
    setState(() {
      _nearbyFuture = _locationService.getNearbyRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const Text(
                "Explore Places",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

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
                  future: _nearbyFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(child: Text("Gagal mengambil data."));
                    }

                    // filter berdasarkan kata kunci kategori & search
                    final filteredPlaces = snapshot.data!.where((p) {
                      // mapping kategori ke keyword untuk pencocokan
                      const categoryKeywords = {
                        "Restaurant": [
                          "restaurant", "food", "dining", "eatery", "bistro", "warung", "makan", "resto", "grill", 
                          "steakhouse", "seafood", "bbq", "buffet", "cuisine", "noodle", "eat", "eatery", "food court",
                          "sushi", "fast food", "street food", "fine dining", "gastropub", "pizza"
                        ],
                        "Cafe and Bar": [
                          "cafe", "coffee", "bakery", "breakfast", "tea", "bar", "kopi", "espresso", "latte", "pastry", 
                          "dessert", "juice", "smoothie", "cocktail", "pub", "lounge", "winery", "brewery",
                          "roastery", "ice cream", "gelato", "bubble tea", "milkshake", "brunch", "club", "karaoke"
                        ],
                        "Park": [
                          "park", "garden", "taman", "nature", "outdoor", "playground", "recreation", "green", "forest", 
                          "trail", "hiking", "picnic", "zoo", "botanical", "wildlife", "lake", "river", "beach", "camping", 
                          "scenic", "viewpoint", "waterfall", "nature reserve", "national park", "state park", "city park", 
                          "amusement park", "theme park", "kebun raya", "hutan", "cagar alam", "lapangan", "alun-alun", "museum", 
                          "monument", "landmark"
                        ],
                        "Gym": [
                          "gym", "fitness", "sport", "exercise", "workout", "training", "yoga", "pilates", "boxing", 
                          "martial arts", "swimming pool", "climbing", "dance", "fitness center", "wellness center", 
                          "gymnasium", "athletic", "recreation center", "outdoor gym", "running track", "cycling", 
                          "kolam renang", "weightlifting", "olahraga", "senam"
                        ],
                        "Shopping": [
                          "mall", "shopping", "market", "plaza", "supermarket", "store", "boutique", "outlet", "retail", 
                          "fashion", "clothing", "electronics", "grocery", "furniture", "department store", "handicraft", 
                          "souvenir", "bazaar", "pasar", "toko", "perbelanjaan", "perdagangan", "shopping center", "shoes", 
                          "accessories", "jewelry", "bookstore", "toy", "pet store", "buku", "sepatu", "tas", "aksesoris"
                          "perhiasan", "skincare", "cosmetic"
                        ],
                        "Salon and Spa": [
                          "salon", "beauty", "spa", "wellness", "hair", "massage", "nail", "barber", "skin", "kecantikan",
                          "tattoo", "piercing", "skincare", "cosmetic", "aesthetic", "grooming", "facial", "body treatment",
                          "kulit", "pijat", "reflexology", "manicure", "pedicure", "barbershop", "salon kecantikan", "spa kecantikan", "perawatan tubuh", "perawatan wajah"
                        ],
                        "Health": [
                          "hospital", "clinic", "pharmacy", "health", "medical", "doctor", "dentist", "fisioterapi",
                          "emergency", "physiotherapy", "mental", "counseling", "therapy", "rehabilitation",  "rehab",
                          "chiropractic", "acupuncture", "maternity", "nurse", "physician", "rumah sakit", "klinik", "apotik", 
                          "kesehatan", "dokter", "dokter gigi", "darurat", "farmasi", "psikolog", "konseling", "terapi",
                          "akupunktur", "bersalin"
                        ],
                      };

                      // cek apakah kategori dari DB mengandung kata kunci dari tombol yang diklik
                      final matchesCategory = selectedCategory == "All" || (categoryKeywords[selectedCategory] ?? []).any(
                            (keyword) => p.category.toLowerCase().contains(keyword)
                        );

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
                                    place.imagePath.isNotEmpty ? place.imagePath : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=500&auto=format&fit=crop',
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
