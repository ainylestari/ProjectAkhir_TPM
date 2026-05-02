class UserModel {
  final String id;
  final String username;
  final String email;
  final String token;
  final String? phone;
  final String? location;
  final String? image;

  UserModel({
      required this.id,
      required this.username,
      required this.email,
      required this.token,
      this.phone,
      this.location,
      this.image,
    });

  // simpan ke Shared Preferences
  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'token': token,
    'phone': phone,
    'location': location,
    'image': image,
  };

  // ambil dari SharedPreferences
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    username: json['username'],
    email: json['email'],
    token: json['token'],
    phone: json['phone'],
    location: json['location'],
    image: json['image'],
  );
}