// lib/features/listings/host_create_listing_screen.dart

// This screen allows authenticated hosts to create a new property listing.
// Uses Supabase for:
// - Authentication (via SupabaseAuthService)
// - Image storage (Supabase Storage bucket: 'host-listing-photos')
// - Database (PostgreSQL 'listings' table)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart'; // For generating listing ID
import '../services/auth_service.dart';
import 'host_dashboard.dart';

final supabase = Supabase.instance.client;

/* -------------------------------------------------------------------------- */
/*  Property Type Options                                                       */
/* -------------------------------------------------------------------------- */
enum PropertyType {
  apartment('Apartment'),
  house('House'),
  cottage('Cottage'),
  villa('Villa'),
  guestHouse('Guest House'),
  hostel('Hostel');

  final String displayName;
  const PropertyType(this.displayName);
}

/* -------------------------------------------------------------------------- */
/*  Amenity Options                                                             */
/* -------------------------------------------------------------------------- */
class Amenity {
  final String id;
  final String name;
  final IconData icon;

  const Amenity(this.id, this.name, this.icon);
}

final List<Amenity> amenitiesList = [
  Amenity('wifi', 'Wifi', Icons.wifi),
  Amenity('ac', 'Air Conditioning', Icons.ac_unit),
  Amenity('pool', 'Pool', Icons.pool),
  Amenity('parking', 'Parking', Icons.local_parking),
  Amenity('kitchen', 'Kitchen', Icons.kitchen),
  Amenity('tv', 'TV', Icons.tv),
  Amenity('washer', 'Washer', Icons.local_laundry_service),
  Amenity('dryer', 'Dryer', Icons.local_laundry_service),
  Amenity('heating', 'Heating', Icons.thermostat),
  Amenity('elevator', 'Elevator', Icons.elevator),
  Amenity('gym', 'Gym', Icons.fitness_center),
  Amenity('breakfast', 'Breakfast', Icons.restaurant),
];

/* -------------------------------------------------------------------------- */
/*  Helper: Validate Google Maps URL                                            */
/* -------------------------------------------------------------------------- */
bool _isValidGoogleMapsUrl(String url) {
  if (url.isEmpty) return false;
  try {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.host.contains('google.com') || uri.host.contains('maps.app.goo.gl');
  } catch (e) {
    return false;
  }
}

void _showHowToGetLink(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("How to Get Google Maps Link"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("1. Open Google Maps on your phone"),
            const SizedBox(height: 8),
            const Text("2. Search for your property or drop a pin"),
            const SizedBox(height: 8),
            const Text("3. Tap the place name at the bottom"),
            const SizedBox(height: 8),
            const Text("4. Tap 'Share' → 'Copy link'"),
            const SizedBox(height: 16),
            const Text("✅ Paste that link here!"),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Got it!"),
        ),
      ],
    ),
  );
}

/* -------------------------------------------------------------------------- */
/*  Screen                                                                      */
/* -------------------------------------------------------------------------- */
class HostCreateListingScreen extends StatefulWidget {
  const HostCreateListingScreen({super.key});

  @override
  State<HostCreateListingScreen> createState() => _HostCreateListingScreenState();
}

