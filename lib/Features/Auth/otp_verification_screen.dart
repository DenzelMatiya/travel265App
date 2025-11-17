import 'package:flutter/material.dart';
import 'dart:async'; // Add this for Timer
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this for FirebaseFirestore and FieldValue
import 'package:travel265/features/services/phone_auth_service.dart';
import 'package:travel265/features/services/auth_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final bool isHost;
  final bool isLinking;
  final String? email;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.isHost = false,
    this.isLinking = false,
    this.email,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final PhoneAuthService _phoneAuthService = PhoneAuthService();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Add Firestore instance

  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 60;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      _showError("Please enter a valid 6-digit OTP");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isLinking) {
        // Link phone number to existing account
        await _phoneAuthService.linkPhoneNumberToUser(
          verificationId: widget.verificationId,
          smsCode: _otpController.text,
        );

        // Update phone number in Firestore
        await _phoneAuthService.updateUserPhoneNumber(
            widget.phoneNumber,
            isHost: widget.isHost
        );

        _showSuccess("Phone number verified successfully!");
        Navigator.pop(context, true); // Return success
      } else {
        // Sign in with phone number
        final userCredential = await _phoneAuthService.signInWithOTP(
          verificationId: widget.verificationId,
          smsCode: _otpController.text,
        );

        // Handle new user registration or existing user sign-in
        await _handleUserSignIn(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Verification failed";
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = "Invalid OTP code. Please check and try again.";
          break;
        case 'session-expired':
          errorMessage = "OTP session expired. Please request a new code.";
          break;
        case 'invalid-verification-id':
          errorMessage = "Invalid verification. Please start over.";
          break;
        default:
          errorMessage = e.message ?? "Verification failed";
      }
      _showError(errorMessage);
    } catch (e) {
      _showError("An error occurred: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUserSignIn(User user) async {
    // Check if user exists in Firestore
    final isHost = await _authService.isUserHost(user.uid);
    final isGuest = await _authService.isUserGuest(user.uid);

    if (!isHost && !isGuest) {
      // New user - create profile
      await _createNewUserProfile(user);
    }

    _showSuccess("Phone number verified successfully!");

    // Navigate based on user role - handled by AuthWrapper
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Future<void> _createNewUserProfile(User user) async {
    final collection = widget.isHost ? 'hosts' : 'users';
    await _firestore.collection(collection).doc(user.uid).set({
      'uid': user.uid,
      'name': 'User', // Default name
      'email': widget.email,
      'phone': widget.phoneNumber,
      'phoneVerified': true,
      'phoneVerifiedAt': FieldValue.serverTimestamp(),
      'role': widget.isHost ? 'host' : 'guest',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'profileComplete': false,
    });
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isResending = true;
      _resendTimer = 60;
    });

    try {
      await _phoneAuthService.resendOTP(
        phoneNumber: widget.phoneNumber,
        onCodeSent: (verificationId) {
          _showSuccess("OTP resent successfully!");
        },
        onVerificationFailed: (error) {
          _handleVerificationError(error);
        },
      );
    } catch (e) {
      _showError("Failed to resend OTP: ${e.toString()}");
    } finally {
      setState(() => _isResending = false);
      _startResendTimer();
    }
  }

  void _handleVerificationError(FirebaseAuthException error) {
    String errorMessage = "Failed to resend OTP";
    switch (error.code) {
      case 'too-many-requests':
        errorMessage = "Too many resend attempts. Please try again later.";
        break;
      case 'quota-exceeded':
        errorMessage = "SMS quota exceeded. Please contact support.";
        break;
      default:
        errorMessage = error.message ?? "Failed to resend OTP";
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter Verification Code",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We've sent a 6-digit code to your phone",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Phone Number Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0b95da).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.phone_iphone, size: 40, color: Color(0xFF0b95da)),
                    const SizedBox(height: 8),
                    Text(
                      widget.phoneNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Enter the code sent to this number",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // OTP Input Field
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 60,
                  fieldWidth: 50,
                  activeFillColor: Colors.white,
                  activeColor: const Color(0xFF0b95da),
                  selectedColor: const Color(0xFF0b95da),
                  inactiveColor: Colors.grey[300],
                  selectedFillColor: Colors.grey[50],
                  inactiveFillColor: Colors.grey[50],
                ),
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
                keyboardType: TextInputType.number,
                onCompleted: (value) {
                  _verifyOTP();
                },
                onChanged: (value) {},
                beforeTextPaste: (text) {
                  return true;
                },
              ),
              const SizedBox(height: 24),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
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
                    "Verify OTP",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (_resendTimer > 0)
                    Text(
                      "Resend in $_resendTimer",
                      style: const TextStyle(
                        color: Color(0xFF0b95da),
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _isResending ? null : _resendOTP,
                      child: _isResending
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0b95da),
                        ),
                      )
                          : const Text(
                        "Resend OTP",
                        style: TextStyle(
                          color: Color(0xFF0b95da),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              // Manual Entry Option
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _showManualEntryDialog,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      "Having trouble receiving the code?",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManualEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Trouble receiving OTP?"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("If you're not receiving the OTP, please:"),
            SizedBox(height: 8),
            Text("• Check your phone signal"),
            Text("• Ensure your phone number is correct"),
            Text("• Wait 2 minutes and try again"),
            Text("• Contact support if the issue persists"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
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