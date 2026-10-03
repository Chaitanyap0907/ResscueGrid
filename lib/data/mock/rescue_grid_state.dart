import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/user.dart';
import '../models/responder.dart';
import '../models/incident.dart';
import '../models/timeline_event.dart';
import '../models/notification_item.dart';
import 'mock_data.dart';

class RescueGridState extends ChangeNotifier {
  late User _currentUser;
  late List<Incident> _incidents;
  late List<Responder> _responders;
  late List<NotificationItem> _notifications;
  DutyStatus _responderDutyStatus = DutyStatus.onDuty;
  Incident? _incomingAssignment;
  Timer? _liveSimulationTimer;
  int _simulationTick = 0;
  late List<User> _registeredUsers;
  bool _isAutoSimulationEnabled = true;

  RescueGridState() {
    _init();
  }

  void _init() {
    _registeredUsers = [
      MockData.studentUser,
      MockData.responderUser,
      MockData.adminUser,
      const User(
        id: 'user_student_2',
        name: 'Rohit Sharma',
        email: 'rohit.sharma@pes.edu',
        password: 'password123',
        role: UserRole.student,
        studentId: 'PES1UG24CS001',
        department: 'Computer Science',
        phone: '+91 98450 12345',
        emergencyContact: 'Mr. Sharma (Father) · +91 98450 99999',
      ),
      const User(
        id: 'resp_2',
        name: 'Sarah Chen, Paramedic',
        email: 's.chen@campus-medic.edu',
        password: 'password123',
        role: UserRole.responder,
        roleTitle: 'Campus Medic · Unit M-2',
        unitNumber: 'Unit M-2',
        skills: ['EMT-Basic', 'Advanced Cardiac Life Support', 'Trauma Assessment'],
        phone: '+1 (555) 456-7890',
      ),
    ];
    _currentUser = MockData.studentUser;
    _incidents = MockData.generateIncidents();
    _responders = List.from(MockData.responders);
    _notifications = List.from(MockData.notifications);
    _startLiveSimulation();
  }

  // Getters
  User get currentUser => _currentUser;
  UserRole get currentRole => _currentUser.role;
  List<User> get registeredUsers => List.unmodifiable(_registeredUsers);
  List<Incident> get incidents => List.unmodifiable(_incidents);
  List<Responder> get responders => List.unmodifiable(_responders);
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  DutyStatus get responderDutyStatus => _responderDutyStatus;
  Incident? get incomingAssignment => _incomingAssignment;
  bool get isAutoSimulationEnabled => _isAutoSimulationEnabled;
  int get simulationTick => _simulationTick;

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  Incident? get studentActiveIncident {
    return _incidents.firstWhere(
      (inc) =>
          inc.reporterName == _currentUser.name &&
          inc.status != IncidentStatus.resolved,
      orElse: () => _incidents.firstWhere(
        (inc) => inc.status != IncidentStatus.resolved,
        orElse: () => _incidents.first,
      ),
    );
  }

  Incident? get responderActiveIncident {
    return _incidents.firstWhere(
      (inc) =>
          inc.assignedResponderId == _currentUser.id &&
          inc.status != IncidentStatus.resolved,
      orElse: () => _incidents.firstWhere(
        (inc) =>
            inc.status == IncidentStatus.enRoute ||
            inc.status == IncidentStatus.arrived,
        orElse: () => _incidents.first,
      ),
    );
  }

