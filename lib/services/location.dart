import 'package:geolocator/geolocator.dart';
import '/models/travel_destination.dart';
import '/database.dart';

class LocationService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Destination>> getNearbyRecommendations() async {
    // 1. Ambil posisi GPS user saat ini
    Position userPos = await Geolocator.getCurrentPosition();

    // 2. Ambil SEMUA data destinasi dari SQLite
    List<Map<String, dynamic>> rawData = await _dbHelper.getExplore();
    List<Destination> allDestinations = rawData.map((e) => Destination.fromMap(e)).toList();

    List<Destination> nearbyResult = [];

    // 3. Filter Radius 10 KM
    for (var dest in allDestinations) {
      double distanceInMeters = Geolocator.distanceBetween(
        userPos.latitude, userPos.longitude, 
        dest.lat, dest.lng
      );

      if (distanceInMeters <= 10000) { // 10 KM
        dest.distance = distanceInMeters / 1000; // Ubah ke KM
        nearbyResult.add(dest);
      }
    }

    // 4. Urutkan dari yang terdekat
    nearbyResult.sort((a, b) => a.distance!.compareTo(b.distance!));

    return nearbyResult;
  }
}