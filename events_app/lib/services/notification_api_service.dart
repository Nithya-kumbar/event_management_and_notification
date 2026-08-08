// lib/services/notification_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_constants.dart';

class NotificationApiService {

  Future<List<Map<String, dynamic>>> getNotifications(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/notifications?userId=$userId'),
      );
      if (response.statusCode != 200) return [];
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<int> getUnreadCount(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/notifications/unread-count?userId=$userId'),
      );
      if (response.statusCode != 200) return 0;
      final data = jsonDecode(response.body);
      return (data['count'] as num).toInt();
    } catch (_) {
      return 0;
    }
  }

  Future<void> markRead(int notificationId) async {
    try {
      await http.post(
        Uri.parse('${AppConstants.baseUrl}/notifications/$notificationId/read'),
      );
    } catch (_) {}
  }

  Future<void> markAllRead(int userId) async {
    try {
      await http.post(
        Uri.parse('${AppConstants.baseUrl}/notifications/mark-all-read?userId=$userId'),
      );
    } catch (_) {}
  }
  Future<List<Map<String, dynamic>>> getUnreadNotifications(int userId) async {
  try {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/notifications/unread?userId=$userId'),
    );
    if (response.statusCode != 200) return [];
    final List data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  } catch (_) {
    return [];
  }
}
}