  // Authentication by credentials
  bool loginWithCredentials(String identifier, String password) {
    final cleanId = identifier.trim().toLowerCase();
    final cleanPass = password.trim();

    if (cleanId.isEmpty) return false;

    final user = _registeredUsers.firstWhere(
      (u) =>
          u.email.toLowerCase() == cleanId ||
          (u.studentId != null && u.studentId!.toLowerCase() == cleanId) ||
          (u.unitNumber != null && u.unitNumber!.toLowerCase() == cleanId),
      orElse: () => const User(
        id: '',
        name: '',
        email: '',
        role: UserRole.student,
      ),
    );

    if (user.id.isEmpty) {
      return false;
    }

    // Password validation: match user's password, or default 'password123'
    if (user.password.isNotEmpty &&
        cleanPass != user.password &&
        cleanPass != 'password123' &&
        cleanPass != 'password') {
      return false;
    }

    _currentUser = user;
    if (user.role == UserRole.responder) {
      _responderDutyStatus = DutyStatus.onDuty;
      final exists = _responders.any((r) => r.id == user.id);
      if (!exists) {
        _responders.add(
          Responder(
            id: user.id,
            name: user.name,
            roleTitle: user.roleTitle ?? 'Campus Safety Unit',
            type: ResponderType.security,
            dutyStatus: DutyStatus.onDuty,
            currentWorkload: 0,
            maxWorkload: 3,
            latitude: 12.9344,
            longitude: 77.5345,
            skills: user.skills.isNotEmpty
                ? user.skills
                : ['First Aid', 'Campus Patrol'],
            shiftStartedAt: DateTime.now(),
            responsesToday: 0,
            avgResponseTimeMinutes: 3.5,
            phone: user.phone,
            avatarColorValue: 0xFF0B2545,
          ),
        );
      }
    }

    notifyListeners();
    return true;
  }

  // Register new account
  User registerNewAccount({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? studentId,
    String? department,
    String? unitNumber,
    String? roleTitle,
    String? phone,
    String? emergencyContact,
    ResponderType? responderType,
  }) {
    final newId = 'user_${role.name}_${DateTime.now().millisecondsSinceEpoch}';
    final user = User(
      id: newId,
      name: name.trim(),
      email: email.trim(),
      password: password.trim().isEmpty ? 'password123' : password.trim(),
      role: role,
      studentId: studentId?.trim(),
      department: department?.trim(),
      unitNumber: unitNumber?.trim(),
      roleTitle: roleTitle?.trim() ??
          (role == UserRole.student
              ? 'Student'
              : role == UserRole.responder
                  ? 'Campus Responder'
                  : 'Command Center Admin'),
      phone: phone?.trim().isNotEmpty == true
          ? phone!.trim()
          : '+1 (555) 000-0000',
      emergencyContact: emergencyContact?.trim(),
      skills: role == UserRole.responder
          ? ['First Aid', 'Emergency Dispatch']
          : const [],
    );

    _registeredUsers.add(user);
    _currentUser = user;

    if (role == UserRole.responder) {
      _responderDutyStatus = DutyStatus.onDuty;
      _responders.add(
        Responder(
          id: user.id,
          name: user.name,
          roleTitle: user.roleTitle ?? 'Campus Responder',
          type: responderType ?? ResponderType.security,
          dutyStatus: DutyStatus.onDuty,
          currentWorkload: 0,
          maxWorkload: 3,
          latitude: 12.9344,
          longitude: 77.5345,
          skills: user.skills,
          shiftStartedAt: DateTime.now(),
          responsesToday: 0,
          avgResponseTimeMinutes: 3.0,
          phone: user.phone,
          avatarColorValue: 0xFF0B2545,
        ),
      );
    }

    _notifications.insert(
      0,
      NotificationItem(
        id: 'notif_welcome_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Welcome to RescueGrid',
        message:
            'Account successfully registered for ${user.name} (${role.displayName}). Emergency network is active.',
        timestamp: DateTime.now(),
        type: NotificationType.alert,
      ),
    );

    notifyListeners();
    return user;
  }

  // Switch role for demo flow
  void switchRole(UserRole role) {
    final candidate = _registeredUsers.firstWhere(
      (u) => u.role == role,
      orElse: () {
        switch (role) {
          case UserRole.student:
            return MockData.studentUser;
          case UserRole.responder:
            return MockData.responderUser;
          case UserRole.admin:
            return MockData.adminUser;
        }
      },
    );
    _currentUser = candidate;
    notifyListeners();
  }


