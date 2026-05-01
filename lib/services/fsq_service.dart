import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FoursquareService {
  // ambil key dari .env
  final String apiKey = dotenv.env['FSQ_Places_API'] ?? '';

  Future<List<Map<String, dynamic>>> fetchNearbyPlaces(double lat, double lng, {String? query}) async {
    if (apiKey.isEmpty) {
      print("Error: API Key Foursquare tidak ditemukan di .env");
      return [];
    }

    // endpoint API fsq untuk pencarian tempat (cafe, resto, taman, dsb) di sekitar
    final url = Uri.parse(
      "https://api.foursquare.com/v3/places/search?ll=$lat,$lng&categories=10000, 13000, 15000, 16000, 17000, 18000, 19000&radius=10000&limit=50&sort=DISTANCE&query=$query"
    );

    try {
      final response = await http.get(url, headers: {
        'Authorization': apiKey,
        'accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      }
    } catch (e) {
      print("Error FSQ Service: $e");
    }
    return [];
  }
}