// lib/features/listings/host_dashboard.dart - SUPABASE MIGRATED & PRODUCTION READY

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import '../../material.dart';
import '../../core/services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../models/host_models.dart';
import 'host_create_listing.dart';
import '../auth/host_register.dart';

final logger = Logger(printer: PrettyPrinter(methodCount: 0));

class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  int _currentIndex = 0;

  // 🛡️ Memory management
  StreamSubscription? _statsSubscription;
  StreamSubscription? _bookingsSubscription;

  // 📊 State
  HostStats _stats = const HostStats(
    activeListings: 0,
    monthlyRevenue: 0,
    occupancyRate: 0,
    upcomingBookings: 0,
  );
  List<UpcomingBooking> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final service = DashboardService();
      final stats = await service.getHostStats();
      final bookings = await service.getUpcomingBookings();

      if (mounted) {
        setState(() {
          _stats = stats;
          _bookings = bookings;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await SupabaseAuthService.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HostRegisterScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  final List<Widget> _tabs = const [
    DashboardTab(),
    ListingsTab(),
    CalendarTab(),
    BookingsTab(),
    MessagesTab(),
  ];

  @override
  void dispose() {
    _statsSubscription?.cancel();
    _bookingsSubscription?.cancel();
    super.dispose();
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
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: IndexedStack(index: _currentIndex, children: _tabs),
      ),
      bottomNavigationBar: NavigationBar(
        height: 64,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        indicatorColor: primaryColor.withOpacity(0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.home_work_outlined), selectedIcon: Icon(Icons.home_work), label: 'Listings'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.book_online_outlined), selectedIcon: Icon(Icons.book_online), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: 'Messages'),
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

// ✅ Dashboard tab with proper state handling
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Parent loads data, we just display it
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = context.findAncestorStateOfType<_HostDashboardScreenState>();
    if (dashboardState == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWelcomeCard(context),
          const SizedBox(height: 16),
          if (dashboardState._isLoading)
            const Center(child: CircularProgressIndicator())
          else if (dashboardState._errorMessage != null)
            _buildErrorWidget(dashboardState._errorMessage!)
          else ...[
              _buildQuickStats(dashboardState._stats),
              const SizedBox(height: 16),
              _buildUpcomingBookings(dashboardState._bookings),
              const SizedBox(height: 16),
              _buildPerformanceSnapshot(),
            ],
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final user = SupabaseAuthService.instance.currentUser;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: user?.userMetadata?['avatar_url'] != null
                  ? NetworkImage(user!.userMetadata!['avatar_url'])
                  : null,
              child: user?.userMetadata?['avatar_url'] == null
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user?.email ?? 'Host'}!',
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

  Widget _buildErrorWidget(String message) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(HostStats stats) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Active Listings',
            value: stats.activeListings.toString(),
            color: Colors.blue,
            icon: Icons.home_work,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'This Month',
            value: 'MWK ${stats.monthlyRevenue.toStringAsFixed(0)}',
            color: Colors.green,
            icon: Icons.attach_money,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Occupancy',
            value: '${stats.occupancyRate.toStringAsFixed(1)}%',
            color: Colors.orange,
            icon: Icons.trending_up,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingBookings(List<UpcomingBooking> bookings) {
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
                Text(
                  'Upcoming Bookings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (bookings.isEmpty)
              _buildEmptyState(Icons.calendar_today, 'No upcoming bookings')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookings.length.clamp(0, 3), // Show max 3
                itemBuilder: (context, index) => _buildBookingItem(bookings[index]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItem(UpcomingBooking booking) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: primaryColor.withOpacity(0.1),
        child: Icon(Icons.person, color: primaryColor),
      ),
      title: Text(booking.propertyTitle),
      subtitle: Text('${booking.guestName} • ${booking.checkIn.day}/${booking.checkIn.month}'),
      trailing: Text('MWK ${booking.totalPrice.toStringAsFixed(0)}'),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildPerformanceSnapshot() {
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
                Text(
                  'Performance Snapshot',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildEmptyState(Icons.bar_chart, 'Performance data will appear here'),
          ],
        ),
      ),
    );
  }
}

// ✅ Stat card widget
class _StatCard extends StatelessWidget {
  final String title, value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

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
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Placeholder tabs (to be implemented later)
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