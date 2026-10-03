import 'enums.dart';

class Responder {
  final String id;
  final String name;
  final String roleTitle; // e.g. "Campus Medic Â· Lead"
  final ResponderType type;
  final DutyStatus dutyStatus;
  final int currentWorkload;
  final int maxWorkload;
  final double latitude;
  final double longitude;
  final List<String> skills;
  final DateTime shiftStartedAt;
  final int responsesToday;
  final double avgResponseTimeMinutes;
  final String phone;
  final int avatarColorValue;

  const Responder({
    required this.id,
    required this.name,
    required this.roleTitle,
    required this.type,
    this.dutyStatus = DutyStatus.onDuty,
    this.currentWorkload = 0,
    this.maxWorkload = 3,
    required this.latitude,
    required this.longitude,
    required this.skills,
    required this.shiftStartedAt,
    this.responsesToday = 4,
    this.avgResponseTimeMinutes = 3.8,
    this.phone = '+1 (555) 987-6543',
    this.avatarColorValue = 0xFF13508F,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'R';
  }

  Responder copyWith({
    DutyStatus? dutyStatus,
    int? currentWorkload,
    double? latitude,
    double? longitude,
    int? responsesToday,
    double? avgResponseTimeMinutes,
  }) {
    return Responder(
      id: id,
      name: name,
      roleTitle: roleTitle,
      type: type,
      dutyStatus: dutyStatus ?? this.dutyStatus,
      currentWorkload: currentWorkload ?? this.currentWorkload,
      maxWorkload: maxWorkload,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      skills: skills,
      shiftStartedAt: shiftStartedAt,
      responsesToday: responsesToday ?? this.responsesToday,
      avgResponseTimeMinutes: avgResponseTimeMinutes ?? this.avgResponseTimeMinutes,
      phone: phone,
      avatarColorValue: avatarColorValue,
    );
  }
}