  void setIncomingAssignment(Incident? incident) {
    _incomingAssignment = incident;
    notifyListeners();
  }

  void toggleDutyStatus(DutyStatus status) {
    _responderDutyStatus = status;
    final index = _responders.indexWhere((r) => r.id == _currentUser.id);
    if (index != -1) {
      _responders[index] = _responders[index].copyWith(dutyStatus: status);
    }
    notifyListeners();
  }

  // Report new emergency
  Incident reportEmergency({
    required IncidentCategory category,
    required String locationName,
    required String locationDetail,
    required String description,
    required String peopleAffected,
    String? photoAsset,
    Uint8List? photoBytes,
  }) {
    final newId = 'RG-${2042 + _incidents.length}';
    final now = DateTime.now();

    // Auto-compute mock severity
    IncidentSeverity severity;
    double score;
    if (category == IncidentCategory.medical || category == IncidentCategory.fire) {
      severity = IncidentSeverity.critical;
      score = 8.6;
    } else if (category == IncidentCategory.securityThreat || category == IncidentCategory.accident) {
      severity = IncidentSeverity.high;
      score = 7.1;
    } else {
      severity = IncidentSeverity.medium;
      score = 5.2;
    }

    final newIncident = Incident(
      id: newId,
      category: category,
      title: description.isNotEmpty
          ? (description.length > 36 ? '${description.substring(0, 36)}...' : description)
          : '${category.displayName} Reported',
      description: description.isNotEmpty ? description : 'Emergency reported via RescueGrid SOS.',
      locationName: locationName,
      locationDetail: locationDetail,
      latitude: 37.7750 + (_incidents.length * 0.0003),
      longitude: -122.4190 + (_incidents.length * 0.0002),
      reporterName: _currentUser.name,
      reporterPhone: _currentUser.phone,
      photoAsset: photoAsset,
      photoBytes: photoBytes,
      severity: severity,
      severityScore: score,
      severityBreakdown: SeverityBreakdown(
        categoryWeight: score * 0.35,
        keywordsScore: score * 0.25,
        peopleScore: score * 0.2,
        timeRiskScore: score * 0.1,
        locationRiskScore: score * 0.1,
      ),
      peopleAffected: peopleAffected,
      status: IncidentStatus.reported,
      createdAt: now,
      timeline: [
        TimelineEvent(
          id: 't_new_1',
          title: 'Emergency Reported',
          description: 'Reported by ${_currentUser.name} at $locationName',
          timestamp: now,
          status: IncidentStatus.reported,
          actorName: _currentUser.name,
          actorRole: 'Student Reporter',
        ),
      ],
      rankedCandidates: MockData.generateIncidents().first.rankedCandidates,
    );

    _incidents.insert(0, newIncident);

    // Add alert notification
    _notifications.insert(
      0,
      NotificationItem(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
        title: 'New ${severity.label} Incident: $newId',
        message: '${category.displayName} at $locationName',
        timestamp: now,
        type: NotificationType.alert,
        incidentId: newId,
      ),
    );

    notifyListeners();

    // Trigger auto-dispatch simulation after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      autoAssignIncident(newId);
    });

    return newIncident;
  }

  void autoAssignIncident(String incidentId) {
    final index = _incidents.indexWhere((i) => i.id == incidentId);
    if (index == -1) return;

    final target = _incidents[index];
    if (target.status != IncidentStatus.reported) return;

    final assignedMedic = _responders.firstWhere(
      (r) => r.type == ResponderType.medical && r.dutyStatus == DutyStatus.onDuty,
      orElse: () => _responders.first,
    );

    final now = DateTime.now();
    final updatedTimeline = List<TimelineEvent>.from(target.timeline)
      ..add(
        TimelineEvent(
          id: 't_${now.millisecondsSinceEpoch}',
          title: 'Assigned to ${assignedMedic.name}',
          description: 'Ranked #1 candidate assigned. Waiting for responder acceptance.',
          timestamp: now,
          status: IncidentStatus.assigned,
          actorName: 'Dispatch Engine',
          actorRole: 'Automated System',
        ),
      );

    _incidents[index] = target.copyWith(
      status: IncidentStatus.assigned,
      assignedResponderId: assignedMedic.id,
      assignedResponderName: assignedMedic.name,
      assignedResponderRole: assignedMedic.roleTitle,
      responderEtaMinutes: 4,
      responderDistanceMeters: 650,
      timeline: updatedTimeline,
    );

    // If responder user is current, trigger incoming assignment overlay
    if (_currentUser.role == UserRole.responder) {
      _incomingAssignment = _incidents[index];
    }

    notifyListeners();
  }

  void acceptAssignment(String incidentId) {
    final index = _incidents.indexWhere((i) => i.id == incidentId);
    if (index == -1) return;

    final now = DateTime.now();
    final target = _incidents[index];
    final updatedTimeline = List<TimelineEvent>.from(target.timeline)
      ..add(
        TimelineEvent(
          id: 't_${now.millisecondsSinceEpoch}',
          title: 'Assignment Accepted',
          description: '${_currentUser.name} accepted and started navigation.',
          timestamp: now,
          status: IncidentStatus.enRoute,
          actorName: _currentUser.name,
          actorRole: _currentUser.roleTitle ?? 'Responder',
        ),
      );

    _incidents[index] = target.copyWith(
      status: IncidentStatus.enRoute,
      assignedResponderId: _currentUser.id,
      assignedResponderName: _currentUser.name,
      assignedResponderRole: _currentUser.roleTitle,
      responderEtaMinutes: 3,
      timeline: updatedTimeline,
    );

    _incomingAssignment = null;
    notifyListeners();
  }

  void declineAssignment(String incidentId, String reason) {
    final index = _incidents.indexWhere((i) => i.id == incidentId);
    if (index == -1) return;

    final now = DateTime.now();
    final target = _incidents[index];
    final updatedTimeline = List<TimelineEvent>.from(target.timeline)
      ..add(
        TimelineEvent(
          id: 't_${now.millisecondsSinceEpoch}',
          title: 'Assignment Passed: $reason',
          description: '${_currentUser.name} declined assignment ($reason). Reassigning to next candidate.',
          timestamp: now,
          status: IncidentStatus.escalated,
          actorName: _currentUser.name,
          actorRole: 'Responder',
        ),
      );

    _incidents[index] = target.copyWith(
      status: IncidentStatus.escalated,
      isEscalated: true,
      timeline: updatedTimeline,
    );

    _incomingAssignment = null;
    notifyListeners();
  }

  void updateIncidentStatus(String incidentId, IncidentStatus newStatus) {
    final index = _incidents.indexWhere((i) => i.id == incidentId);
    if (index == -1) return;

    final now = DateTime.now();
    final target = _incidents[index];

    String eventTitle;
    String eventDesc;
    switch (newStatus) {
      case IncidentStatus.enRoute:
        eventTitle = 'Responder En Route';
        eventDesc = 'Unit moving toward incident scene.';
        break;
      case IncidentStatus.arrived:
        eventTitle = 'Responder Arrived on Scene';
        eventDesc = 'Unit is on-scene. Beginning patient stabilization / area security.';
        break;
      case IncidentStatus.resolved:
        eventTitle = 'Incident Resolved';
        eventDesc = 'Situation brought under control. Incident timeline closed.';
        break;
      default:
        eventTitle = 'Status Updated';
        eventDesc = 'Status changed to ${newStatus.label}';
    }

    final updatedTimeline = List<TimelineEvent>.from(target.timeline)
      ..add(
        TimelineEvent(
          id: 't_${now.millisecondsSinceEpoch}',
          title: eventTitle,
          description: eventDesc,
          timestamp: now,
          status: newStatus,
          actorName: _currentUser.name,
          actorRole: _currentUser.roleTitle ?? _currentUser.role.displayName,
        ),
      );

    _incidents[index] = target.copyWith(
      status: newStatus,
      responderEtaMinutes: newStatus == IncidentStatus.arrived || newStatus == IncidentStatus.resolved ? 0 : target.responderEtaMinutes,
      timeline: updatedTimeline,
    );

    notifyListeners();
  }

  void requestBackup(String incidentId, String backupType, String note) {
    final index = _incidents.indexWhere((i) => i.id == incidentId);
    if (index == -1) return;

    final now = DateTime.now();
    final target = _incidents[index];
    final updatedTimeline = List<TimelineEvent>.from(target.timeline)
      ..add(
        TimelineEvent(
          id: 't_${now.millisecondsSinceEpoch}',
          title: 'Backup Requested: $backupType',
          description: 'Note: $note',
          timestamp: now,
          status: target.status,
          actorName: _currentUser.name,
          actorRole: _currentUser.roleTitle ?? 'Responder',
        ),
      );

    _incidents[index] = target.copyWith(
      backupRequestedType: backupType,
      timeline: updatedTimeline,
    );

    // Notify command center
    _notifications.insert(
      0,
      NotificationItem(
        id: 'n_backup_${now.millisecondsSinceEpoch}',
        title: 'BACKUP REQUESTED: $backupType',
        message: 'Unit ${_currentUser.name} requested backup at ${target.locationName}',
        timestamp: now,
        type: NotificationType.backupRequest,
        incidentId: incidentId,
      ),
    );

    notifyListeners();
  }

  void overrideAssign(String incidentId, String responderId, String reason) {
    final incIndex = _incidents.indexWhere((i) => i.id == incidentId);
    final respIndex = _responders.indexWhere((r) => r.id == responderId);
    if (incIndex == -1 || respIndex == -1) return;

    final target = _incidents[incIndex];
    final newResp = _responders[respIndex];
    final now = DateTime.now();

    final updatedTimeline = List<TimelineEvent>.from(target.timeline)
      ..add(
        TimelineEvent(
          id: 't_override_${now.millisecondsSinceEpoch}',
          title: 'Command Manual Override',
          description: 'Reassigned to ${newResp.name} (${newResp.roleTitle}). Reason: $reason',
          timestamp: now,
          status: IncidentStatus.assigned,
          actorName: _currentUser.name,
          actorRole: 'Command Center Director',
        ),
      );

    _incidents[incIndex] = target.copyWith(
      status: IncidentStatus.assigned,
      assignedResponderId: newResp.id,
      assignedResponderName: newResp.name,
      assignedResponderRole: newResp.roleTitle,
      isEscalated: false,
      timeline: updatedTimeline,
    );

    notifyListeners();
  }

  void markNotificationRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void _startLiveSimulation() {
    _liveSimulationTimer?.cancel();
    _liveSimulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isAutoSimulationEnabled) return;
      _simulationTick++;

      // Gently advance moving responder coordinates along route for active en-route incidents
      for (int i = 0; i < _incidents.length; i++) {
        final inc = _incidents[i];
        if (inc.status == IncidentStatus.enRoute && inc.responderEtaMinutes > 0) {
          final nextEta = (inc.responderEtaMinutes - 1).clamp(0, 10);
          final nextDistance = (inc.responderDistanceMeters - 120).clamp(0.0, 5000.0);
          _incidents[i] = inc.copyWith(
            responderEtaMinutes: nextEta,
            responderDistanceMeters: nextDistance,
          );
          notifyListeners();
          break;
        }
      }
    });
  }

  void toggleAutoSimulation() {
    _isAutoSimulationEnabled = !_isAutoSimulationEnabled;
    notifyListeners();
  }

  void resetDemo() {
    _init();
    notifyListeners();
  }

  @override
  void dispose() {
    _liveSimulationTimer?.cancel();
    super.dispose();
  }
}
