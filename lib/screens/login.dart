import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth_service.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService authService = AuthService();

  bool showPassword = false;
  bool isLoading = false;

  /// VALIDATION
  bool isValidEmail(String email) {
    return RegExp(r'\S+@\S+\.\S+').hasMatch(email);
  }

  Future<void> handleLogin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError("Email dan password wajib diisi");
      return;
    }

    if (!isValidEmail(email)) {
      showError("Format email tidak valid");
      return;
    }

    if (password.length < 6) {
      showError("Password minimal 6 karakter");
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await authService.login(
        email: email,
        password: password,
      );

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setInt('user_id', user['id']);
        await prefs.setString('username', user['username']);
        await prefs.setString('email', user['email']);
        await prefs.setBool('is_logged_in', true);

        showError("Login berhasil");

        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          '/home',
        );
      } else {
        showError("Email atau password salah");
      }
    } catch (e) {
      showError("Login gagal");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  final LocalAuthentication auth =
    LocalAuthentication();

  Future<void> loginWithBiometric() async {
  try {
    bool canCheck =
        await auth.canCheckBiometrics;

    bool isSupported =
        await auth.isDeviceSupported();

    final available =
        await auth.getAvailableBiometrics();

    print("canCheck: $canCheck");
    print("isSupported: $isSupported");
    print("available: $available");

    if (!canCheck || !isSupported) {
      showError("Biometric not supported");
      return;
    }

    bool authenticated =
        await auth.authenticate(
      localizedReason:
          "Scan fingerprint to login",
      options: const AuthenticationOptions(
        stickyAuth: true,
      ),
    );

    print("authenticated: $authenticated");

    if (authenticated) {
      final prefs =
          await SharedPreferences.getInstance();

      int userId =
          prefs.getInt("user_id") ?? 0;

      print("saved user id: $userId");

      if (userId != 0) {
        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          '/home',
        );
      } else {
        showError(
          "No saved session found.\nLogin manually first.",
        );
      }
    } else {
      showError(
        "Authentication cancelled",
      );
    }
  } catch (e) {
    print("BIO ERROR: $e");

    showError(
      "Biometric failed: $e",
    );
  }
}
  

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E8FF), Color(0xFFFCE7F3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text("🎭", style: TextStyle(fontSize: 50)),
                const SizedBox(height: 10),
                const Text(
                  "Welcome to MoodMate",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                /// EMAIL
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "your.email@example.com",
                    prefixIcon: const Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// PASSWORD
                TextField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign In", style: TextStyle(color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 20),

                /// REGISTER LINK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                Column(
                  children: [
                    const Text(
                      "Login with Fingerprint",
                    ),
                    IconButton(
                      onPressed: loginWithBiometric,
                      icon: const Icon(
                        Icons.fingerprint,
                        size: 48,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}