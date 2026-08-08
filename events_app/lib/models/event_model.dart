// ============================================================
// event_model.dart
// Place this file at: lib/models/event_model.dart
// ============================================================

class EventModel {
  final int id;
  final String eventName;
  final String description;
  final String department;
  final DateTime eventDate;
  final String eventTime;
  final String location;
  final String? registrationLink;
  final String? imageUrl;
  final String? fileType; // "IMAGE" or "PDF"
  final String organizer;
  final String category;
  final DateTime? registrationDueDate;

  const EventModel({
    required this.id,
    required this.eventName,
    required this.description,
    required this.department,
    required this.eventDate,
    required this.eventTime,
    required this.location,
    this.registrationLink,
    this.imageUrl,
    this.fileType,
    required this.organizer,
    required this.category,
    this.registrationDueDate,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? 0,

      eventName: json['event_name']?.toString() ?? '',

      description: json['description']?.toString() ?? '',

      department: json['department']?.toString() ?? '',

      eventDate: DateTime.tryParse(
            json['event_date']?.toString() ?? '',
          ) ??
          DateTime.now(),

      eventTime: json['event_time']?.toString() ?? '',

      location: json['location']?.toString() ?? '',

      registrationLink: json['registration_link']?.toString(),

      imageUrl: json['image_url']?.toString(),

      fileType: json['fileType']?.toString(),

      organizer:
          json['organizer']?.toString() ?? 'College Department',

      category: json['category']?.toString() ?? 'General',

      registrationDueDate: json['registration_due_date'] != null
          ? DateTime.tryParse(json['registration_due_date'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_name': eventName,
      'description': description,
      'department': department,
      'event_date':
          '${eventDate.year.toString().padLeft(4, '0')}-'
          '${eventDate.month.toString().padLeft(2, '0')}-'
          '${eventDate.day.toString().padLeft(2, '0')}',
      'event_time': eventTime,
      'location': location,
      'registration_link': registrationLink,
      'image_url': imageUrl,
      'fileType': fileType,
      'organizer': organizer,
      'category': category,
      'registration_due_date': registrationDueDate != null
          ? '${registrationDueDate!.year.toString().padLeft(4, '0')}-'
            '${registrationDueDate!.month.toString().padLeft(2, '0')}-'
            '${registrationDueDate!.day.toString().padLeft(2, '0')}'
          : null,
    };
  }

  Map<String, dynamic> toArgs() => toJson();

  DateTime get effectiveDueDate => registrationDueDate ?? eventDate;

  bool get isRegistrationClosed {
    final today = DateTime.now();
    final dueEnd = DateTime(
      effectiveDueDate.year,
      effectiveDueDate.month,
      effectiveDueDate.day,
      23,
      59,
      59,
    );
    return today.isAfter(dueEnd);
  }
}