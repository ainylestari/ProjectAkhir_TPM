import 'dart:convert';
import 'package:http/http.dart' as http;

class OSMService {
  Future<List<Map<String, dynamic>>> fetchNearbyPlaces(double lat, double lng) async {
    // cari cafe, resto, dan taman dalam radius 10km
    final query = """
    [out:json];
    (
      node["amenity"~"restaurant|cafe"](around:10000, $lat, $lng);
      node["leisure"~"park|garden"](around:10000, $lat, $lng);
    );
    out body;
    """;

    final url = Uri.parse("https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}");
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['elements']);
      }
    } catch (e) {
      print("Error dalam mengambil data OSM: $e");
    }
    return [];
  }
}