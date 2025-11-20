import 'package:flutter/material.dart';
import 'package:travel265/models/property_model.dart';
import 'package:travel265/features/booking/payment_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  final Property property;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;

  const BookingSummaryScreen({
    super.key,
    required this.property,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  bool _isGeneratingInvoice = false;

  int get nights => widget.checkOut.difference(widget.checkIn).inDays;
  int get basePrice => nights * widget.property.pricePerNight;
  int get serviceFee => (basePrice * 0.1).round(); // 10% service fee
  int get occupancyTax => (basePrice * 0.05).round(); // 5% tax
  int get totalAmount => basePrice + serviceFee + occupancyTax;
  int get depositAmount => (totalAmount * 0.5).round(); // 50% deposit

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8fbfc),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Booking Summary",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Property Summary
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(widget.property.images.first),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.property.type,
                          style: const TextStyle(
                            color: Color(0xFF49819c),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.property.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$nights nights · ${widget.guests} guest${widget.guests > 1 ? 's' : ''}",
                          style: const TextStyle(
                            color: Color(0xFF49819c),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Trip Details
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Your Trip",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFe2e8f0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTripDetail("Check-in", _formatDate(widget.checkIn)),
                  const SizedBox(height: 12),
                  _buildTripDetail("Check-out", _formatDate(widget.checkOut)),
                  const SizedBox(height: 12),
                  _buildTripDetail("Guests", "${widget.guests}"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Price Details
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Price Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFe2e8f0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildPriceDetail("$nights nights", "MWK ${basePrice.toStringAsFixed(0)}"),
                  const SizedBox(height: 8),
                  _buildPriceDetail("Service fee", "MWK ${serviceFee.toStringAsFixed(0)}"),
                  const SizedBox(height: 8),
                  _buildPriceDetail("Occupancy taxes", "MWK ${occupancyTax.toStringAsFixed(0)}"),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildPriceDetail(
                    "Total",
                    "MWK ${totalAmount.toStringAsFixed(0)}",
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Deposit Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFe7f5ff),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "You'll pay 50% now and the remaining 50% will be charged on check-in date.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0b95da),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Popular Alert
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFfff3e0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.group, color: Color(0xFFf57c00), size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "10+ people are viewing this property",
                      style: TextStyle(
                        color: Color(0xFFf57c00),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // Space for bottom buttons
          ],
        ),
      ),

      // Bottom Buttons
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isGeneratingInvoice ? null : _generateInvoice,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0b95da),
                  side: const BorderSide(color: Color(0xFF0b95da)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isGeneratingInvoice
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text(
                  "Generate Invoice",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        property: widget.property,
                        checkIn: widget.checkIn,
                        checkOut: widget.checkOut,
                        guests: widget.guests,
                        totalAmount: totalAmount,
                        depositAmount: depositAmount,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0b95da),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Continue to Pay",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF49819c),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDetail(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black87 : const Color(0xFF49819c),
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? Colors.black87 : const Color(0xFF49819c),
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  void _generateInvoice() async {
    setState(() => _isGeneratingInvoice = true);

    // Simulate invoice generation
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isGeneratingInvoice = false);

    // Show invoice dialog or screen
    _showInvoice();
  }

  void _showInvoice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Invoice Generated"),
        content: const Text("Your invoice has been generated successfully."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}