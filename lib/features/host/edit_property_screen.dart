import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel265/models/property_model.dart'; // ADD THIS IMPORT
import 'package:travel265/models/property_models.dart'; // ADD THIS IMPORT

class EditPropertyScreen extends StatefulWidget {
  final Property? property;

  const EditPropertyScreen({super.key, this.property});

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _guestsController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bedsController;
  late TextEditingController _bathroomsController;
  late TextEditingController _minNightsController;
  late TextEditingController _cleaningFeeController;
  late TextEditingController _securityDepositController;

  String _selectedType = 'Apartment';
  List<String> _selectedAmenities = [];
  List<HouseRule> _customRules = [];
  List<String> _images = [];
  bool _requireDeposit = true;
  bool _instantBooking = false;
  bool _isLoading = false;

  final List<String> _propertyTypes = [
    'Apartment', 'House', 'Cabin', 'Villa', 'Cottage', 'Studio'
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.property != null) {
      _titleController = TextEditingController(text: widget.property!.title);
      _descriptionController = TextEditingController(text: widget.property!.description);
      _locationController = TextEditingController(text: widget.property!.location);
      _priceController = TextEditingController(text: widget.property!.pricePerNight.toString());
      _guestsController = TextEditingController(text: widget.property!.guests.toString());
      _bedroomsController = TextEditingController(text: widget.property!.bedrooms.toString());
      _bedsController = TextEditingController(text: widget.property!.beds.toString());
      _bathroomsController = TextEditingController(text: widget.property!.bathrooms.toString());
      _minNightsController = TextEditingController(
        text: widget.property!.bookingSettings.minNights.toString(),
      );
      _cleaningFeeController = TextEditingController(
        text: widget.property!.pricingSettings.cleaningFee.toString(),
      );
      _securityDepositController = TextEditingController(
        text: widget.property!.pricingSettings.securityDeposit.toString(),
      );

      _selectedType = widget.property!.type;
      _selectedAmenities = widget.property!.amenities.map((a) => a.name).toList();
      _customRules = widget.property!.houseRules;
      _images = widget.property!.images;
      _requireDeposit = widget.property!.bookingSettings.requireDeposit;
      _instantBooking = widget.property!.bookingSettings.instantBooking;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _locationController = TextEditingController();
      _priceController = TextEditingController(text: '0');
      _guestsController = TextEditingController(text: '1');
      _bedroomsController = TextEditingController(text: '1');
      _bedsController = TextEditingController(text: '1');
      _bathroomsController = TextEditingController(text: '1');
      _minNightsController = TextEditingController(text: '1');
      _cleaningFeeController = TextEditingController(text: '0');
      _securityDepositController = TextEditingController(text: '0');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property == null ? 'Add Property' : 'Edit Property'),
        backgroundColor: const Color(0xFF0b95da),
        foregroundColor: Colors.white,
        actions: [
          if (widget.property != null)
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {
                // Navigate to calendar
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information
            _buildSectionHeader('Basic Information'),
            _buildTextField(_titleController, 'Property Title', Icons.title),
            _buildTextField(_descriptionController, 'Description', Icons.description, maxLines: 4),
            _buildTextField(_locationController, 'Location', Icons.location_on),

            // Property Type
            _buildDropdown('Property Type', _selectedType, _propertyTypes, (value) {
              setState(() => _selectedType = value!);
            }),

            // Capacity
            _buildSectionHeader('Capacity'),
            Row(
              children: [
                Expanded(child: _buildNumberField(_guestsController, 'Guests', Icons.group)),
                const SizedBox(width: 8),
                Expanded(child: _buildNumberField(_bedroomsController, 'Bedrooms', Icons.bed)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildNumberField(_bedsController, 'Beds', Icons.bed)),
                const SizedBox(width: 8),
                Expanded(child: _buildNumberField(_bathroomsController, 'Bathrooms', Icons.bathtub)),
              ],
            ),

            // Pricing
            _buildSectionHeader('Pricing'),
            _buildNumberField(_priceController, 'Price per Night (MWK)', Icons.attach_money),
            _buildNumberField(_cleaningFeeController, 'Cleaning Fee (MWK)', Icons.clean_hands),
            _buildNumberField(_securityDepositController, 'Security Deposit (MWK)', Icons.security),

            // Booking Settings
            _buildSectionHeader('Booking Settings'),
            _buildNumberField(_minNightsController, 'Minimum Nights', Icons.night_shelter),
            _buildSwitch('Require Deposit', _requireDeposit, (value) {
              setState(() => _requireDeposit = value);
            }),
            _buildSwitch('Instant Booking', _instantBooking, (value) {
              setState(() => _instantBooking = value);
            }),

            // Amenities
            _buildSectionHeader('Amenities'),
            _buildAmenitiesGrid(),

            // House Rules
            _buildSectionHeader('House Rules'),
            _buildCustomRules(),

            // Photos
            _buildSectionHeader('Photos'),
            _buildImageUpload(),

            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0b95da),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (int.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF0b95da),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesGrid() {
    final allAmenities = [
      'WiFi', 'Pool', 'Kitchen', 'TV', 'Parking', 'Air Conditioning',
      'Heating', 'Washer', 'Dryer', 'Hot Tub', 'Fireplace', 'BBQ Grill',
      'Breakfast', 'Gym', 'Beach Access', 'Lake View', 'Mountain View'
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3,
      ),
      itemCount: allAmenities.length,
      itemBuilder: (context, index) {
        final amenity = allAmenities[index];
        final isSelected = _selectedAmenities.contains(amenity);

        return FilterChip(
          label: Text(amenity),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedAmenities.add(amenity);
              } else {
                _selectedAmenities.remove(amenity);
              }
            });
          },
          selectedColor: const Color(0xFF0b95da).withOpacity(0.2),
          checkmarkColor: const Color(0xFF0b95da),
        );
      },
    );
  }

  Widget _buildCustomRules() {
    return Column(
      children: [
        ..._customRules.map((rule) => ListTile(
          title: Text(rule.description),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() => _customRules.remove(rule));
            },
          ),
        )),
        TextButton.icon(
          onPressed: _addCustomRule,
          icon: const Icon(Icons.add),
          label: const Text('Add Custom Rule'),
        ),
      ],
    );
  }

  Widget _buildImageUpload() {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._images.map((imageUrl) => Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _images.remove(imageUrl));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, color: Colors.grey),
                    SizedBox(height: 4),
                    Text('Add Photo', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${_images.length}/10 photos',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0b95da),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _isLoading
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      )
          : Text(
        widget.property == null ? 'Create Property' : 'Update Property',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _addCustomRule() {
    showDialog(
      context: context,
      builder: (context) => AddCustomRuleDialog(
        onRuleAdded: (rule) {
          setState(() => _customRules.add(rule));
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // In a real app, you would upload the image to Firebase Storage
      // For now, we'll just add the file path
      setState(() => _images.add(image.path));
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {


        _selectedAmenities.map((name) => Amenity(
          id: name.toLowerCase().replaceAll(' ', '_'),
          name: name,
          icon: Icons.check, // You would map to actual icons
        )).toList();
        Navigator.pop(context, true); // Return success
      } catch (e) {
        setState(() => _isLoading = false);
        _showError('Failed to save property: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

// Additional dialogs for custom rules, etc.
class AddCustomRuleDialog extends StatefulWidget {
  final Function(HouseRule) onRuleAdded;

  const AddCustomRuleDialog({super.key, required this.onRuleAdded});

  @override
  State<AddCustomRuleDialog> createState() => _AddCustomRuleDialogState();
}

class _AddCustomRuleDialogState extends State<AddCustomRuleDialog> {
  final _ruleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Rule'),
      content: TextField(
        controller: _ruleController,
        decoration: const InputDecoration(
          labelText: 'Rule Description',
          hintText: 'e.g., No smoking inside the property',
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addRule,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0b95da)),
          child: const Text('Add Rule'),
        ),
      ],
    );
  }

  void _addRule() {
    if (_ruleController.text.isNotEmpty) {
      final rule = HouseRule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: _ruleController.text,
        icon: Icons.rule, // Default icon
      );
      widget.onRuleAdded(rule);
      Navigator.pop(context);
    }
  }
}