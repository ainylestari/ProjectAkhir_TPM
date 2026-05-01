class Destination {
  final int? id;
  final String name;
  final double lat;
  final double lng;
  final String imagePath;
  final String description;
  double? distance; // jarak

  Destination({
    this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.imagePath,
    required this.description,
    this.distance,
  });

  // mapping dari database ke object dart
  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'],
      name: map['name'],
      lat: map['lat'],
      lng: map['lng'],
      imagePath: map['imagePath'],
      description: map['description'],
    );
  }
}