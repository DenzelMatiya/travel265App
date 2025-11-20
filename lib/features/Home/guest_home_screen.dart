import 'package:flutter/material.dart';
import 'package:travel265/core/services/auth_service.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const BookingsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TRAVEL 265"),
        backgroundColor: const Color(0xFF0b95da),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              _showLanguageDialog();
            },
            tooltip: 'Change Language',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF0b95da),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthService().signOut();
                // Navigation will be handled by AuthWrapper
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text("English"),
                onTap: () {
                  Navigator.of(context).pop();
                  // Implement language change
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text("Chichewa"),
                onTap: () {
                  Navigator.of(context).pop();
                  // Implement language change
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Home Screen with Listings
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Find your perfect stay in Malawi",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Discover unique accommodations across the Warm Heart of Africa",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: TextEditingController(),
              decoration: InputDecoration(
                hintText: "Search destinations, properties...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Categories
          Text(
            "Browse by Category",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _CategoryCard(
                  icon: Icons.beach_access,
                  title: "Beach",
                  color: Colors.blue,
                ),
                _CategoryCard(
                  icon: Icons.landscape,
                  title: "Nature",
                  color: Colors.green,
                ),
                _CategoryCard(
                  icon: Icons.apartment,
                  title: "City",
                  color: Colors.orange,
                ),
                _CategoryCard(
                  icon: Icons.house,
                  title: "Cottage",
                  color: Colors.purple,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Featured Listings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Featured Stays",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "See all",
                  style: TextStyle(color: Color(0xFF0b95da)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Listings
          Column(
            children: const [
              _ListingCard(
                image: "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400",
                title: "Cozy Lakeside Cabin",
                location: "Near Lake Malawi, Mangochi",
                price: "MWK 45,000",
                rating: 4.8,
              ),
              SizedBox(height: 12),
              _ListingCard(
                image: "https://images.unsplash.com/photo-1551524165-68e03a1f0f0c?w=400",
                title: "Urban Chic Apartment",
                location: "Central Lilongwe",
                price: "MWK 60,000",
                rating: 4.6,
              ),
              SizedBox(height: 12),
              _ListingCard(
                image: "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400",
                title: "Mountain View Lodge",
                location: "Zomba Plateau",
                price: "MWK 35,000",
                rating: 4.9,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Category Card Widget
class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Listing Card Widget
class _ListingCard extends StatelessWidget {
  final String image;
  final String title;
  final String location;
  final String price;
  final double rating;

  const _ListingCard({
    required this.image,
    required this.title,
    required this.location,
    required this.price,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to listing details
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                image,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: const Icon(Icons.home, size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0b95da),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bookings Screen (Stub)
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Your Bookings",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "No bookings yet",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// Profile Screen (Stub)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFF0b95da),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            "Guest User",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "guest@example.com",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}