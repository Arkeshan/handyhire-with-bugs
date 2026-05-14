import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final _client = http.Client();

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  // ─── AUTH ────────────────────────────────────────────────────────────────

  /// Fetches the user's full profile from the backend
  Future<Map<String, dynamic>> getProfile(String email) async {
    return _getJson('/api/auth/profile?email=$email');
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) =>
      _postJson(ApiConfig.login, {'email': email, 'password': password});

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? profession,
    String? experience,
    String? idProofName,
    String? certificationName,
  }) async {
    final Map<String, dynamic> body = {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'phone': phone ?? '0000000000',
      'profession': profession,
      'experience': experience != null ? int.tryParse(experience) : 0,
    };

    if (idProofName != null) {
      body['idProofName'] = idProofName;
    }
    if (certificationName != null) {
      body['certificationName'] = certificationName;
    }

    return _postJson('/api/auth/register', body);
  }

  // ─── ADMIN AUTH (RESTORED) ───────────────────────────────────────────────

  Future<Map<String, dynamic>> sendAdminOtp({
    required String email,
    required String password,
  }) =>
      _postJson(ApiConfig.adminSendOtp, {'email': email, 'password': password});

  Future<Map<String, dynamic>> verifyAdminOtp({
    required String email,
    required int otp,
  }) =>
      _postJson(ApiConfig.adminVerifyOtp, {'email': email, 'otp': otp});

  // ─── ADMIN ACTIONS ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getPendingUsers() =>
      _getJson('/api/admin/users/pending');

  Future<Map<String, dynamic>> approveUser(int userId) =>
      _putJson('/api/admin/users/$userId/approve', const {});

  Future<bool> rejectUser(int userId) async {
    try {
      final res = await _client
          .delete(_uri('/api/admin/users/$userId/reject'), headers: _headers())
          .timeout(ApiConfig.timeout);
      return res.statusCode == 200;
    } catch (e) {
      throw ApiException('Failed to reject user: $e');
    }
  }

  // ─── SESSION / LOGOUT (RESTORED) ─────────────────────────────────────────

  Future<bool> logoutBackend() async {
    try {
      await _postJson('/api/auth/logout', {});
      return true;
    } catch (e) {
      print("Backend logout failed or unreachable: $e");
      return false;
    }
  }

  // ─── JOBS & BOOKINGS (Standard Wrappers) ─────────────────────────────────

  Future<Map<String, dynamic>> createJob({
    required int customerId,
    required Map<String, dynamic> jobDto,
  }) =>
      _postJson(ApiConfig.createJob(customerId), jobDto);

  Future<Map<String, dynamic>> getOpenJobs({String? category}) {
    final path = category != null
        ? '${ApiConfig.openJobs}?category=$category'
        : ApiConfig.openJobs;
    return _getJson(path);
  }

  // ─── INTERNALS ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _getJson(String path) async {
    try {
      final res = await _client
          .get(_uri(path), headers: _headers())
          .timeout(ApiConfig.timeout);
      return _decode(res);
    } on TimeoutException {
      throw ApiException('Request timed out. Is the backend running?');
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
// Add this to lib/services/api_service.dart
  Future<Map<String, dynamic>> getJobHistory(int userId) =>
    _getJson('/api/jobs/history/$userId');
  Future<Map<String, dynamic>> _postJson(String path, Map<String, dynamic> body) async {
    try {
      final res = await _client
          .post(_uri(path), headers: _headers(), body: jsonEncode(body))
          .timeout(ApiConfig.timeout);
      return _decode(res);
    } on TimeoutException {
      throw ApiException('Request timed out. Is the backend running?');
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> _putJson(String path, Map<String, dynamic> body) async {
    try {
      final res = await _client
          .put(_uri(path), headers: _headers(), body: jsonEncode(body))
          .timeout(ApiConfig.timeout);
      return _decode(res);
    } on TimeoutException {
      throw ApiException('Request timed out. Is the backend running?');
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, dynamic> _decode(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('Server returned ${res.statusCode}: ${res.body}');
    }
    if (res.body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'data': decoded};
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}