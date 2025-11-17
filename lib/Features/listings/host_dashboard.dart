// lib/features/listings/host_dashboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel265/features/listings/host_create_listing.dart';
import '../../../material.dart'; // ✅ Your primaryColor

class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const DashboardTab(),
    const ListingsTab(),
    const CalendarTab(),
    const BookingsTab(),
    const MessagesTab(),
  ];

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    // AuthWrapper will redirect to RoleSelection
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Host Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Logout"),
                content: const Text("Are you sure you want to logout?"),
                actions: [
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _logout();
                    },
                    child: const Text("Logout", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        height: 64,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        indicatorColor: primaryColor.withOpacity(0.2),
        destinations: [
          NavigationDestination(
            icon: Icon(_currentIndex == 0 ? Icons.dashboard : Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(_currentIndex == 1 ? Icons.home_work : Icons.home_work_outlined),
            label: 'Listings',
          ),
          NavigationDestination(
            icon: Icon(_currentIndex == 2 ? Icons.calendar_month : Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(_currentIndex == 3 ? Icons.book_online : Icons.book_online_outlined),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(_currentIndex == 4 ? Icons.chat : Icons.chat_outlined),
            label: 'Messages',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HostCreateListingScreen()),
        ),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}

/* -------------------- DASHBOARD TAB -------------------- */
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWelcomeCard(context),
          const SizedBox(height: 16),
          _buildQuickStats(context), // ✅ Pass context
          const SizedBox(height: 16),
          _buildUpcomingBookings(context), // ✅ Pass context
          const SizedBox(height: 16),
          _buildPerformanceSnapshot(context), // ✅ Pass context
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null ? const Icon(Icons.person, size: 30) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user?.displayName ?? 'Host'}!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ready to manage your properties?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Pass context as parameter
  Widget _buildQuickStats(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('hosts')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('listings')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final activeListings = snapshot.data!.docs.length;
        return Row(
          children: [
            Expanded(child: _StatCard(title: 'Active Listings', value: activeListings.toString(), color: Colors.blue, icon: Icons.home_work)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(title: 'This Month', value: 'MWK 0', color: Colors.green, icon: Icons.attach_money)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(title: 'Occupancy', value: '0%', color: Colors.orange, icon: Icons.trending_up)),
          ],
        );
      },
    );
  }

  Widget _buildUpcomingBookings(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.book_online, color: primaryColor),
                const SizedBox(width: 8),
                Text('Upcoming Bookings', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.calendar_today, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text('No upcoming bookings', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSnapshot(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: primaryColor),
                const SizedBox(width: 8),
                Text('Performance Snapshot', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text('Performance data will appear here', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------- STAT CARD -------------------- */
class _StatCard extends StatelessWidget {
  final String title, value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

/* -------------------- PLACEHOLDER TABS -------------------- */
class ListingsTab extends StatelessWidget {
  const ListingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Listings Management - Coming Soon'));
  }
}

class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Availability Calendar - Coming Soon'));
  }
}

class BookingsTab extends StatelessWidget {
  const BookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Bookings Management - Coming Soon'));
  }
}

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Messages - Coming Soon'));
  }
}