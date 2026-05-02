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
      "4d4b7104d754a06370d81259,54541900498ea6ccd0202697,52f2ab2ebcbc57f1066b8b20,4bf58dd8d48988d110951735",
      "52f2ab2ebcbc57f1066b8b3c,4f04aa0c2fb6e1c99f3db0b8,63be6904847c3692a84b9b4b,4bf58dd8d48988d1ed941735",
      "4bf58dd8d48988d1de931735,63be6904847c3692a84b9bb5,4bf58dd8d48988d16a941735,4bf58dd8d48988d116941735",
      "4bf58dd8d48988d143941735,63be6904847c3692a84b9bb6,52e81612bcbc57f1066b7a0c,4bf58dd8d48988d16d941735",
      "4bf58dd8d48988d1e0931735,56aa371be4b08b9a8d573508,5f2c407c5b4c177b9a6dc536,4bf58dd8d48988d1c9941735",
      "4bf58dd8d48988d120951735,56aa371be4b08b9a8d57350b,53e510b7498ebcb1801b55d4,4d4b7105d754a06374d81259",
      "4deefc054765f83613cdba6f,4bf58dd8d48988d145941735,52af0bd33cf9994f4e043bdd,4bf58dd8d48988d111941735",
      "4bf58dd8d48988d113941735,52e81612bcbc57f1066b79f4,4bf58dd8d48988d147941735,4bf58dd8d48988d16e941735",
      "52e81612bcbc57f1066b79ff,4bf58dd8d48988d1c4941735,4bf58dd8d48988d1d3941735,4bf58dd8d48988d1c7941735",
      "4bf58dd8d48988d14b941735,4d4b7105d754a06373d81259,4bf58dd8d48988d14c941735,5267e4d9e4b0ec79466e48c8",
      "63be6904847c3692a84b9bb8,5267e4d9e4b0ec79466e48c7,5267e4d8e4b0ec79466e48c5,63be6904847c3692a84b9bb9",
      "63be6904847c3692a84b9bbe,63be6904847c3692a84b9bc1,63be6904847c3692a84b9bd1,63be6904847c3692a84b9bd9",
      "4d4b7105d754a06377d81259,4bf58dd8d48988d15f941735,4bf58dd8d48988d15a941735,4bf58dd8d48988d159941735",
      "4bf58dd8d48988d12d941735,52e81612bcbc57f1066b7a13,4bf58dd8d48988d162941735,4bf58dd8d48988d163941735",
      "5fabfe3599ce226e27fe709a,4bf58dd8d48988d1e7941735,4bf58dd8d48988d164941735,56aa371be4b08b9a8d573560",
      "4d4b7105d754a06378d81259,4bf58dd8d48988d127951735,4bf58dd8d48988d104951735,4bf58dd8d48988d114951735",
      "4bf58dd8d48988d10c951735,4bf58dd8d48988d1f6941735,4bf58dd8d48988d103951735,4bf58dd8d48988d111951735",
      "4bf58dd8d48988d107951735,4bf58dd8d48988d1f9941735,5e18993feee47d000759b256,63be6904847c3692a84b9bf1",
      "4bf58dd8d48988d1fd941735,5744ccdfe4b0c0459246b4dc,4bf58dd8d48988d1f3941735,4f4528bc4b90abdf24c9de85",
      "63be6904847c3692a84b9bfd,52e81612bcbc57f1066b7a0f,63be6904847c3692a84b9c05,4bf58dd8d48988d175941735",
      "63be6904847c3692a84b9c08,4bf58dd8d48988d176941735,5744ccdfe4b0c0459246b4b2,4bf58dd8d48988d102941735",
      "4bf58dd8d48988d1f4931735,63be6904847c3692a84b9c12,52e81612bcbc57f1066b7a26,58daa1558bbb0b01f18ec1ae",
      "63be6904847c3692a84b9c17,63be6904847c3692a84b9c1a,4eb1bf013b7b6f98df247e07,52e81612bcbc57f1066b7a29",
      "63be6904847c3692a84b9c21,63be6904847c3692a84b9c22,4bf58dd8d48988d15e941735,52f2ab2ebcbc57f1066b8b50",
      "4bf58dd8d48988d1f8931735,63be6904847c3692a84b9c26,4bf58dd8d48988d1fa931735,4bf58dd8d48988d12f951735",
      /*"10000,11000,12000,13000",
      "14000,15000,16000",
      "17000,18000,19000",*/
    ];

    // tambahkan query pencarian
    final queryParam = (query != null && query.isNotEmpty) ? "&query=$query" : "";

    List<Map<String, dynamic>> allResults = [];

    for (final cats in categoryGroups) {
      final url = Uri.parse(
        "https://places-api.foursquare.com/places/search?ll=$lat,$lng&category_id=$cats&radius=10000&limit=50&sort=DISTANCE$queryParam"
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
    return unique; // filter biar ga duplikat
  }
}