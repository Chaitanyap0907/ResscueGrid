import 'enums.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? studentId;
  final String? department;
  final String? unitNumber;
  final String? roleTitle;
  final List<String> skills;
  final String phone;
  final String? emergencyContact;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.password = 'password123',
    required this.role,
    this.studentId,
    this.department,
    this.unitNumber,
    this.roleTitle,
    this.skills = const [],
    this.phone = '+1 (555) 234-5678',
    this.emergencyContact,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    String? studentId,
    String? department,
    String? unitNumber,
    String? roleTitle,
    List<String>? skills,
    String? phone,
    String? emergencyContact,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      unitNumber: unitNumber ?? this.unitNumber,
      roleTitle: roleTitle ?? this.roleTitle,
      skills: skills ?? this.skills,
      phone: phone ?? this.phone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }
}

