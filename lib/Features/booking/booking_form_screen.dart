//lib/features/booking/booking_form_screen
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel265/core/blocs/booking/booking_bloc.dart';
import 'package:travel265/core/blocs/booking/booking_event.dart';
import 'package:travel265/core/models/booking_model.dart';
import 'package:travel265/core/models/property_model.dart';
import 'package:uuid/uuid.dart';
import 'package:travel265/core/blocs/auth/auth_state.dart';
import 'package:travel265/core/services/auth_service.dart';

class BookingFormScreen extends StatefulWidget {
  final PropertyModel property;

  const BookingFormScreen({super.key, required this.property});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _checkInController = TextEditingController();
  final _checkOutController = TextEditingController();
  final _guestsController = TextEditingController();

  @override
  void dispose() {
    _checkInController.dispose();
    _checkOutController.dispose();
    _guestsController.dispose();
    super.dispose();
  }

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      final booking = BookingModel(
        id: const Uuid().v4(),
        propertyId: widget.property.id,
        guestId: context.read<AuthBloc>().state.user!.id,
        checkIn: DateTime.parse(_checkInController.text),
        checkOut: DateTime.parse(_checkOutController.text),
        numberOfGuests: int.parse(_guestsController.text),
        totalPrice: widget.property.pricePerNight * _calculateTotalNights(),
        currency: widget.property.currency,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        property: widget.property, // Pass the property model
      );

      context.read<BookingBloc>().add(CreateBooking(booking));
    }
  }

  int _calculateTotalNights() {
    final checkIn = DateTime.parse(_checkInController.text);
    final checkOut = DateTime.parse(_checkOutController.text);
    return checkOut.difference(checkIn).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Property'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Property: ${widget.property.title}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _checkInController,
                decoration: _inputDecoration(context, 'Check-In Date', Icons.calendar_today, theme.colorScheme.primary),
                validator: (value) => value!.isEmpty ? 'Enter check-in date' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _checkOutController,
                decoration: _inputDecoration(context, 'Check-Out Date', Icons.calendar_today, theme.colorScheme.primary),
                validator: (value) => value!.isEmpty ? 'Enter check-out date' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _guestsController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(context, 'Number of Guests', Icons.group, theme.colorScheme.primary),
                validator: (value) => value!.isEmpty ? 'Enter number of guests' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitBooking,
                child: const Text('Confirm Booking'),
              ),
            ],
          ),
        ),
      ),
    );
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
}