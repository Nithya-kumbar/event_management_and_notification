// ============================================================
// auth_service.dart - Authentication Service
// Place this file at: lib/services/auth_service.dart

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

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  int? get userId => _userId;
  // -------------------------------------------------------
  // LOGIN
  // TODO (Backend): Replace with POST /api/login
  // Send: { email, password }
  // Receive: { token, user: { id, name, email, department } }
  // Store token using shared_preferences
  // -------------------------------------------------------
Future<Map<String, dynamic>> login(
String email,
String password,
) async {

_isLoading = true;
notifyListeners();

try {

final response = await http.post(

  Uri.parse('${AppConstants.baseUrl}/login'),

  headers: {
    'Content-Type': 'application/json',
  },

  body: jsonEncode({
    'email': email,
    'password': password,
  }),
);

final data = jsonDecode(response.body);

if (response.statusCode == 200 &&
    data['success'] == true) {

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

  return {
    'success': true,
    'message': 'Login successful',
  };

} else {

  _isLoading = false;

  notifyListeners();

  return {
    'success': false,
    'message': data['message'] ??
        'Login failed',
  };
}


} catch (e) {


_isLoading = false;

notifyListeners();

return {
  'success': false,
  'message': 'Server connection failed',
};

}
}


  // -------------------------------------------------------
  // REGISTER
  // TODO (Backend): Replace with POST /api/register
  // Send: { name, email, password, department }
  // Receive: { message }
  // -------------------------------------------------------
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
      headers: {
        'Content-Type': 'application/json',
      },
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

    return {
      'success': false,
      'message': 'Server connection failed',
    };
  }
}

  // -------------------------------------------------------
  // LOGOUT - Clear session from shared_preferences
  // -------------------------------------------------------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  // -------------------------------------------------------
  // CHECK SESSION - Auto-login if token exists
  // TODO (Backend): Validate token with GET /api/me
  // -------------------------------------------------------
  Future<bool> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.prefAuthToken);
    final name = prefs.getString(AppConstants.prefUserName);
    final email = prefs.getString(AppConstants.prefUserEmail);
    final dept = prefs.getString(AppConstants.prefUserDept);
    final userId = prefs.getInt(AppConstants.prefUserId);

  if (token != null &&
    userId != null &&
    name != null &&
    email != null &&
    dept != null)  {
      _currentUser = UserModel(name: name, email: email, department: dept);
      _isLoggedIn = true;
      _userId = userId;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Save user session data locally
  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    // In future: save actual JWT token from backend response
    await prefs.setString(AppConstants.prefAuthToken, 'dummy_token_123');
    await prefs.setInt(AppConstants.prefUserId, _userId!);
    await prefs.setString(AppConstants.prefUserName, user.name);
    await prefs.setString(AppConstants.prefUserEmail, user.email);
    await prefs.setString(AppConstants.prefUserDept, user.department);
  }
}
