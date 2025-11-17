import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel265/models/user_profile_model.dart';
import 'package:travel265/models/property_models.dart';
import 'package:travel265/models/user_profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile? userProfile;

  const EditProfileScreen({super.key, this.userProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _aboutController;

  String? _photoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile?.name ?? '');
    _emailController = TextEditingController(text: widget.userProfile?.email ?? '');
    _phoneController = TextEditingController(text: widget.userProfile?.phone ?? '');
    _aboutController = TextEditingController();
    _photoUrl = widget.userProfile?.photoUrl;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // In production, upload to Firebase Storage and get URL
      setState(() => _photoUrl = image.path);
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      try {
        final userData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          'photoUrl': _photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
          'profileComplete': true,
        };

        // Update in both collections if exists
        final batch = _firestore.batch();

        final guestRef = _firestore.collection('users').doc(user.uid);
        final hostRef = _firestore.collection('hosts').doc(user.uid);

        // Check which collections exist and update them
        final guestDoc = await guestRef.get();
        final hostDoc = await hostRef.get();

        if (guestDoc.exists) batch.update(guestRef, userData);
        if (hostDoc.exists) batch.update(hostRef, userData);

        // If no profile exists, create guest profile
        if (!guestDoc.exists && !hostDoc.exists) {
          batch.set(guestRef, {
            ...userData,
            'uid': user.uid,
            'role': 'guest',
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }

        await batch.commit();

        _showSuccess('Profile updated successfully!');
        Navigator.pop(context, true);
      } catch (e) {
        _showError('Failed to update profile: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userProfile == null ? 'Create Profile' : 'Edit Profile'),
        backgroundColor: const Color(0xFF0b95da),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Photo
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _photoUrl != null
                          ? NetworkImage(_photoUrl!)
                          : null,
                      child: _photoUrl == null
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0b95da),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap to change photo',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: const OutlineInputBorder(),
                  suffixIcon: widget.userProfile?.phoneVerified ?? false
                      ? const Icon(Icons.verified, color: Colors.green)
                      : null,
                ),
              ),

              const SizedBox(height: 16),

              // About (for hosts)
              if (widget.userProfile?.role == 'host' || widget.userProfile?.role == 'both')
                TextFormField(
                  controller: _aboutController,
                  decoration: const InputDecoration(
                    labelText: 'About Me (for hosts)',
                    prefixIcon: Icon(Icons.info),
                    border: OutlineInputBorder(),
                    hintText: 'Tell guests about yourself and your hosting style...',
                  ),
                  maxLines: 4,
                ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0b95da),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text(
                    'Save Profile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}