import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/incident.dart';
import '../../data/models/responder.dart';
import '../../data/mock/rescue_grid_state.dart';
import '../../widgets/severity_badge.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/outline_action_button.dart';
import '../../widgets/timeline_view.dart';
import '../../widgets/user_avatar.dart';

class IncidentDetailSheet extends StatefulWidget {
  final Incident incident;
  final bool isDrawerMode;
  final VoidCallback? onClose;

  const IncidentDetailSheet({
    super.key,
    required this.incident,
    this.isDrawerMode = false,
    this.onClose,
  });

  @override
  State<IncidentDetailSheet> createState() => _IncidentDetailSheetState();
}

class _IncidentDetailSheetState extends State<IncidentDetailSheet> {
  void _openOverrideSheet(BuildContext context, RescueGridState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OverrideAssignmentSheet(
        incident: widget.incident,
        responders: state.responders,
        onConfirmed: (responderId, reason) {
          state.overrideAssign(widget.incident.id, responderId, reason);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Incident #${widget.incident.id} reassigned successfully.'),
              backgroundColor: RgColors.success,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RescueGridState>();
    // Get fresh incident data in case of override updates
    final currentIncident = state.incidents.firstWhere(
      (i) => i.id == widget.incident.id,
      orElse: () => widget.incident,
    );

    final content = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.isDrawerMode
            ? BorderRadius.circular(RgDimensions.radiusCard)
            : const BorderRadius.vertical(top: Radius.circular(24)),
        border: widget.isDrawerMode ? Border.all(color: RgColors.border) : null,
        boxShadow: RgDimensions.elevatedShadow,
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          currentIncident.id,
                          style: RgTypography.headingMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SeverityBadge(severity: currentIncident.severity),
                        const SizedBox(width: 6),
                        StatusBadge(status: currentIncident.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Reported ${RgFormatters.dateAndTime(currentIncident.createdAt)}',
                      style: RgTypography.caption.copyWith(color: RgColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(PhosphorIconsRegular.x, size: 20),
                  onPressed: widget.onClose ?? () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Title and Description
                Text(
                  currentIncident.title,
                  style: RgTypography.headingMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  currentIncident.description,
                  style: RgTypography.bodyMedium.copyWith(color: RgColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // Location Details Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RgColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
                    border: Border.all(color: RgColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsRegular.mapPin, color: RgColors.primaryAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentIncident.locationName,
                              style: RgTypography.caption.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              currentIncident.locationDetail,
                              style: RgTypography.caption.copyWith(color: RgColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${currentIncident.peopleAffected} affected',
                        style: RgTypography.caption.copyWith(
                          color: RgColors.primaryAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (currentIncident.photoBytes != null || currentIncident.photoAsset != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Incident Photo Evidence',
                    style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: RgColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
                      border: Border.all(color: RgColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 180),
                          child: SizedBox(
                            width: double.infinity,
                            child: currentIncident.photoBytes != null
                                ? Image.memory(
                                    currentIncident.photoBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    currentIncident.photoAsset!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Center(
                                      child: Icon(PhosphorIconsRegular.image, size: 40),
                                    ),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                currentIncident.photoBytes != null
                                    ? PhosphorIconsFill.hardDrive
                                    : PhosphorIconsRegular.image,
                                size: 14,
                                color: RgColors.primaryAccent,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  currentIncident.photoBytes != null
                                      ? 'Photo attached from local storage by reporter'
                                      : 'Simulated visual evidence',
                                  style: RgTypography.caption.copyWith(
                                    color: RgColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Severity Score & Breakdown Section
                _buildSeverityBreakdown(currentIncident),
                const SizedBox(height: 24),

                // Assigned Responder Card
                Text(
                  'Assigned Responder',
                  style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (currentIncident.assignedResponderName != null)
                  _buildAssignedResponderInfo(currentIncident)
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: RgColors.warningLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(PhosphorIconsRegular.warningCircle, color: RgColors.warning),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No responder currently assigned. Use manual override to dispatch.',
                            style: RgTypography.caption.copyWith(
                              color: RgColors.warning,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Manual Override Button
                OutlineActionButton(
                  label: 'Manual Dispatch Override',
                  icon: PhosphorIconsRegular.arrowsLeftRight,
                  color: RgColors.warning,
                  onPressed: () => _openOverrideSheet(context, state),
                ),
                const SizedBox(height: 24),

                // Ranked Candidates Section
                if (currentIncident.rankedCandidates.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dispatch Engine Ranking',
                        style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Top Candidates',
                        style: RgTypography.caption.copyWith(color: RgColors.primaryAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...currentIncident.rankedCandidates.map(
                    (cand) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildCandidateCard(cand),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Full Chronological Timeline
                Text(
                  'Full Incident Audit Timeline',
                  style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                TimelineView(
                  events: currentIncident.timeline,
                  shrinkWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.isDrawerMode) {
      return content;
    }

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: content,
    );
  }

  Widget _buildSeverityBreakdown(Incident incident) {
    final bd = incident.severityBreakdown;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RgColors.surfaceMuted,
        borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
        border: Border.all(color: RgColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SEVERITY ENGINE ASSESSMENT',
                style: RgTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: RgColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: incident.severity.color,
                  borderRadius: BorderRadius.circular(RgDimensions.radiusFull),
                ),
                child: Text(
                  '${incident.severityScore.toStringAsFixed(1)} / 10.0',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildBreakdownBar('Category Baseline', bd.categoryWeight, 3.0),
          _buildBreakdownBar('Urgent Keywords Match', bd.keywordsScore, 2.5),
          _buildBreakdownBar('People Affected Multiplier', bd.peopleScore, 2.0),
          _buildBreakdownBar('Time of Day Risk', bd.timeRiskScore, 1.0),
          _buildBreakdownBar('Location Vulnerability', bd.locationRiskScore, 1.5),
        ],
      ),
    );
  }

  Widget _buildBreakdownBar(String label, double value, double max) {
    final pct = (value / max).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: RgTypography.caption.copyWith(fontSize: 11.5)),
              Text(
                '${value.toStringAsFixed(1)} / ${max.toStringAsFixed(1)}',
                style: RgTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: RgColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                pct > 0.75
                    ? RgColors.secondary
                    : (pct > 0.5 ? RgColors.warning : RgColors.primaryAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedResponderInfo(Incident incident) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
        border: Border.all(color: RgColors.border),
      ),
      child: Row(
        children: [
          UserAvatar(
            initials: incident.assignedResponderName != null
                ? incident.assignedResponderName![0]
                : 'R',
            size: 40,
            backgroundColor: RgColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incident.assignedResponderName!,
                  style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  incident.assignedResponderRole ?? 'Active Unit',
                  style: RgTypography.caption.copyWith(color: RgColors.textSecondary),
                ),
              ],
            ),
          ),
          if (incident.responderEtaMinutes > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: RgColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'ETA ${incident.responderEtaMinutes}m',
                style: RgTypography.caption.copyWith(
                  color: RgColors.primaryAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(dynamic candidate) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
        border: Border.all(color: RgColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                candidate.name,
                style: RgTypography.subheading.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: RgColors.successLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${candidate.matchScore.toStringAsFixed(1)}% match',
                  style: RgTypography.caption.copyWith(
                    color: RgColors.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'ETA ${candidate.etaMinutes} min Â· ${candidate.distanceMeters.round()}m away Â· Workload: ${candidate.currentWorkload}/${candidate.maxWorkload}',
                style: RgTypography.caption.copyWith(color: RgColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            children: (candidate.matchReasons as List<String>).map((reason) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: RgColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  reason,
                  style: const TextStyle(fontSize: 10, color: RgColors.textSecondary),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _OverrideAssignmentSheet extends StatefulWidget {
  final Incident incident;
  final List<Responder> responders;
  final Function(String responderId, String reason) onConfirmed;

  const _OverrideAssignmentSheet({
    required this.incident,
    required this.responders,
    required this.onConfirmed,
  });

  @override
  State<_OverrideAssignmentSheet> createState() => _OverrideAssignmentSheetState();
}

class _OverrideAssignmentSheetState extends State<_OverrideAssignmentSheet> {
  String? _selectedResponderId;
  final _reasonController = TextEditingController(text: 'Command priority override for closer unit proximity.');

  @override
  void initState() {
    super.initState();
    if (widget.responders.isNotEmpty) {
      _selectedResponderId = widget.responders.first.id;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(PhosphorIconsRegular.shieldCheck, color: RgColors.warning, size: 22),
              const SizedBox(width: 8),
              Text(
                'Manual Dispatch Override',
                style: RgTypography.headingMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Assign incident #${widget.incident.id} to any available staff member.',
            style: RgTypography.bodySmall,
          ),
          const SizedBox(height: 16),

          Text('Select Available Responder:', style: RgTypography.caption.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: ListView(
              shrinkWrap: true,
              children: widget.responders.map((resp) {
                return RadioListTile<String>(
                  value: resp.id,
                  groupValue: _selectedResponderId,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    resp.name,
                    style: RgTypography.subheading.copyWith(fontSize: 14),
                  ),
                  subtitle: Text(
                    '${resp.roleTitle} Â· Workload ${resp.currentWorkload}/${resp.maxWorkload}',
                    style: RgTypography.caption,
                  ),
                  onChanged: (val) {
                    setState(() => _selectedResponderId = val);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          Text('Reason for Override (Audited in Timeline):', style: RgTypography.caption.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _reasonController,
            style: RgTypography.bodyMedium,
            decoration: const InputDecoration(
              hintText: 'Enter reason for manual dispatch...',
            ),
          ),
          const SizedBox(height: 20),

          PrimaryButton(
            label: 'Confirm Reassignment',
            icon: PhosphorIconsRegular.check,
            onPressed: () {
              if (_selectedResponderId != null) {
                widget.onConfirmed(_selectedResponderId!, _reasonController.text);
              }
            },
          ),
        ],
      ),
    );
  }
}
