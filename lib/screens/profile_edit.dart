import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database.dart';
import '../models/user_model.dart';
import '../services/session.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final DatabaseHelper dbHelper =
      DatabaseHelper.instance;

  final fullNameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final locationController =
      TextEditingController();

  File? selectedImage;
  String imagePath = '';

  @override
  void initState() {
    super.initState();

    fullNameController.text =
        widget.user.username;

    emailController.text =
        widget.user.email;

    phoneController.text =
        widget.user.phone?.toString() ?? '';

    locationController.text =
        widget.user.location ?? '';

    imagePath =
        widget.user.image ?? '';
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
        imagePath = picked.path;
      });
    }
  }

  Future<void> saveProfile() async {
    try {
      final int userId =
          int.parse(widget.user.id);

      final result = await dbHelper.updateUser(
        userId,
        {
          'username': fullNameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'location': locationController.text.trim(),
          'image': imagePath,
        },
      );

      if (!mounted) return;

      if (result > 0) {
        await SessionManager().login(UserModel(
          id: widget.user.id,
          username: fullNameController.text.trim(),
          email: emailController.text.trim(),
          token: widget.user.token,
          phone: phoneController.text.trim(),
          location: locationController.text.trim(),
          image: imagePath,
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update profile"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// BACK
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, size: 18),
                    SizedBox(width: 6),
                    Text("Back"),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Edit Profile",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Update your personal information",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              /// PHOTO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: pickImage,
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.transparent,
                            backgroundImage: imagePath.isNotEmpty
                                ? FileImage(File(imagePath))
                                : null,
                            child: imagePath.isEmpty
                                ? Container(
                                    width: 84,
                                    height: 84,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFA855F7),
                                          Color(0xFFFF4FA3),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person_outline,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        ),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFA855F7),
                                    Color(0xFFFF4FA3),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.photo_camera_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Click to change photo",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              buildTextField(
                label: "Full Name",
                icon: Icons.person_outline,
                controller: fullNameController,
              ),

              const SizedBox(height: 18),

              buildTextField(
                label: "Email",
                icon: Icons.email_outlined,
                controller: emailController,
              ),

              const SizedBox(height: 18),

              buildTextField(
                label: "Phone",
                icon: Icons.phone_outlined,
                controller: phoneController,
              ),

              const SizedBox(height: 18),

              buildTextField(
                label: "Location",
                icon: Icons.location_on_outlined,
                controller: locationController,
              ),

              const SizedBox(height: 30),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              /// CANCEL
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}