import 'enums.dart';

class RankedCandidate {
  final String responderId;
  final String name;
  final ResponderType type;
  final double matchScore; // e.g. 96.5%
  final int etaMinutes;
  final double distanceMeters;
  final int currentWorkload;
  final int maxWorkload;
  final List<String> matchReasons; // e.g. "Medical skill match", "Nearest unit", "Low workload"

  const RankedCandidate({
    required this.responderId,
    required this.name,
    required this.type,
    required this.matchScore,
    required this.etaMinutes,
    required this.distanceMeters,
    required this.currentWorkload,
    required this.maxWorkload,
    required this.matchReasons,
  });
}
