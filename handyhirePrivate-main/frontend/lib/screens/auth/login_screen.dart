import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../admin/admin_login.dart';
import '../customer/home_screen.dart' as customer;
import '../provider/home_screen.dart' as provider;
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showLogin = false;
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Set to false to use offline demo without needing the backend server
  static const bool useBackend = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showLogin = true);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      String resolvedRole;
      String message;
      int? userId;

      if (useBackend) {
        final resp = await ApiService.instance.login(email: email, password: password);
        final status = resp['status']?.toString() ?? 'FAILED';

        if (status == 'INVALID_CREDENTIALS') {
          // UPDATED: Added the helper text for rejected providers!
          _showError('Invalid email or password.\n\nNote: If you applied as a Provider and your application was rejected, your account data has been cleared. Please register again.');
          return;
        }
        if (status == 'PENDING_VERIFICATION') {
          _showError('Your account is waiting for admin approval.\nPlease check back later.');          
          return;
        }
        if (status != 'SUCCESS' && status != 'OTP_REQUIRED') {
          _showError(resp['message']?.toString() ?? 'Login failed.');
          return;
        }

        resolvedRole = (resp['role'] as String?)?.toUpperCase() ?? 'CUSTOMER';
        message = resp['message']?.toString() ?? 'Logged in';
        final rawId = resp['userId'];
        userId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');

        if (status == 'OTP_REQUIRED' || resolvedRole == 'ADMIN') {
          await ApiService.instance.sendAdminOtp(email: email, password: password);
          
          SessionService.instance.saveSession(role: 'ADMIN', userId: userId, email: email);
          
          if (!mounted) return;
          setState(() => _isLoading = false);
          
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOtpScreen()));
          return;
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
        if (email.toLowerCase().contains('provider')) {
          resolvedRole = 'PROVIDER';
        } else if (email.toLowerCase().contains('admin')) {
          resolvedRole = 'ADMIN';
        } else {
          resolvedRole = 'CUSTOMER';
        }
        message = 'Demo login ($resolvedRole)';
        userId = 1;
      }

      SessionService.instance.saveSession(
          role: resolvedRole, userId: userId, email: email,
          displayName: email.split('@').first);

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));

      Widget landing;
      switch (resolvedRole) {
        case 'PROVIDER':  landing = const provider.HomeScreen(); break;
        case 'ADMIN':     landing = const AdminOtpScreen(); break;
        default:          landing = const customer.HomeScreen();
      }

      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => landing));

    } on ApiException catch (e) {
      _showError(
        'Cannot reach the backend server!\n\n'
        'Make sure it is running:\n'
        '  cd backend\n'
        '  mvn spring-boot:run\n\n'
        '(or run the start script)\n\n'
        'Error: ${e.message}',
      );
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E355B),
        title: const Row(children: [
          Icon(Icons.error_outline, color: Colors.redAccent),
          SizedBox(width: 8),
          Text('Oops!', style: TextStyle(color: Colors.white)),
        ]),
        content: Text(msg, style: const TextStyle(color: Colors.white70, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF8EBBFF))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1E3F),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: _showLogin
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeInOutCubic,
                height: _showLogin ? 28 : MediaQuery.of(context).size.height * 0.2,
              ),
              AnimatedScale(
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeInOutCubic,
                scale: _showLogin ? 1.0 : 1.35,
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Handy', style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: const Color(0xFFB18E44))),
                      const SizedBox(width: 4),
                      Text('Hire', style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: const Color(0xFFC0C0C2))),
                    ]),
                    const SizedBox(height: 10),
                    Container(
                      width: 85, height: 85,
                      decoration: BoxDecoration(color: const Color(0xFF1E355B), borderRadius: BorderRadius.circular(18)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/logo.jpg', 
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.handyman,
                            color: Color(0xFFB18E44),
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSlide(
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                offset: _showLogin ? Offset.zero : const Offset(0, 0.2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 900),
                  opacity: _showLogin ? 1.0 : 0.0,
                  child: IgnorePointer(
                    ignoring: !_showLogin,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Color(0xFF0B1E3F)),
                              decoration: InputDecoration(
                                filled: true, fillColor: const Color(0xFFC0C0C2),
                                hintText: 'Email', hintStyle: TextStyle(color: Colors.grey[600]),
                                prefixIcon: const Icon(Icons.email, color: Color(0xFF0B1E3F)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Enter your email' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Color(0xFF0B1E3F)),
                              decoration: InputDecoration(
                                filled: true, fillColor: const Color(0xFFC0C0C2),
                                hintText: 'Password', hintStyle: TextStyle(color: Colors.grey[600]),
                                prefixIcon: const Icon(Icons.lock, color: Color(0xFF0B1E3F)),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF0B1E3F)),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
                            ),
                            const SizedBox(height: 26),
                            _isLoading
                                ? const CircularProgressIndicator(color: Color(0xFFB18E44))
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFB18E44),
                                      minimumSize: const Size(double.infinity, 55),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                    ),
                                    onPressed: _handleLogin,
                                    child: const Text('Log In', style: TextStyle(fontSize: 18, color: Color(0xFF0B1E3F), fontWeight: FontWeight.bold)),
                                  ),
                            const SizedBox(height: 18),
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Text("Don't have an account? ", style: TextStyle(color: Colors.white70)),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                                child: const Text('Sign Up', style: TextStyle(color: Color(0xFF8EBBFF), fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: Color(0xFF8EBBFF))),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}