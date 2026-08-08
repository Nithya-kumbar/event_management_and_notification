
// Save at: lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  int? _userId;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  int? get userId => _userId;

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _currentUser = UserModel(
          name: data['name'],
          email: data['email'],
          department: data['department'],
        );
        _userId = data['id'];
        _isLoggedIn = true;
        await _saveSession(_currentUser!);
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'message': 'Login successful'};
      } else {
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Server connection failed'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String usn,
    required String email,
    required String password,
    required String confirmPassword,
    required String department,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'usn': usn,
          'email': email,
          'password': password,
          'department': department,
        }),
      );
      final data = jsonDecode(response.body);
      _isLoading = false;
      notifyListeners();
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Server connection failed'};
    }
  }

  /// Called after a successful profile edit so the UI updates immediately
  /// without requiring a logout/login cycle.
  void updateLocalProfile({
    required String name,
    required String email,
    required String department,
  }) {
    _currentUser = UserModel(name: name, email: email, department: department);
    notifyListeners();
    // Persist updated values locally
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(AppConstants.prefUserName, name);
      prefs.setString(AppConstants.prefUserEmail, email);
      prefs.setString(AppConstants.prefUserDept, department);
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<bool> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token  = prefs.getString(AppConstants.prefAuthToken);
    final name   = prefs.getString(AppConstants.prefUserName);
    final email  = prefs.getString(AppConstants.prefUserEmail);
    final dept   = prefs.getString(AppConstants.prefUserDept);
    final userId = prefs.getInt(AppConstants.prefUserId);
    if (token != null && userId != null && name != null &&
        email != null && dept != null) {
      _currentUser = UserModel(name: name, email: email, department: dept);
      _isLoggedIn = true;
      _userId = userId;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefAuthToken, 'dummy_token_123');
    await prefs.setInt(AppConstants.prefUserId, _userId!);
    await prefs.setString(AppConstants.prefUserName, user.name);
    await prefs.setString(AppConstants.prefUserEmail, user.email);
    await prefs.setString(AppConstants.prefUserDept, user.department);
  }
}
