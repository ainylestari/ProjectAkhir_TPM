import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database.dart';
import '/screens/profileEdit.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseHelper dbHelper =
      DatabaseHelper.instance;

  Map<String, dynamic>? userData;
  bool biometricEnabled = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      int userId =
          prefs.getInt('user_id') ?? 0;

      if (userId == 0) {
        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          '/login',
        );
        return;
      }

      final user =
          await dbHelper.getUserById(userId);

      setState(() {
        userData = user;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleLogout() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool("isLoggedIn", false);

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      '/login',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    String username =
        userData?['username'] ??
            'User';

    String email =
        userData?['email'] ??
            'No Email';

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F2FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                /// HEADER
                const Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Manage your account settings",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 24),

                /// PROFILE CARD
                Container(
                  padding:
                      const EdgeInsets.all(
                          20),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                            24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(
                                0.08),
                        blurRadius: 12,
                        offset:
                            const Offset(
                                0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFA855F7),
                                  Color(0xFFFF6FB5),
                                ],
                              ),
                              image: userData?['image'] != null &&
                                      userData!['image']
                                          .toString()
                                          .isNotEmpty
                                  ? DecorationImage(
                                      image: FileImage(
                                        File(userData!['image']),
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: userData?['image'] == null ||
                                    userData!['image']
                                        .toString()
                                        .isEmpty
                                ? const Icon(
                                    Icons.person_outline,
                                    color: Colors.white,
                                    size: 42,
                                  )
                                : null,
                          ),

                          const SizedBox(
                              height: 16),

                          Text(
                            username,
                            style:
                                const TextStyle(
                              fontSize:
                                  22,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                              height: 6),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              const Icon(
                                Icons
                                    .email_outlined,
                                size: 16,
                                color: Colors
                                    .grey,
                              ),
                              const SizedBox(
                                  width: 4),
                              Flexible(
                                child: Text(
                                  email,
                                  style:
                                      const TextStyle(
                                    color: Colors
                                        .grey,
                                  ),
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  user: userData!, // FIX HERE
                                ),
                              ),
                            );

                            if (result == true) {
                              loadUserProfile(); // REFRESH DARI DB
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Colors.purple,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                /// BIOMETRIC LOGIN
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                            22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFF3E8FF,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      12),
                        ),
                        child:
                            const Icon(
                          Icons
                              .shield_outlined,
                          color: Colors
                              .purple,
                          size: 18,
                        ),
                      ),

                      const SizedBox(
                          width: 14),

                      const Expanded(
                        child: Text(
                          "Biometric Login",
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),

                      Switch(
                        value:
                            biometricEnabled,
                        onChanged:
                            (value) {
                          setState(() {
                            biometricEnabled =
                                value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                /// FEEDBACK
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 20,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                            22),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons
                            .chat_bubble_outline,
                        color:
                            Colors.blue,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Saran & Kesan TPM",
                        ),
                      ),
                      Icon(
                        Icons
                            .chevron_right,
                        color:
                            Colors.grey,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// LOGOUT
                SizedBox(
                  width:
                      double.infinity,
                  child:
                      ElevatedButton(
                    onPressed:
                        handleLogout,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                20),
                      ),
                    ),
                    child:
                        const Text(
                      "Logout",
                      style:
                          TextStyle(
                        color:
                            Colors.white,
                        fontSize: 16,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}