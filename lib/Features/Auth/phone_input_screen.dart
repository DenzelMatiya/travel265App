import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel265/features/services/phone_auth_service.dart';
import 'package:travel265/features/auth/otp_verification_screen.dart'; // Uncommented

class PhoneInputScreen extends StatefulWidget {
  final bool isHost;
  final bool isLinking;
  final String? email;

  const PhoneInputScreen({
    super.key,
    this.isHost = false,
    this.isLinking = false,
    this.email,
  });

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final PhoneAuthService _phoneAuthService = PhoneAuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _selectedCountryCode = '+265'; // Malawi

  final Map<String, String> _countryCodes = {
    'Malawi': '+265',
    'South Africa': '+27',
    'Zambia': '+260',
    'Tanzania': '+255',
    'Mozambique': '+258',
    'Zimbabwe': '+263',
  };

  Future<void> _sendOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final phoneNumber = _phoneController.text.trim();
      final fullPhoneNumber = _selectedCountryCode + phoneNumber;

      try {
        // Check if phone number is already registered (only for new registrations)
        if (!widget.isLinking) {
          final isRegistered = await _phoneAuthService.isPhoneNumberRegistered(fullPhoneNumber);
          if (isRegistered) {
            setState(() => _isLoading = false);
            _showError('This phone number is already registered. Please use a different number or sign in.');
            return;
          }
        }

        await _phoneAuthService.verifyPhoneNumber(
          phoneNumber: fullPhoneNumber,
          onCodeSent: (String verificationId) {
            setState(() => _isLoading = false);
            _navigateToOTPScreen(fullPhoneNumber, verificationId);
          },
          onVerificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-verification on some devices
            setState(() => _isLoading = false);
            await _handleAutoVerification(credential, fullPhoneNumber);
          },
          onVerificationFailed: (FirebaseAuthException error) {
            setState(() => _isLoading = false);
            _handleVerificationError(error);
          },
          onCodeAutoRetrievalTimeout: (String verificationId) {
            // Handle timeout if needed
            print('Auto-retrieval timeout');
          },
        );
      } catch (e) {
        setState(() => _isLoading = false);
        _showError('Failed to send OTP: ${e.toString()}');
      }
    }
  }

  void _navigateToOTPScreen(String phoneNumber, String verificationId) {
    // Uncommented navigation code
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPVerificationScreen(
          phoneNumber: phoneNumber,
          verificationId: verificationId,
          isHost: widget.isHost,
          isLinking: widget.isLinking,
          email: widget.email,
        ),
      ),
    );
  }

  Future<void> _handleAutoVerification(PhoneAuthCredential credential, String phoneNumber) async {
    try {
      if (widget.isLinking) {
        await _phoneAuthService.linkPhoneNumberToUser(
          verificationId: credential.verificationId!,
          smsCode: credential.smsCode!,
        );
        await _phoneAuthService.updateUserPhoneNumber(phoneNumber, isHost: widget.isHost);
      } else {
        await _phoneAuthService.signInWithOTP(
          verificationId: credential.verificationId!,
          smsCode: credential.smsCode!,
        );
      }

      _showSuccess('Phone number verified successfully!');
      Navigator.pop(context, true); // Return success
    } catch (e) {
      _showError('Auto-verification failed: ${e.toString()}');
    }
  }

  void _handleVerificationError(FirebaseAuthException error) {
    String errorMessage = 'Verification failed';

    switch (error.code) {
      case 'invalid-phone-number':
        errorMessage = 'Invalid phone number format';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many attempts. Please try again later';
        break;
      case 'quota-exceeded':
        errorMessage = 'SMS quota exceeded. Please contact support';
        break;
      case 'operation-not-allowed':
        errorMessage = 'Phone sign-in is not enabled. Contact support';
        break;
      default:
        errorMessage = error.message ?? 'Verification failed';
    }

    _showError(errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Phone Verification",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "We'll send you a 6-digit verification code via SMS",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Country Code and Phone Input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      // Country Code Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCountryCode,
                        decoration: const InputDecoration(
                          labelText: "Country",
                          border: InputBorder.none,
                        ),
                        items: _countryCodes.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.value,
                            child: Text("${entry.key} ${entry.value}"),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCountryCode = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone Number Input
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          hintText: "123 456 789",
                          border: InputBorder.none,
                          prefixText: _selectedCountryCode == '+265' ? "  " : null,
                          prefix: _selectedCountryCode != '+265'
                              ? Text("$_selectedCountryCode ")
                              : null,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }

                          // Basic phone number validation
                          final cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');
                          if (cleanNumber.length < 7 || cleanNumber.length > 15) {
                            return 'Please enter a valid phone number';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0b95da).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF0b95da)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Standard SMS rates may apply. You'll receive a 6-digit verification code within 2 minutes.",
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0b95da),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      "Send Verification Code",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Test Mode Info (for development)
                if (_isLoading) ...[
                  const SizedBox(height: 20),
                  const LinearProgressIndicator(
                    color: Color(0xFF0b95da),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Sending SMS...",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],

                const SizedBox(height: 16),
                _buildTestModeInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestModeInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.developer_mode, size: 16, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                "Development Mode",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            "Use test phone numbers from Firebase Console. Real SMS will be sent in production.",
            style: TextStyle(
              color: Colors.orange,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}