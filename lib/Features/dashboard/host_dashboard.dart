// lib/features/dashboard/host_dashboard.dart

import 'package:flutter/material.dart';
import 'package:travel265/core/services/auth_service.dart';
import 'package:travel265/features/dashboard/data/services/dashboard_service.dart';
import 'package:travel265/features/dashboard/domain/models/host_stats_model.dart';
import 'package:travel265/features/dashboard/domain/models/upcoming_booking_model.dart';
import 'package:travel265/core/theme/app_theme.dart';
import 'package:travel265/core/utils/logger.dart';

// ✅ Ensure this class name is EXACTLY "HostDashboardScreen"
class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  int _currentIndex = 0;
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
      final stats = await DashboardService.instance.getHostStats();
      final bookings = await DashboardService.instance.getUpcomingBookings();

      if (mounted) {
        setState(() {
          _stats = stats;
          _bookings = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      logger.e('Dashboard load failed', error: e);
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/host_register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: DashboardTab(
        stats: _stats,
        bookings: _bookings,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onRefresh: _loadData,
      ),
    );
  }
}

// ✅ Tab widget
class DashboardTab extends StatelessWidget {
  final HostStats stats;
  final List<UpcomingBooking> bookings;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;

  const DashboardTab({
    super.key,
    required this.stats,
    required this.bookings,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) return Center(child: Text('Error: $errorMessage'));

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(bookings[index].propertyTitle),
      ),
    );
  }
}