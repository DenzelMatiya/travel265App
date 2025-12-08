//lib/features/properties/property_details_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travel265/core/models/property_model.dart';
import 'package:travel265/features/booking/booking_summary_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final PageController _imageController = PageController();
  int _currentImageIndex = 0;
  DateTime? _selectedCheckIn;
  DateTime? _selectedCheckOut;
  // UNUSED FIELD - remove if not needed: int _guests = 1; // Currently unused

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Image Gallery with App Bar
          SliverAppBar(
            expandedHeight: 320,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9), // FIXED: withOpacity
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.9), // FIXED
                      child: IconButton(
                        icon: const Icon(Icons.share, color: Colors.black87),
                        onPressed: _shareProperty,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.9), // FIXED
                      child: IconButton(
                        icon: Icon(
                          widget.property.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.property.isFavorite
                              ? Colors.red
                              : Colors.black87,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image Gallery
                  PageView.builder(
                    controller: _imageController,
                    itemCount: widget.property.imageUrls.length,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: widget.property.imageUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.home, size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  ),

                  // Image Indicator
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.property.imageUrls.length, (index) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5), // FIXED
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Property Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Basic Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.property.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${widget.property.type.name} in ${widget.property.city}", // FIXED: use type.name and city
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${widget.property.maxGuests} guests · ${widget.property.bedrooms} bedrooms · ${widget.property.bedrooms} beds · ${widget.property.bathrooms} bath", // FIXED: use bedrooms instead of beds
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            widget.property.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "(${widget.property.reviewCount} reviews)",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),

                  // Host Info - FIXED: Map access
                  if (widget.property.host != null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: widget.property.host!['photo_url'] != null &&
                              widget.property.host!['photo_url']!.isNotEmpty
                              ? CachedNetworkImageProvider(widget.property.host!['photo_url'])
                              : null,
                          child: widget.property.host!['photo_url'] == null ||
                              widget.property.host!['photo_url']!.isEmpty
                              ? const Icon(Icons.person, size: 30, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hosted by ${widget.property.host!['name'] ?? 'Host'}", // FIXED
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${(widget.property.host!['is_superhost'] == true) ? 'Superhost' : 'Host'} · ${widget.property.host!['hosting_since'] ?? '0'} years hosting", // FIXED
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                  ],

                  // Description
                  const Text(
                    "About this place",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.property.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),

                  // Amenities - FIXED: String list
                  if (widget.property.amenities.isNotEmpty) ...[
                    const Text(
                      "What this place offers",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 3,
                      ),
                      itemCount: widget.property.amenities.length,
                      itemBuilder: (context, index) {
                        final amenity = widget.property.amenities[index];
                        return Row(
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF0b95da)), // FIXED: Default icon
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                amenity,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                  ],

                  // Location
                  const Text(
                    "Where you'll be",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: Stack(
                      children: [
                        // Map placeholder
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on, size: 40, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                "Approximate location\n${widget.property.distanceFromLandmark ?? 'Unknown distance'} from ${widget.property.nearestLandmark ?? 'nearest landmark'}", // FIXED: Null safety
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1), // FIXED
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              "Exact location after booking",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.property.locationDescription ?? 'No location description available.', // FIXED: Null safety
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),

                  // House Rules - FIXED: String list
                  if (widget.property.houseRules != null && widget.property.houseRules!.isNotEmpty) ...[
                    const Text(
                      "House rules",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: widget.property.houseRules!.map((rule) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.rule, color: Colors.grey), // FIXED: Default icon
                              const SizedBox(width: 12),
                              Expanded(child: Text(rule)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                  ],

                  // Reviews - FIXED: Map access
                  if (widget.property.reviews.isNotEmpty) ...[
                    const Text(
                      "Reviews",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildReviewsSection(),
                  ],

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Booking Bar
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "MWK ${widget.property.pricePerNight} / night",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (_selectedCheckIn != null && _selectedCheckOut != null)
                    Text(
                      "${_selectedCheckIn!.day} - ${_selectedCheckOut!.day} ${_getMonthName(_selectedCheckIn!.month)}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingSummaryScreen(
                      property: widget.property,
                      checkIn: _selectedCheckIn ?? DateTime.now(),
                      checkOut: _selectedCheckOut ?? DateTime.now().add(const Duration(days: 2)),
                      guests: 1, // FIXED: Use actual value if needed
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0b95da),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Reserve",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      children: [
        ...widget.property.reviews.take(3).map((review) { // FIXED: Remove unnecessary toList()
          return _buildReviewCard(review);
        }),
        if (widget.property.reviews.length > 3)
          TextButton(
            onPressed: _showAllReviews,
            child: Text("Show all ${widget.property.reviews.length} reviews"),
          ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: review['user_photo'] != null &&
                    review['user_photo']!.isNotEmpty
                    ? CachedNetworkImageProvider(review['user_photo'])
                    : null,
                child: review['user_photo'] == null || review['user_photo']!.isEmpty
                    ? const Icon(Icons.person, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['user_name'] ?? 'Guest', // FIXED: Map access
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text((review['rating'] ?? 0).toStringAsFixed(1)), // FIXED
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(review['date'] ?? DateTime.now()), // FIXED
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'] ?? '', // FIXED: Map access
            style: const TextStyle(
              height: 1.4,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showAllReviews() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "All Reviews",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.property.reviews.length,
                  itemBuilder: (context, index) {
                    final review = widget.property.reviews[index];
                    return _buildReviewCard(review);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareProperty() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _toggleFavorite() {
    setState(() {
      // This would normally update in the database
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorite functionality coming soon!')),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    DateTime dateTime;
    if (date is String) {
      dateTime = DateTime.tryParse(date) ?? DateTime.now();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      dateTime = DateTime.now();
    }
    return "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}";
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}