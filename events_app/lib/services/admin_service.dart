// lib/services/admin_service.dart
// Save at: lib/services/admin_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';
import 'dart:io';

class AdminService extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _adminInfo;
  bool _isLoading = false;

  String? get token => _token;
  Map<String, dynamic>? get adminInfo => _adminInfo;
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;

  static const String _prefToken    = 'admin_token';
  static const String _prefEmail    = 'admin_email';
  static const String _prefName     = 'admin_name';

  // ── Auth ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _token = data['token'];
        _adminInfo = {
          'id': data['id'],
          'name': data['name'],
          'email': data['email'],
          'role': data['role'],
        };
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefToken, _token!);
        await prefs.setString(_prefEmail, data['email']);
        await prefs.setString(_prefName,  data['name']);
        _isLoading = false;
        notifyListeners();
        return {'success': true};
      }
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Server connection failed'};
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await http.post(
          Uri.parse('${AppConstants.baseUrl}/admin/logout'),
          headers: {'X-Admin-Token': _token!},
        );
      } catch (_) {}
    }
    _token = null;
    _adminInfo = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefToken);
    await prefs.remove(_prefEmail);
    await prefs.remove(_prefName);
    notifyListeners();
  }

  Future<bool> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_prefToken);
    final email = prefs.getString(_prefEmail);
    final name  = prefs.getString(_prefName);
    if (token != null) {
      _token     = token;
      _adminInfo = {'email': email, 'name': name};
      notifyListeners();
      return true;
    }
    return false;
  }

  Map<String, String> get _headers => {
    'Content-Type':  'application/json',
    'X-Admin-Token': _token ?? '',
  };

  // Extracts a readable message from a non-200 response body, if possible.
  String _errorMessageFrom(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}
    if (response.statusCode == 401 || response.statusCode == 403) {
      return 'Unauthorized: invalid or missing admin token. Please log in again.';
    }
    return 'Request failed (${response.statusCode})';
  }

  // ── Registrations ────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getRegistrations({
    int? eventId,
    int? userId,
  }) async {
    String url = '${AppConstants.baseUrl}/admin/registrations';
    final params = <String>[];
    if (eventId != null) params.add('eventId=$eventId');
    if (userId  != null) params.add('userId=$userId');
    if (params.isNotEmpty) url += '?${params.join('&')}';

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception(_errorMessageFrom(response));
  }

  Future<Map<String, dynamic>> addRegistration(int userId, int eventId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/admin/registrations'),
        headers: _headers,
        body: jsonEncode({'userId': userId, 'eventId': eventId}),
      );
      if (response.statusCode != 200) {
        return {'success': false, 'message': _errorMessageFrom(response)};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'message': 'Server error'};
    }
  }

  Future<Map<String, dynamic>> deleteRegistration(int registrationId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/admin/registrations/$registrationId'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        return {'success': false, 'message': _errorMessageFrom(response)};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'message': 'Server error'};
    }
  }

  // ── Events ───────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getEvents() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/events'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception(_errorMessageFrom(response));
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/admin/events'),
        headers: _headers,
        body: jsonEncode(eventData),
      );
      if (response.statusCode != 200) {
        return {'success': false, 'message': _errorMessageFrom(response)};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'message': 'Server error'};
    }
  }

  Future<Map<String, dynamic>> deleteEvent(int eventId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/admin/events/$eventId'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        return {'success': false, 'message': _errorMessageFrom(response)};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'message': 'Server error'};
    }
  }

  Future<Map<String, dynamic>> updateEvent(
      int eventId, Map<String, dynamic> fields) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/admin/events/$eventId'),
        headers: _headers,
        body: jsonEncode(fields),
      );
      if (response.statusCode != 200) {
        return {'success': false, 'message': _errorMessageFrom(response)};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'message': 'Server error'};
    }
  }

  // ── Users (for add-registration lookup) ──────────────────────────
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/admin/users'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception(_errorMessageFrom(response));
  }

  Future<Map<String, dynamic>> uploadEventFile(File file) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/admin/events/upload');
      final request = http.MultipartRequest('POST', uri);
      request.headers['X-Admin-Token'] = _token ?? '';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200) {
        return {'success': false, 'message': _errorMessageFrom(response)};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'message': 'Upload failed'};
    }
  }
}