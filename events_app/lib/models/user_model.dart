// ============================================================
// user_model.dart - User Data Model
// Place this file at: lib/models/user_model.dart
//
// Structured to match future MySQL 'users' table:
// id, name, email, password, department
// ============================================================

class UserModel {
  final int? id;
  final String name;
  final String email;
  final String department;
  // Note: password is never stored locally; only token from JWT in future

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.department,
  });

  // Factory constructor to build UserModel from JSON (future API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String,
      department: json['department'] as String,
    );
  }

  // Convert UserModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
    };
  }

  // Dummy/static user for UI testing
  static UserModel dummy() {
    return const UserModel(
      id: 1,
      name: 'Alex Johnson',
      email: 'alex.johnson@git.edu',
      department: 'Computer Science',
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, email: $email, department: $department)';
}
