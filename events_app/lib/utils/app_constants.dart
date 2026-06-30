import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConstants {

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }

    if (Platform.isAndroid) {
      return 'http://192.168.0.109:8080/api';
    }

    return 'http://localhost:8080/api';
  }

  static const String collegeName = 'New horizon college of engineering';
  // ...keep the rest of your file unchanged

  static const String collegeShortName = 'NHCE';
  static const String collegeTagline = 'In pursuit of excellence';

  // Placeholder image URLs (replace with real assets later)
  static const String eventImagePlaceholder =
      'https://via.placeholder.com/400x200/1A3C6E/FFFFFF?text=Event';
  static const String profileImagePlaceholder =
      'https://via.placeholder.com/150/1A3C6E/FFFFFF?text=Student';

  // Department list - must match backend enum later
  static const List<String> departments = [
    'All',
    'Computer Science',
    'Electronics & ECE',
    'Mechanical',
    'MCA',
    'MBA',
    'AIML',
    'Mathematics',
    'Cultural',
  ];

  // Event categories shown on home dashboard
  static const List<String> eventCategories = [
    'All',
    'Technical',
    'Cultural',
    'Academic',
    'Sports',
    'Workshop',
    'Seminar',
  ];

  // Shared preferences keys
  static const String prefAuthToken = 'auth_token';
  static const String prefUserId = 'user_id';
  static const String prefUserName = 'user_name';
  static const String prefUserEmail = 'user_email';
  static const String prefUserDept = 'user_department';

  // Base URL for future Spring Boot API
  // static const String baseUrl = 'http://10.0.2.2:8080/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:8080/api';  // iOS simulator

  // Future API endpoints (reference only)
  // static const String loginEndpoint = '/login';
  // static const String registerEndpoint = '/register';
  // static const String eventsEndpoint = '/events';
}
