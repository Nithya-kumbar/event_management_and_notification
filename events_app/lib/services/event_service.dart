// ============================================================
// event_service.dart - Event Data Service
// Place this file at: lib/services/event_service.dart
//
// Currently returns static dummy data.
// Replace method bodies with HTTP calls when backend is ready.
// ============================================================
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_constants.dart';
import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import 'notification_service.dart';
class EventService extends ChangeNotifier {
  //static const String baseUrl = 'http://localhost:8080/api';
  List<EventModel> _allEvents = [];
  List<EventModel> _filteredEvents = [];
  String _selectedDepartment = 'All';
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<EventModel> get allEvents => _allEvents;
  List<EventModel> get filteredEvents => _filteredEvents;
  String get selectedDepartment => _selectedDepartment;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // -------------------------------------------------------
  // FETCH ALL EVENTS
  // TODO (Backend): Replace with GET /api/events
  // -------------------------------------------------------
Future<void> fetchEvents() async {
  try {
    _isLoading = true;
    notifyListeners();
    print("API URL = ${AppConstants.baseUrl}/events");
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/events'),
    );
    

   print("STATUS: ${response.statusCode}");
   print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      //_allEvents =
          //data.map((e) => EventModel.fromJson(e)).toList();
          print("TOTAL RECORDS = ${data.length}");
          _allEvents = [];

for (var e in data) {
  try {
    _allEvents.add(EventModel.fromJson(e));
  } catch (err) {
    print("ERROR PARSING EVENT:");
    print(err);
    print(e);
  }
}

print("EVENTS LOADED = ${_allEvents.length}");


_filteredEvents = List.from(_allEvents);

_error = null;


// ===============================
// SCHEDULE EVENT NOTIFICATIONS
// ===============================

await NotificationService()
    .cancelAllReminders();


for (var event in _allEvents) {

  await NotificationService()
      .scheduleEventReminder(
        eventId: event.id,
        title: event.eventName,
        eventDate: event.eventDate,
        eventTime: event.eventTime,
      );

}


print("EVENT REMINDERS SCHEDULED");
    } else {
      _error = 'Failed to load events';
    }
  } catch (e) {
    _error = e.toString();
  }

  _isLoading = false;
  notifyListeners();
}
  


  // -------------------------------------------------------
  // FILTER BY DEPARTMENT
  // TODO (Backend): Replace with GET /api/events/department/{dept}
  // -------------------------------------------------------
  void filterByDepartment(String department) {
    _selectedDepartment = department;
    _applyFilters();
    notifyListeners();
  }

  // Filter by event category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // -------------------------------------------------------
  // GET EVENTS BY DATE
  // TODO (Backend): Replace with GET /api/events/date/{date}
  // -------------------------------------------------------
  List<EventModel> getEventsByDate(DateTime date) {
    return _allEvents.where((e) {
      return e.eventDate.year == date.year &&
          e.eventDate.month == date.month &&
          e.eventDate.day == date.day;
    }).toList();
  }

  // Apply all active filters locally
  void _applyFilters() {
    _filteredEvents = _allEvents.where((event) {
      final deptMatch =
          _selectedDepartment == 'All' || event.department == _selectedDepartment;
      final catMatch =
          _selectedCategory == 'All' || event.category == _selectedCategory;
      return deptMatch && catMatch;
    }).toList();
  }

  // Search events by keyword
  void searchEvents(String query) {
    if (query.isEmpty) {
      _filteredEvents = List.from(_allEvents);
    } else {
      _filteredEvents = _allEvents.where((event) {
        return event.eventName.toLowerCase().contains(query.toLowerCase()) ||
            event.department.toLowerCase().contains(query.toLowerCase()) ||
            event.category.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  // Get upcoming events (events in the future, sorted by date)
  List<EventModel> get upcomingEvents {
  final now = DateTime.now();

  final upcoming = _allEvents.where((e) {

    final timeParts = e.eventTime.split(" ");

    int hourMinute = 0;

    if (timeParts.length >= 1) {

      final hm = timeParts[0].split(":");

      int hour = int.parse(hm[0]);
      int minute = int.parse(hm[1]);

      if (timeParts.length > 1) {
        final ampm = timeParts[1];

        if (ampm == "PM" && hour != 12) {
          hour += 12;
        }

        if (ampm == "AM" && hour == 12) {
          hour = 0;
        }
      }

      hourMinute = hour * 60 + minute;
    }


    final eventDateTime = DateTime(
      e.eventDate.year,
      e.eventDate.month,
      e.eventDate.day,
      hourMinute ~/ 60,
      hourMinute % 60,
    );


    return eventDateTime.isAfter(now);

  }).toList();


  upcoming.sort((a, b) {

    final aTime = DateTime(
      a.eventDate.year,
      a.eventDate.month,
      a.eventDate.day,
    );

    final bTime = DateTime(
      b.eventDate.year,
      b.eventDate.month,
      b.eventDate.day,
    );

    return aTime.compareTo(bTime);
  });


  return upcoming;
}
  

  // Reset all filters
  void resetFilters() {
    _selectedDepartment = 'LAll';
    _selectedCategory = 'All';
    _filteredEvents = List.from(_allEvents);
    notifyListeners();
  }
}
