import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'admin_dashboard.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

class AdminOtpScreen extends StatefulWidget {
  const AdminOtpScreen({super.key});

  @override
  State<AdminOtpScreen> createState() => _AdminOtpScreenState();
}

class _AdminOtpScreenState extends State<AdminOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _animateIn = false;

  Timer? _timer;
  int _remainingSeconds = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _animateIn = true);
    });
  }

  void _startTimer() {
    setState(() => _remainingSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

void _verifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Get the admin's email that we saved in the session during login
      final email = SessionService.instance.email;
      if (email == null) throw Exception("Session email not found");

      // 2. Parse the OTP to an integer
      final otpInt = int.tryParse(_otpController.text);
      if (otpInt == null) throw Exception("Invalid OTP format");

      // 3. Call the backend to verify the actual OTP!
      await ApiService.instance.verifyAdminOtp(
        email: email,
        otp: otpInt,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // 4. Success! Navigate to the Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // If the backend says the OTP is wrong/expired, it throws an exception here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification Failed. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1E3F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              offset: _animateIn ? Offset.zero : const Offset(0, 0.15),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _animateIn ? 1.0 : 0.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Authentication',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB18E44),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'We have sent a 6-digit security code to admin@email.com. Please enter it below.\n\n',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      height: 65,
                      child: Stack(
                        children: [
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            maxLength: 6,
                            autofocus: true,
                            cursorColor: Colors.transparent,
                            style: const TextStyle(color: Colors.transparent),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              counterText: "",
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                          IgnorePointer(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                String char = _otpController.text.length > index
                                    ? _otpController.text[index]
                                    : '';
                                bool isCurrentBox = _otpController.text.length == index;
                                return Container(
                                  width: 48,
                                  height: 60,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC0C0C2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isCurrentBox
                                          ? const Color(0xFFB18E44)
                                          : Colors.transparent,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: Text(
                                    char.isEmpty ? '_' : char,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0B1E3F),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    _isLoading
                        ? const CircularProgressIndicator(color: Color(0xFFB18E44))
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8EBBFF),
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            onPressed: _verifyOtp,
                            child: const Text('Verify Account',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF0B1E3F),
                                    fontWeight: FontWeight.bold)),
                          ),
                    const SizedBox(height: 30),
                    TextButton(
                      onPressed: _remainingSeconds == 0
                          ? () {
                              _startTimer();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('A new OTP has been sent!')));
                            }
                          : null,
                      child: Text(
                        _remainingSeconds == 0
                            ? 'Didn\'t receive a code? Resend OTP'
                            : 'Resend code in 00:${_remainingSeconds.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: _remainingSeconds == 0
                              ? const Color(0xFF8EBBFF)
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                          decoration: _remainingSeconds == 0
                              ? TextDecoration.underline
                              : TextDecoration.none,
                          decorationColor: const Color(0xFF8EBBFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
