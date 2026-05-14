import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  String? currentRole;
  int? userId;
  String? displayName;
  String? email;
  String? phone; // Added phone number

  bool get isLoggedIn => currentRole != null;

  // Initialize session from SharedPreferences on app startup
  Future<void> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    currentRole = prefs.getString('role');
    userId = prefs.getInt('userId');
    displayName = prefs.getString('displayName');
    email = prefs.getString('email');
    phone = prefs.getString('phone');
  }

  // Save session both in memory and to disk
  Future<void> saveSession({
    required String role,
    int? userId,
    String? displayName,
    String? email,
    String? phone,
  }) async {
    this.currentRole = role.toUpperCase();
    this.userId = userId;
    this.displayName = displayName;
    this.email = email;
    this.phone = phone;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', this.currentRole!);
    if (userId != null) await prefs.setInt('userId', userId);
    if (displayName != null) await prefs.setString('displayName', displayName);
    if (email != null) await prefs.setString('email', email);
    if (phone != null) await prefs.setString('phone', phone);
  }

  void clear() {
    currentRole = null;
    userId = null;
    displayName = null;
    email = null;
    phone = null;
  }

  Future<void> logout() async {
    try {
      await ApiService.instance.logoutBackend();
    } catch (e) {
      print(
        "Could not reach backend for logout, proceeding with local logout.",
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    clear();
  }
}
