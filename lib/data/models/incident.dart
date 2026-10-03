import 'dart:typed_data';
import 'enums.dart';
import 'ranked_candidate.dart';
import 'timeline_event.dart';

class SeverityBreakdown {
  final double categoryWeight; // e.g. 3.0 / 3.0
  final double keywordsScore; // e.g. 2.1 / 2.5
  final double peopleScore; // e.g. 1.8 / 2.0
  final double timeRiskScore; // e.g. 0.8 / 1.0
  final double locationRiskScore; // e.g. 0.7 / 1.5

  const SeverityBreakdown({
    required this.categoryWeight,
    required this.keywordsScore,
    required this.peopleScore,
    required this.timeRiskScore,
    required this.locationRiskScore,
  });

  double get totalScore =>
      categoryWeight + keywordsScore + peopleScore + timeRiskScore + locationRiskScore;
}

class Incident {
  final String id; // e.g. "RG-2041"
  final IncidentCategory category;
  final String title;
  final String description;
  final String locationName;
  final String locationDetail;
  final double latitude;
  final double longitude;
  final String reporterName;
  final String reporterPhone;
  final String? photoAsset;
  final Uint8List? photoBytes;
  final IncidentSeverity severity;
  final double severityScore; // 0.0 to 10.0
  final SeverityBreakdown severityBreakdown;
  final String peopleAffected; // "1", "2–5", "5+"
  final IncidentStatus status;
  final DateTime createdAt;
  final String? assignedResponderId;
  final String? assignedResponderName;
  final String? assignedResponderRole;
  final int responderEtaMinutes;
  final double responderDistanceMeters;
  final List<TimelineEvent> timeline;
  final List<RankedCandidate> rankedCandidates;
  final bool isEscalated;
  final String? backupRequestedType;

  const Incident({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.locationName,
    required this.locationDetail,
    required this.latitude,
    required this.longitude,
    required this.reporterName,
    required this.reporterPhone,
    this.photoAsset,
    this.photoBytes,
    required this.severity,
    required this.severityScore,
    required this.severityBreakdown,
    this.peopleAffected = '1',
    required this.status,
    required this.createdAt,
    this.assignedResponderId,
    this.assignedResponderName,
    this.assignedResponderRole,
    this.responderEtaMinutes = 4,
    this.responderDistanceMeters = 850,
    required this.timeline,
    this.rankedCandidates = const [],
    this.isEscalated = false,
    this.backupRequestedType,
  });

  Incident copyWith({
    IncidentStatus? status,
    String? assignedResponderId,
    String? assignedResponderName,
    String? assignedResponderRole,
    int? responderEtaMinutes,
    double? responderDistanceMeters,
    List<TimelineEvent>? timeline,
    bool? isEscalated,
    String? backupRequestedType,
    Uint8List? photoBytes,
  }) {
    return Incident(
      id: id,
      category: category,
      title: title,
      description: description,
      locationName: locationName,
      locationDetail: locationDetail,
      latitude: latitude,
      longitude: longitude,
      reporterName: reporterName,
      reporterPhone: reporterPhone,
      photoAsset: photoAsset,
      photoBytes: photoBytes ?? this.photoBytes,
      severity: severity,
      severityScore: severityScore,
      severityBreakdown: severityBreakdown,
      peopleAffected: peopleAffected,
      status: status ?? this.status,
      createdAt: createdAt,
      assignedResponderId: assignedResponderId ?? this.assignedResponderId,
      assignedResponderName: assignedResponderName ?? this.assignedResponderName,
      assignedResponderRole: assignedResponderRole ?? this.assignedResponderRole,
      responderEtaMinutes: responderEtaMinutes ?? this.responderEtaMinutes,
      responderDistanceMeters: responderDistanceMeters ?? this.responderDistanceMeters,
      timeline: timeline ?? this.timeline,
      rankedCandidates: rankedCandidates,
      isEscalated: isEscalated ?? this.isEscalated,
      backupRequestedType: backupRequestedType ?? this.backupRequestedType,
    );
  }
}

