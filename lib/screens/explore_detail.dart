import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/destination_model.dart';

class ExploreDetailScreen extends StatefulWidget {
  final LatLng poi;
  final Destination place;
  
  const ExploreDetailScreen({
    super.key,
    required this.poi,
    required this.place,
  });

  @override
  State<ExploreDetailScreen> createState() => _ExploreDetailScreenState();
}

class _ExploreDetailScreenState extends State<ExploreDetailScreen> {
  LatLng? userLocation;
  List<LatLng> routePoints = [];
  double? compassHeading;
  
  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _listenCompass();
  }

  // sensor kompas
  void _listenCompass() {
    FlutterCompass.events?.listen((event) {
      if (mounted) {
        setState(() {
          compassHeading = event.heading;
        });
      }
    });
  }

  // cari titik lokasi user
  Future<void> _getUserLocation() async {
    final position = await Geolocator.getCurrentPosition();
    final userLatLng = LatLng(position.latitude, position.longitude);
    setState(() {
      userLocation = userLatLng;
    });
    await _getRoute(userLatLng, widget.poi);
  }

  // cari rute terdekat
  Future<void> _getRoute(LatLng from, LatLng to) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${from.longitude},${from.latitude};'
      '${to.longitude},${to.latitude}'
      '?overview=full&geometries=geojson'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        setState(() {
          routePoints = coords
              .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
              .toList();
        });
      }
    } catch (e) {
      print("OSRM error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Point of Interest")),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: widget.poi,
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.tpm_tugasakhir',
                    ),

                    // garis rute
                    if (routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            color: Colors.blue,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                      
                    MarkerLayer(
                      markers: [
                        // poi marker
                        Marker(
                          point: widget.poi,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_on, 
                            color: Colors.red, 
                            size: 50,
                          ),
                        ),

                        // marker user
                        if (userLocation != null)
                        Marker(
                          point: userLocation!,
                          width: 50,
                          height: 50,
                          child: Transform.rotate(
                            angle: compassHeading != null
                                ? compassHeading! * (pi / 180)
                                : 0,
                            child: const Icon(
                              Icons.navigation,
                              color: Colors.blue,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // detail
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.place.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${widget.place.distance?.toStringAsFixed(1)} km dari lokasimu",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.place.category,
                    style: const TextStyle(color: Colors.purple),
                  ),

                  const SizedBox(height: 20),

                  Text(widget.place.description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}