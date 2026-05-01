import 'package:geolocator/geolocator.dart';
import '../models/destination_model.dart';
import '/database.dart';
import 'osm_service.dart';
import 'fsq_service.dart';

class LocationService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FoursquareService _fsqService = FoursquareService();

  Future<List<Destination>> getNearbyRecommendations({String? category}) async {
    // cek layanan lokasi
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return [];

    // cek status izin
    LocationPermission permission = await Geolocator.checkPermission();

    // izin akses
    permission = await Geolocator.requestPermission();
    
    // user pilih 'don't allow', tanya lagi
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    };

    // amnil posisi user
    Position userPos = await Geolocator.getCurrentPosition();

    // ambil destinasi dari mapping database
    List<Map<String, dynamic>> rawData = await _dbHelper.getExplore();

    bool hasRelevantData = rawData.any((e) => 
    e['category'].toString().toLowerCase().contains(category?.toLowerCase() ?? ""));

    if (rawData.isEmpty || (category != "All" && !hasRelevantData)) {
      final fsqData = await _fsqService.fetchNearbyPlaces(
        userPos.latitude, 
        userPos.longitude,
        query: (category == null || category == "All") ? "" : category
      );
    
      // simpan hasil biar nggak download lagi
      for (var element in fsqData) {
        // ambil list kategori dari JSON Foursquare
        List categories = element['categories'] as List;

        String categoryName = categories.isNotEmpty 
            ? categories[0]['name'] // ambil nama kayak 'Coffee Shop' atau 'Park'
            : 'General';

        await _dbHelper.insertExplore({
          'name': element['name'] ?? 'Unnamed Place',
          'category': categoryName,
          'lat': element['geocodes']['main']['latitude'],
          'lng': element['geocodes']['main']['longitude'],
          'imagePath': 'assets/images/default.png', 
          'description': element['location']['formatted_address'] ?? 'Lokasi di sekitar kamu'
        });
      }
      
      // ambil ulang data yang disimpan
      rawData = await _dbHelper.getExplore();
    }

      List<Destination> allDestinations = rawData.map((e) => Destination.fromMap(e)).toList();

      List<Destination> nearbyResult = [];

      // filter destinasi radius 10km
      for (var dest in allDestinations) {
        double distanceInMeters = Geolocator.distanceBetween(
          userPos.latitude, userPos.longitude, 
          dest.lat, dest.lng
        );

        if (distanceInMeters <= 10000) {
          dest.distance = distanceInMeters / 1000;
          nearbyResult.add(dest);
        }
      }

      // sort dari yang terdekat
      nearbyResult.sort((a, b) => a.distance!.compareTo(b.distance!));

      return nearbyResult;
    }
  }