class _HostCreateListingScreenState extends State<HostCreateListingScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _propertyNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _houseRulesController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationUrlController = TextEditingController();
  final _maxGuestsController = TextEditingController();

  PropertyType? _selectedPropertyType;
  final Set<String> _selectedAmenities = {};
  final List<Uint8List> _selectedImages = [];
  bool _providesBreakfast = false;
  bool _isSelfCatering = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isDraft = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _propertyNameController.dispose();
    _descriptionController.dispose();
    _houseRulesController.dispose();
    _priceController.dispose();
    _locationUrlController.dispose();
    _maxGuestsController.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /* --------------------  image handling  -------------------- */
  Future<void> _pickMultipleImages() async {
    if (_selectedImages.length >= 10) {
      _showSnack('Maximum 10 images allowed', isError: true);
      return;
    }
    try {
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 70, limit: 10 - _selectedImages.length);
      if (pickedFiles.isEmpty) return;

      final bytesList = await Future.wait(
        pickedFiles.map((file) => file.readAsBytes()),
      );
      setState(() => _selectedImages.addAll(bytesList));
    } catch (e) {
      _showSnack('Failed to pick images', isError: true);
    }
  }

  Future<void> _pickFromCamera() async {
    if (_selectedImages.length >= 10) {
      _showSnack('Maximum 10 images allowed', isError: true);
      return;
    }
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      setState(() => _selectedImages.add(bytes));
    } catch (e) {
      _showSnack('Failed to capture image', isError: true);
    }
  }

  void _removeImage(Uint8List imageBytes) {
    setState(() => _selectedImages.remove(imageBytes));
  }

  /* --------------------  Supabase image upload  -------------------- */
  Future<List<String>> _uploadImages(String hostId, String listingId) async {
    List<String> downloadUrls = [];
    for (var i = 0; i < _selectedImages.length; i++) {
      try {
        Uint8List imageData = _selectedImages[i];
        String fileName = 'image_${i + 1}.jpg';
        String filePath = 'hosts/$hostId/listings/$listingId/$fileName';

        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(imageData);

        await supabase.storage.from('host-listing-photos').upload(
          filePath,
          tempFile,
          fileOptions: const FileOptions(upsert: true),
        );

        final publicUrl = supabase.storage.from('host-listing-photos').getPublicUrl(filePath);
        downloadUrls.add(publicUrl);
        await tempFile.delete();
      } catch (e) {
        print('Error uploading image $i: $e');
        rethrow;
      }
    }
    return downloadUrls;
  }

  /* --------------------  Save listing to Supabase  -------------------- */
  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = SupabaseAuthService();
    if (!authService.isUserLoggedIn) {
      _showSnack("You must be logged in as a host to create a listing.", isError: true);
      return;
    }
    final hostId = authService.currentUserId!;

    if (_selectedImages.isEmpty) {
      _showSnack("Please add at least one photo of your property.", isError: true);
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    // Generate a UUID for the listing (used in image paths and DB)
    final listingId = const Uuid().v4();

    try {
      setState(() => _isUploading = true);
      final imageUrls = await _uploadImages(hostId, listingId);
      setState(() => _isUploading = false);

      // Save to Supabase 'listings' table
      await supabase.from('listings').insert({
        'id': listingId, // Optional if 'id' is auto-generated
        'host_id': hostId,
        'property_name': _propertyNameController.text.trim(),
        'property_type': _selectedPropertyType?.name,
        'price': int.parse(_priceController.text.trim().replaceAll(',', '')),
        'location_url': _locationUrlController.text.trim(),
        'max_guests': int.tryParse(_maxGuestsController.text.trim()) ?? 2,
        'provides_breakfast': _providesBreakfast,
        'is_self_catering': _isSelfCatering,
        'description': _descriptionController.text.trim(),
        'amenities': _selectedAmenities.toList(),
        'house_rules': _houseRulesController.text.trim(),
        'photos': imageUrls,
        'is_active': !_isDraft,
        'is_draft': _isDraft,
      });

      _showSnack(_isDraft ? 'Draft saved!' : 'Listing published!', isError: false);
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HostDashboardScreen()),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      _showSnack('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "New Listing",
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AnimatedPropertyName(controller: _propertyNameController, primaryColor: primaryColor, isDark: isDark),
                const SizedBox(height: 16),
                _AnimatedPropertyType(
                  selectedType: _selectedPropertyType,
                  onTypeChanged: (type) => setState(() => _selectedPropertyType = type),
                  primaryColor: primaryColor,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildLocationUrlField(
                  controller: _locationUrlController,
                  primaryColor: primaryColor,
                  isDark: isDark,
                  onHelpPressed: () => _showHowToGetLink(context),
                ),
                const SizedBox(height: 16),
                _AnimatedPrice(controller: _priceController, primaryColor: primaryColor, isDark: isDark),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maxGuestsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoration(context, 'Max Guests', Icons.group, primaryColor),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter max guests';
                    final num = int.tryParse(v.trim());
                    if (num == null || num < 1 || num > 50) return 'Enter 1–50 guests';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _AnimatedDescription(controller: _descriptionController, primaryColor: primaryColor, isDark: isDark),
                const SizedBox(height: 16),
                _AnimatedAmenities(
                  selectedAmenities: _selectedAmenities,
                  onAmenityToggle: (amenityId) {
                    setState(() {
                      if (_selectedAmenities.contains(amenityId)) {
                        _selectedAmenities.remove(amenityId);
                      } else {
                        _selectedAmenities.add(amenityId);
                      }
                    });
                  },
                  primaryColor: primaryColor,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _AnimatedPhotos(
                  selectedImages: _selectedImages,
                  onAddFromGallery: _pickMultipleImages,
                  onAddFromCamera: _pickFromCamera,
                  onRemoveImage: _removeImage,
                  isUploading: _isUploading,
                  primaryColor: primaryColor,
                  isDark: isDark,
                ),
                const SizedBox(height: 4),
                Text(
                  "📸 Tip: Upload clear photos of your living room, bedroom, bathroom, and exterior.",
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _AnimatedHouseRules(controller: _houseRulesController, primaryColor: primaryColor, isDark: isDark),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildToggleOption(
                      title: "Breakfast Included",
                      value: _providesBreakfast,
                      onChanged: (v) => setState(() => _providesBreakfast = v!),
                      icon: Icons.restaurant,
                    ),
                    const SizedBox(width: 16),
                    _buildToggleOption(
                      title: "Self Catering",
                      value: _isSelfCatering,
                      onChanged: (v) => setState(() => _isSelfCatering = v!),
                      icon: Icons.kitchen,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () {
                          _isDraft = false;
                          _saveListing();
                        },
                        child: const Text("Publish Listing"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () {
                          _isDraft = true;
                          _saveListing();
                        },
                        child: const Text("Save Draft"),
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

  Widget _buildLocationUrlField({
    required TextEditingController controller,
    required Color primaryColor,
    required bool isDark,
    required VoidCallback onHelpPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Location (Google Maps Link)",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            TextButton(
              onPressed: onHelpPressed,
              child: const Text("How?"),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          decoration: _inputDecoration(
            context,
            'Paste Google Maps link',
            Icons.link,
            primaryColor,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Paste a Google Maps link';
            if (!_isValidGoogleMapsUrl(value.trim())) return 'Enter a valid Google Maps link';
            return null;
          },
        ),
        const SizedBox(height: 4),
        Text(
          "Example: https://maps.app.goo.gl/...    ",
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildToggleOption({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        color: value ? Colors.blue.shade50 : null,
        child: InkWell(
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(icon, color: value ? Colors.blue : Colors.grey),
                const SizedBox(height: 4),
                Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: value ? FontWeight.bold : null)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ====================================================================== */
/*                           ANIMATED COMPONENTS                          */
/* ====================================================================== */
class _AnimatedPropertyName extends StatefulWidget {
  final TextEditingController controller;
  final Color primaryColor;
  final bool isDark;

  const _AnimatedPropertyName({
    required this.controller,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  State<_AnimatedPropertyName> createState() => _AnimatedPropertyNameState();
}

class _AnimatedPropertyNameState extends State<_AnimatedPropertyName>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    Future.delayed(const Duration(milliseconds: 100), () => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: TextFormField(
          controller: widget.controller,
          decoration: _inputDecoration(
            context,
            'Property Name',
            Icons.home_work_outlined,
            widget.primaryColor,
          ),
          validator: (value) => (value?.trim().isEmpty ?? true) ? "Enter property name" : null,
        ),
      ),
    );
  }
}

class _AnimatedPrice extends StatefulWidget {
  final TextEditingController controller;
  final Color primaryColor;
  final bool isDark;
  const _AnimatedPrice({required this.controller, required this.primaryColor, required this.isDark});

  @override
  State<_AnimatedPrice> createState() => _AnimatedPriceState();
}

class _AnimatedPriceState extends State<_AnimatedPrice> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    Future.delayed(const Duration(milliseconds: 250), () => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _ThousandsSeparatorInputFormatter(),
          ],
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(context, 'Price per Night (MWK)', Icons.attach_money_outlined, widget.primaryColor),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Enter a price';
            final clean = value.trim().replaceAll(',', '');
            final num = int.tryParse(clean);
            if (num == null || num <= 0) return 'Price must be a positive number';
            return null;
          },
        ),
      ),
    );
  }
}

class _AnimatedPropertyType extends StatefulWidget {
  final PropertyType? selectedType;
  final ValueChanged<PropertyType?> onTypeChanged;
  final Color primaryColor;
  final bool isDark;

  const _AnimatedPropertyType({
    required this.selectedType,
    required this.onTypeChanged,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  State<_AnimatedPropertyType> createState() => _AnimatedPropertyTypeState();
}

class _AnimatedPropertyTypeState extends State<_AnimatedPropertyType>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    Future.delayed(const Duration(milliseconds: 200), () => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: DropdownButtonFormField<PropertyType>(
          decoration: _inputDecoration(
            context,
            'Property Type',
            Icons.category_outlined,
            widget.primaryColor,
          ),
          value: widget.selectedType,
          items: PropertyType.values.map((PropertyType type) {
            return DropdownMenuItem<PropertyType>(
              value: type,
              child: Text(
                type.displayName,
                style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
              ),
            );
          }).toList(),
          onChanged: widget.onTypeChanged,
          validator: (val) => val == null ? "Select property type" : null,
        ),
      ),
    );
  }
}

class _AnimatedDescription extends StatefulWidget {
  final TextEditingController controller;
  final Color primaryColor;
  final bool isDark;

  const _AnimatedDescription({
    required this.controller,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  State<_AnimatedDescription> createState() => _AnimatedDescriptionState();
}

class _AnimatedDescriptionState extends State<_AnimatedDescription>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    Future.delayed(const Duration(milliseconds: 300), () => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: TextFormField(
          controller: widget.controller,
          decoration: _inputDecoration(
            context,
            'Description',
            Icons.description_outlined,
            widget.primaryColor,
          ),
          maxLines: 4,
          validator: (value) => (value?.trim().isEmpty ?? true) ? "Enter description" : null,
        ),
      ),
    );
  }
}

class _AnimatedAmenities extends StatefulWidget {
  final Set<String> selectedAmenities;
  final ValueChanged<String> onAmenityToggle;
  final Color primaryColor;
  final bool isDark;

  const _AnimatedAmenities({
    required this.selectedAmenities,
    required this.onAmenityToggle,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  State<_AnimatedAmenities> createState() => _AnimatedAmenitiesState();
}

class _AnimatedAmenitiesState extends State<_AnimatedAmenities>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    Future.delayed(const Duration(milliseconds: 400), () => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Amenities",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: amenitiesList.map((amenity) {
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(amenity.icon, size: 16),
                      const SizedBox(width: 4),
                      Text(amenity.name),
                    ],
                  ),
                  selected: widget.selectedAmenities.contains(amenity.id),
                  selectedColor: widget.primaryColor.withOpacity(0.2),
                  backgroundColor: widget.isDark ? Colors.grey[800] : Colors.grey[200],
                  checkmarkColor: widget.primaryColor,
                  onSelected: (selected) => widget.onAmenityToggle(amenity.id),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedPhotos extends StatefulWidget {
  final List<Uint8List> selectedImages; // ✅ Uint8List
  final VoidCallback onAddFromGallery;
  final VoidCallback onAddFromCamera;
  final ValueChanged<Uint8List> onRemoveImage; // ✅ Uint8List
  final bool isUploading;
  final Color primaryColor;
  final bool isDark;

  const _AnimatedPhotos({
    required this.selectedImages,
    required this.onAddFromGallery,
    required this.onAddFromCamera,
    required this.onRemoveImage,
    required this.isUploading,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  State<_AnimatedPhotos> createState() => _AnimatedPhotosState();
}

class _AnimatedPhotosState extends State<_AnimatedPhotos>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    Future.delayed(const Duration(milliseconds: 500), () => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Photos",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.isUploading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...widget.selectedImages.map((imageBytes) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory( // ✅ Image.memory
                        imageBytes,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: widget.isDark ? Colors.grey[800] : Colors.grey[300],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -8,
                      top: -8,
                      child: GestureDetector(
                        onTap: () => widget.onRemoveImage(imageBytes),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red.shade600,
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )),
                GestureDetector(
                  onTap: widget.onAddFromGallery,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: widget.isDark ? Colors.grey[800] : Colors.grey[100],
                      border: Border.all(
                        color: widget.isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.photo_library, size: 24),
                        Text('Gallery', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onAddFromCamera,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: widget.isDark ? Colors.grey[800] : Colors.grey[100],
                      border: Border.all(
                        color: widget.isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.camera_alt, size: 24),
                        Text('Camera', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "${widget.selectedImages.length}/10 photos",
              style: TextStyle(
                color: widget.isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedHouseRules extends StatefulWidget {
  final TextEditingController controller;
  final Color primaryColor;
  final bool isDark;

  const _AnimatedHouseRules({
    required this.controller,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  State<_AnimatedHouseRules> createState() => _AnimatedHouseRulesState();
}

class _AnimatedHouseRulesState extends State<_AnimatedHouseRules>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    Future.delayed(const Duration(milliseconds: 600), () => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: TextFormField(
          controller: widget.controller,
          decoration: _inputDecoration(
            context,
            'House Rules',
            Icons.rule_outlined,
            widget.primaryColor,
          ),
          maxLines: 3,
        ),
      ),
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    if (newValue.text.compareTo(oldValue.text) == 0) return oldValue;

    final clean = newValue.text.replaceAll(',', '');
    if (clean.isEmpty) return newValue.copyWith(text: '');

    final intNum = int.tryParse(clean);
    if (intNum == null) return oldValue;

    final formatted = NumberFormat("#,##0", "en_US").format(intNum);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

InputDecoration _inputDecoration(BuildContext context, String label, IconData icon, Color primaryColor) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: isDark ? Colors.white70 : Colors.grey),
    filled: true,
    fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 2)),
  );
}