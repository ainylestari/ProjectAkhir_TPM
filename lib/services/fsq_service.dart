import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'session.dart';

class FoursquareService {
  // ambil key dari .env
  final String apiKey = dotenv.env['FSQ_Places_API'] ?? '';

  Future<List<Map<String, dynamic>>> fetchNearbyPlaces(double lat, double lng, {String? query}) async {
    if (apiKey.isEmpty) {
      print("Error: API Key Foursquare tidak ditemukan di .env"); //debug
      return [];
    }

    final categoryGroups = [
      "10000,11000,12000,13000",
      "14000,15000,16000",
      "17000,18000,19000",
    ];

    // tambahkan query pencarian
    final queryParam = (query != null && query.isNotEmpty) ? "&query=$query" : "";

    List<Map<String, dynamic>> allResults = [];

    for (final cats in categoryGroups) {
      final url = Uri.parse(
        "https://places-api.foursquare.com/places/search?ll=$lat,$lng&categories=$cats&radius=10000&limit=50&sort=DISTANCE$queryParam"
      );
    
      print("FSQ request URL: $url"); // debug

      // header baru
      try {
        final response = await http.get(url, headers: {
          'Authorization': 'Bearer $apiKey',
          'accept': 'application/json',
          'X-Places-Api-Version': '2025-06-17'
        });

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print("FSQ raw response: ${response.body}"); // debug
          allResults.addAll(List<Map<String, dynamic>>.from(data['results']));
        } else {
          print("FSQ status code: ${response.statusCode}"); // debug
          print("FSQ error body: ${response.body}"); // debug
        }
      } catch (e) {
        print("Error FSQ Service: $e");
      }
    }
    final seen = <String>{};
    final unique = allResults.where((e) {
      final id = e['fsq_place_id'] as String? ?? '';
      return seen.add(id); 
    }).toList();
    
    print("Total FSQ setelah difilter: ${unique.length}");
    return unique;
  }
}