import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel265/models/property_models.dart';
import 'package:travel265/features/services/auth_service.dart';
import 'package:travel265/features/auth/phone_input_screen.dart';
import 'package:travel265/features/profile/edit_profile_screen.dart';
import 'package:travel265/models/user_profile_model.dart';
import 'package:travel265/models/property_models.dart'; // For Amenity, HouseRule, etc.
import 'package:travel265/features/profile/settings_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserProfile? _userProfile;
  bool _isLoading = true;
  String _currentRole = 'guest';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Try to get guest profile first
        final guestDoc = await _firestore.collection('users').doc(user.uid).get();
        if (guestDoc.exists) {
          final data = guestDoc.data()!;
          setState(() {
            _userProfile = UserProfile(
              uid: user.uid,
              name: data['name'] ?? 'User',
              email: data['email'] ?? user.email ?? '',
              phone: data['phone'],
              photoUrl: data['photoUrl'],
              role: data['role'] ?? 'guest',
              joinedDate: (data['createdAt'] as Timestamp).toDate(),
              stats: UserStats(
                totalBookings: data['totalBookings'] ?? 0,
                completedBookings: data['completedBookings'] ?? 0,
                averageRating: (data['averageRating'] ?? 0).toDouble(),
                reviewsCount: data['reviewsCount'] ?? 0,
              ),
              notificationSettings: NotificationSettings(
                bookingNotifications: data['bookingNotifications'] ?? true,
                messageNotifications: data['messageNotifications'] ?? true,
                promotionNotifications: data['promotionNotifications'] ?? true,
                reviewNotifications: data['reviewNotifications'] ?? true,
              ),
              paymentSettings: PaymentSettings(
                defaultPaymentMethod: data['defaultPaymentMethod'] ?? 'paychangu',
                savePaymentInfo: data['savePaymentInfo'] ?? true,
                currency: data['currency'] ?? 'MWK',
              ),
            );
            _currentRole = _userProfile!.role;
          });
        } else {
          // Try to get host profile
          final hostDoc = await _firestore.collection('hosts').doc(user.uid).get();
          if (hostDoc.exists) {
            final data = hostDoc.data()!;
            setState(() {
              _userProfile = UserProfile(
                uid: user.uid,
                name: data['name'] ?? 'Host',
                email: data['email'] ?? user.email ?? '',
                phone: data['phone'],
                photoUrl: data['photoUrl'],
                role: data['role'] ?? 'host',
                joinedDate: (data['createdAt'] as Timestamp).toDate(),
                stats: UserStats(
                  totalBookings: data['totalBookings'] ?? 0,
                  completedBookings: data['completedBookings'] ?? 0,
                  averageRating: (data['averageRating'] ?? 0).toDouble(),
                  reviewsCount: data['reviewsCount'] ?? 0,
                  hostListings: data['listingsCount'] ?? 0,
                ),
                notificationSettings: NotificationSettings(
                  bookingNotifications: data['bookingNotifications'] ?? true,
                  messageNotifications: data['messageNotifications'] ?? true,
                  promotionNotifications: data['promotionNotifications'] ?? true,
                  reviewNotifications: data['reviewNotifications'] ?? true,
                ),
                paymentSettings: PaymentSettings(
                  defaultPaymentMethod: data['defaultPaymentMethod'] ?? 'paychangu',
                  savePaymentInfo: data['savePaymentInfo'] ?? true,
                  currency: data['currency'] ?? 'MWK',
                ),
              );
              _currentRole = _userProfile!.role;
            });
          }
        }
      } catch (e) {
        print('Error loading user profile: $e');
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _switchRole(String newRole) async {
    if (_userProfile == null) return;

    setState(() => _isLoading = true);

    try {
      // Update role in both collections if user has both profiles
      final batch = _firestore.batch();

      final guestRef = _firestore.collection('users').doc(_userProfile!.uid);
      final hostRef = _firestore.collection('hosts').doc(_userProfile!.uid);

      batch.update(guestRef, {'currentRole': newRole});
      batch.update(hostRef, {'currentRole': newRole});

      await batch.commit();

      setState(() {
        _currentRole = newRole;
        _userProfile = _userProfile!.copyWith(role: newRole);
      });

      _showSuccess('Switched to ${newRole == 'host' ? 'Host' : 'Guest'} mode');
    } catch (e) {
      _showError('Failed to switch role: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
          ? _buildNoProfile()
          : _buildProfileContent(),
    );
  }

  Widget _buildNoProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Profile Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Please complete your profile setup'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              ).then((_) => _loadUserProfile());
            },
            child: const Text('Setup Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          _buildProfileHeader(),
          const SizedBox(height: 24),

          // Role Switching (if user has both roles)
          if (_userProfile!.role == 'both') _buildRoleSwitch(),
          const SizedBox(height: 24),

          // Stats Cards
          _buildStatsSection(),
          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 24),

          // Profile Sections
          _buildProfileSections(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey[200],
          backgroundImage: _userProfile!.photoUrl != null
              ? NetworkImage(_userProfile!.photoUrl!)
              : null,
          child: _userProfile!.photoUrl == null
              ? const Icon(Icons.person, size: 40, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userProfile!.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userProfile!.email,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              if (_userProfile!.phone != null)
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _userProfile!.phone!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (_userProfile!.phoneVerified ?? false)
                      const Row(
                        children: [
                          SizedBox(width: 4),
                          Icon(Icons.verified, size: 14, color: Colors.green),
                        ],
                      ),
                  ],
                ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(userProfile: _userProfile!),
                    ),
                  ).then((_) => _loadUserProfile());
                },
                child: const Text('Edit Profile'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSwitch() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Switch Mode',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _currentRole == 'guest' ? null : () => _switchRole('guest'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _currentRole == 'guest' ? Colors.white : const Color(0xFF0b95da),
                      backgroundColor: _currentRole == 'guest' ? const Color(0xFF0b95da) : Colors.transparent,
                    ),
                    child: const Text('Guest Mode'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _currentRole == 'host' ? null : () => _switchRole('host'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _currentRole == 'host' ? Colors.white : const Color(0xFF0b95da),
                      backgroundColor: _currentRole == 'host' ? const Color(0xFF0b95da) : Colors.transparent,
                    ),
                    child: const Text('Host Mode'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Bookings',
            _userProfile!.stats.totalBookings.toString(),
            Icons.book_online,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Rating',
            _userProfile!.stats.averageRating.toStringAsFixed(1),
            Icons.star,
          ),
        ),
        if (_currentRole == 'host') ...[
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Listings',
              _userProfile!.stats.hostListings.toString(),
              Icons.home_work,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0b95da)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_currentRole == 'guest')
                  ActionChip(
                    avatar: const Icon(Icons.favorite_border, size: 16),
                    label: const Text('Wishlist'),
                    onPressed: () {},
                  ),
                if (_currentRole == 'host')
                  ActionChip(
                    avatar: const Icon(Icons.add_home_work, size: 16),
                    label: const Text('Add Listing'),
                    onPressed: () {},
                  ),
                ActionChip(
                  avatar: const Icon(Icons.help_outline, size: 16),
                  label: const Text('Help'),
                  onPressed: () {},
                ),
                if (_userProfile!.phone == null || !(_userProfile!.phoneVerified ?? false))
                  ActionChip(
                    avatar: const Icon(Icons.phone, size: 16),
                    label: const Text('Verify Phone'),
                    onPressed: _verifyPhone,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSections() {
    return Column(
      children: [
        _buildProfileSection(
          'Personal Information',
          Icons.person_outline,
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(userProfile: _userProfile!),
              ),
            ).then((_) => _loadUserProfile());
          },
        ),
        _buildProfileSection(
          'Booking History',
          Icons.history,
              () {
            // Navigate to booking history
          },
        ),
        if (_currentRole == 'host')
          _buildProfileSection(
            'Host Dashboard',
            Icons.dashboard,
                () {
              // Navigate to host dashboard
            },
          ),
        _buildProfileSection(
          'Payment Methods',
          Icons.payment,
              () {
            // Navigate to payment methods
          },
        ),
        _buildProfileSection(
          'Security',
          Icons.security,
              () {
            // Navigate to security settings
          },
        ),
      ],
    );
  }

  Widget _buildProfileSection(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0b95da)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _verifyPhone() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhoneInputScreen(
          isHost: _currentRole == 'host',
          isLinking: true,
          email: _userProfile!.email,
        ),
      ),
    ).then((success) {
      if (success == true) {
        _loadUserProfile();
      }
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}