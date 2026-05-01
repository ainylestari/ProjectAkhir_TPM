import '/database.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // =========================
  // REGISTER USER
  // =========================
  Future<String> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // cek email sudah ada atau belum
      final users = await _dbHelper.getUsers();

      bool emailExists = users.any(
        (user) => user['email'] == email,
      );

      if (emailExists) {
        return "Email already registered";
      }

      await _dbHelper.registerUser({
        'username': username,
        'email': email,
        'password': password,
      });

      return "Register Success";
    } catch (e) {
      return "Register Failed: $e";
    }
  }

  // =========================
  // LOGIN USER
  // =========================
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dbHelper.loginUser(
        email,
        password,
      );

      return user;
    } catch (e) {
      return null;
    }
  }
}