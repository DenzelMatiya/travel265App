//lib/features/booking/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:travel265/core/models/booking_model.dart';
import 'package:travel265/core/models/property_model.dart';
import 'package:travel265/features/booking/confirmation_screen.dart';
import 'package:uuid/uuid.dart';

class PaymentScreen extends StatefulWidget {
  final PropertyModel property;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final int totalAmount;
  final int depositAmount;

  const PaymentScreen({
    super.key,
    required this.property,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalAmount,
    required this.depositAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentOption = 'deposit';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final amountToPay = _selectedPaymentOption == 'deposit'
        ? widget.depositAmount
        : widget.totalAmount;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Secure Payment",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Options
            const Text(
              "Choose how to pay",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildPaymentOption(
                  value: 'deposit',
                  title: "Pay 50% deposit",
                  subtitle: "Pay MWK ${widget.depositAmount.toStringAsFixed(0)} now, and the rest later.",
                  amount: "MWK ${widget.depositAmount.toStringAsFixed(0)}",
                ),
                const SizedBox(height: 12),
                _buildPaymentOption(
                  value: 'full',
                  title: "Pay the full amount",
                  subtitle: "Pay the total and you're all set.",
                  amount: "MWK ${widget.totalAmount.toStringAsFixed(0)}",
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Payment Summary
            const Text(
              "Payment summary",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSummaryRow("${widget.checkOut.difference(widget.checkIn).inDays} nights rental",
                      "MWK ${(widget.property.pricePerNight * widget.checkOut.difference(widget.checkIn).inDays).toStringAsFixed(0)}"),
                  const SizedBox(height: 8),
                  _buildSummaryRow("Service fee", "MWK ${(widget.totalAmount * 0.1).round().toStringAsFixed(0)}"),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    "Total (MWK)",
                    "MWK ${widget.totalAmount.toStringAsFixed(0)}",
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment Method
            const Text(
              "Pay with",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // PayChangu logo placeholder
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0b95da),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        "P",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PayChangu",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Airtel Money, TNM Mpamba, Bank Transfer",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              "You will be redirected to PayChangu to complete your purchase securely. Supports Airtel Money, TNM Mpamba, and Instant Bank Transfer.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),

      // Bottom Payment Button
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: ElevatedButton.icon(
          onPressed: _isProcessing ? null : _processPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0b95da),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          icon: const Icon(Icons.lock, size: 20),
          label: _isProcessing
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text(
            "Confirm and pay MWK ${amountToPay.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPaymentOption = value);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedPaymentOption == value
                ? const Color(0xFF0b95da)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Radio(
              value: value,
              groupValue: _selectedPaymentOption,
              onChanged: (newValue) {
                setState(() => _selectedPaymentOption = newValue!);
              },
              activeColor: const Color(0xFF0b95da),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black87 : Colors.grey[600],
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? Colors.black87 : Colors.grey[600],
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isProcessing = false);

    // Create a BookingModel instance
    final booking = BookingModel(
      id: const Uuid().v4(),
      propertyId: widget.property.id,
      guestId: 'guest_id', // Replace with actual guest ID
      checkIn: widget.checkIn,
      checkOut: widget.checkOut,
      numberOfGuests: widget.guests,
      totalPrice: widget.totalAmount.toDouble(),
      currency: 'MWK',
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
      property: widget.property, // Pass the property model
    );

    // Navigate to confirmation screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(
          booking: booking, // Pass the BookingModel instance
        ),
      ),
    );
  }
}