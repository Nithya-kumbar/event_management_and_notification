import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import '../utils/app_constants.dart';

class RegistrationService {
  Future<String> registerEvent({
    required int userId,
    required int eventId,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${AppConstants.baseUrl}/register-event?userId=$userId&eventId=$eventId',
      ),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Registration failed');
    }
  }
  Future<List<EventModel>> getUserRegistrations(int userId) async {
  final response = await http.get(
    Uri.parse(
      '${AppConstants.baseUrl}/user-registrations?userId=$userId',
    ),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to load registrations');
  }

  final List data = jsonDecode(response.body);

  return data.map((e) {
    return EventModel(
      id: e['eventId'],
      eventName: e['eventName'],
      description: e['description'],
      department: e['department'],
      eventDate: DateTime.parse(e['eventDate']),
      eventTime: e['eventTime'],
      location: e['location'],
      registrationLink: null,
      imageUrl: null,
      organizer: 'College Department',
      category: e['category'],
    );
  }).toList();
}
Future<int> getRegistrationCount(int userId) async {
  final response = await http.get(
    Uri.parse(
      '${AppConstants.baseUrl}/registration-count?userId=$userId',
    ),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to load registration count');
  }

  return int.parse(response.body);
}
}