import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/dimensions.dart';
import '../../data/models/incident.dart';
import '../../data/mock/rescue_grid_state.dart';
import '../../widgets/countdown_ring.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/outline_action_button.dart';

class IncomingAssignmentScreen extends StatefulWidget {
  final Incident? incident;

  const IncomingAssignmentScreen({
    super.key,
    this.incident,
  });

  @override
  State<IncomingAssignmentScreen> createState() => _IncomingAssignmentScreenState();
}

class _IncomingAssignmentScreenState extends State<IncomingAssignmentScreen> {
  late Incident _incident;

  @override
  void initState() {
    super.initState();
    final state = context.read<RescueGridState>();
    _incident = widget.incident ?? state.incidents.first;
  }

  void _onAccept() {
    final state = context.read<RescueGridState>();
    state.acceptAssignment(_incident.id);
    context.go('/responder/active/${_incident.id}');
  }

  void _onDecline() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DeclineReasonSheet(
        onReasonSelected: (reason) {
          final state = context.read<RescueGridState>();
          state.declineAssignment(_incident.id, reason);
          Navigator.pop(ctx);
          context.go('/responder');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Assignment passed: $reason. Reassigning to next candidate.'),
              backgroundColor: RgColors.warning,
            ),
          );
        },
      ),
    );
  }

  void _onCountdownExpired() {
    if (!mounted) return;
    final state = context.read<RescueGridState>();
    state.declineAssignment(_incident.id, 'Timeout unacknowledged after 30s');
    context.go('/responder');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('30s countdown expired. Incident escalated to next candidate.'),
        backgroundColor: RgColors.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RgColors.surfaceDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Red Severity Band
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: RgColors.secondary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(PhosphorIconsBold.warningOctagon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_incident.severity.label} EMERGENCY DISPATCH',
                    style: RgTypography.subheading.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Large Category Icon Container
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _incident.category.color.withOpacity(0.2),
                        border: Border.all(color: _incident.category.color, width: 2),
                      ),
                      child: Icon(
                        _incident.category.icon,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      _incident.title,
                      style: RgTypography.headingLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _incident.description,
                      style: RgTypography.bodyMedium.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Distance & ETA Highlight Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              const Icon(PhosphorIconsRegular.navigationArrow, color: RgColors.primaryAccent, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '${(_incident.responderDistanceMeters / 1000).toStringAsFixed(1)} km away',
                                style: RgTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Container(width: 1, height: 20, color: const Color(0xFF475569)),
                          Row(
                            children: [
                              const Icon(PhosphorIconsRegular.timer, color: RgColors.success, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'ETA ${_incident.responderEtaMinutes} min',
                                style: RgTypography.caption.copyWith(color: RgColors.success, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Location Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(PhosphorIconsRegular.mapPin, color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _incident.locationName,
                                  style: RgTypography.subheading.copyWith(color: Colors.white, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 26, top: 2),
                            child: Text(
                              _incident.locationDetail,
                              style: RgTypography.caption.copyWith(color: const Color(0xFF94A3B8)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 26),
                            child: Text(
                              'Reporter: ${_incident.reporterName} (${_incident.reporterPhone})',
                              style: RgTypography.caption.copyWith(color: const Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // "Why You?" Candidate Ranking Chips
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'WHY YOU WERE ASSIGNED',
                        style: RgTypography.caption.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _WhyYouChip(label: 'Medical Skill Match (ACLS/BLS)', icon: PhosphorIconsRegular.checkCircle),
                        _WhyYouChip(label: 'Nearest Unit (450m)', icon: PhosphorIconsRegular.navigationArrow),
                        _WhyYouChip(label: 'Low Workload (0 Active)', icon: PhosphorIconsRegular.pulse),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Circular Countdown Ring (30 seconds)
                    CountdownRing(
                      durationSeconds: 30,
                      size: 96,
                      onExpired: _onCountdownExpired,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Auto-escalates to next candidate on expiry',
                      style: RgTypography.caption.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions (Accept / Decline)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF0B132B),
                border: Border(top: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: Column(
                children: [
                  PrimaryButton(
                    label: 'Accept Assignment & Navigate',
                    icon: PhosphorIconsBold.check,
                    height: 52,
                    onPressed: _onAccept,
                  ),
                  const SizedBox(height: 10),
                  OutlineActionButton(
                    label: 'Decline / Pass Assignment',
                    icon: PhosphorIconsRegular.x,
                    color: const Color(0xFF94A3B8),
                    height: 48,
                    onPressed: _onDecline,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhyYouChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _WhyYouChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: RgColors.success),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeclineReasonSheet extends StatelessWidget {
  final ValueChanged<String> onReasonSelected;

  const _DeclineReasonSheet({required this.onReasonSelected});

  @override
  Widget build(BuildContext context) {
    final reasons = [
      'Engaged in higher-priority incident',
      'Location blocked / vehicle transit issue',
      'Unfit for medical category equipment',
      'End of shift / relief handover',
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Reason for Declining',
            style: RgTypography.headingMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'The incident will be automatically dispatched to the next ranked candidate.',
            style: RgTypography.bodySmall,
          ),
          const SizedBox(height: 16),
          ...reasons.map((r) => ListTile(
                dense: true,
                title: Text(r, style: RgTypography.bodyMedium),
                trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16),
                onTap: () => onReasonSelected(r),
              )),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
