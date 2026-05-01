import 'package:geolocator/geolocator.dart';
import '../models/destination_model.dart';
import '/database.dart';
import 'osm_service.dart';

class LocationService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Destination>> getNearbyRecommendations() async {
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

    if (rawData.isEmpty) {
    // ambil dari Open Street Map
    final osmData = await OSMService().fetchNearbyPlaces(userPos.latitude, userPos.longitude);
    
    // simpan hasil nggak download lagi
    for (var element in osmData) {
      await _dbHelper.insertExplore({
        'name': element['tags']['name'] ?? 'Unnamed Place',
        'category': element['tags']['amenity'] ?? element['tags']['leisure'] ?? 'Place',
        'lat': element['lat'],
        'lng': element['lon'],
        'imagePath': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4', // Gambar placeholder
        'description': 'Tempat asik ditemukan via OpenStreetMap'
      });
    }
    // Ambil ulang setelah di-isi
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