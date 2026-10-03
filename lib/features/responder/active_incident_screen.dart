import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/dimensions.dart';
import '../../data/models/enums.dart';
import '../../data/models/incident.dart';
import '../../data/mock/mock_data.dart';
import '../../data/mock/rescue_grid_state.dart';
import '../../widgets/severity_badge.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/outline_action_button.dart';
import '../../widgets/campus_map_panel.dart';
import '../../widgets/timeline_view.dart';

class ActiveIncidentScreen extends StatefulWidget {
  final String? incidentId;

  const ActiveIncidentScreen({
    super.key,
    this.incidentId,
  });

  @override
  State<ActiveIncidentScreen> createState() => _ActiveIncidentScreenState();
}

class _ActiveIncidentScreenState extends State<ActiveIncidentScreen> {
  bool _isTimelineExpanded = false;

  void _openRequestBackupSheet(BuildContext context, Incident incident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RequestBackupSheet(
        incident: incident,
        onSubmitted: (type, note) {
          final state = context.read<RescueGridState>();
          state.requestBackup(incident.id, type, note);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Backup requested ($type). Command Center alerted.'),
              backgroundColor: RgColors.warning,
            ),
          );
        },
      ),
    );
  }

  void _showResolveDialog(BuildContext context, Incident incident) {
    showDialog(
      context: context,
      builder: (ctx) => _ResolveIncidentDialog(
        incident: incident,
        onResolved: (outcome, note) {
          final state = context.read<RescueGridState>();
          state.updateIncidentStatus(incident.id, IncidentStatus.resolved);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incident resolved. Timeline archived.'),
              backgroundColor: RgColors.success,
            ),
          );
          context.go('/responder');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RescueGridState>();
    final incident = state.incidents.firstWhere(
      (i) => i.id == (widget.incidentId ?? 'RG-2041'),
      orElse: () => state.incidents.first,
    );
    final responder = state.responders.first;

    final routePoints = MockData.demoRouteCoordinates
        .map((coord) => LatLng(coord[0], coord[1]))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Full-screen Campus Map with Polyline and Markers
          Positioned.fill(
            child: CampusMapPanel(
              height: double.infinity,
              activeIncident: incident,
              activeResponder: responder,
              routePolyline: routePoints,
              showFloatingEta: false,
            ),
          ),

          // 2. Top Bar Navigation + Glass Floating Summary Card
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: RgDimensions.cardShadow,
                          ),
                          child: IconButton(
                            icon: const Icon(PhosphorIconsRegular.arrowLeft, size: 22),
                            onPressed: () => context.go('/responder'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: RgDimensions.cardShadow,
                              border: Border.all(color: RgColors.border),
                            ),
                            child: Row(
                              children: [
                                SeverityBadge(severity: incident.severity),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${incident.id} Â· ${incident.title}',
                                    style: RgTypography.subheading.copyWith(fontSize: 13.5),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Draggable Responsive Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.40,
            minChildSize: 0.22,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: RgColors.borderStrong,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Contextual Progressive Status Button
                    _buildContextualActionButton(context, state, incident),
                    const SizedBox(height: 14),

                    // Secondary Actions Row: Request Backup & Call Reporter
                    Row(
                      children: [
                        Expanded(
                          child: OutlineActionButton(
                            label: incident.backupRequestedType != null
                                ? 'Backup (${incident.backupRequestedType})'
                                : 'Request Backup',
                            icon: PhosphorIconsRegular.shieldPlus,
                            color: RgColors.warning,
                            height: 46,
                            onPressed: () => _openRequestBackupSheet(context, incident),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlineActionButton(
                            label: 'Call Reporter',
                            icon: PhosphorIconsRegular.phoneCall,
                            color: RgColors.primaryAccent,
                            height: 46,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Calling ${incident.reporterName} (${incident.reporterPhone})...'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Incident Quick Details
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: RgColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
                        border: Border.all(color: RgColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(PhosphorIconsRegular.mapPin, color: RgColors.primaryAccent, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  incident.locationName,
                                  style: RgTypography.subheading.copyWith(fontSize: 14),
                                ),
                              ),
                              if (incident.responderEtaMinutes > 0)
                                Text(
                                  'ETA ${incident.responderEtaMinutes} min',
                                  style: RgTypography.caption.copyWith(
                                    color: RgColors.primaryAccent,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 26),
                            child: Text(
                              incident.locationDetail,
                              style: RgTypography.caption.copyWith(color: RgColors.textSecondary),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 26),
                            child: Text(
                              'Reporter: ${incident.reporterName} Â· ${incident.peopleAffected} affected',
                              style: RgTypography.caption.copyWith(color: RgColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (incident.photoBytes != null || incident.photoAsset != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                          color: RgColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
                          border: Border.all(color: RgColors.border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 160),
                              child: SizedBox(
                                width: double.infinity,
                                child: incident.photoBytes != null
                                    ? Image.memory(
                                        incident.photoBytes!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        incident.photoAsset!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: Icon(PhosphorIconsRegular.image, size: 36),
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    incident.photoBytes != null
                                        ? PhosphorIconsFill.hardDrive
                                        : PhosphorIconsRegular.image,
                                    size: 14,
                                    color: RgColors.primaryAccent,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      incident.photoBytes != null
                                          ? 'Photo Evidence (Local storage attachment)'
                                          : 'Incident Photo Evidence',
                                      style: RgTypography.caption.copyWith(
                                        fontWeight: FontWeight.w700,
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

                    // Expandable Timeline
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Live Response Timeline',
                          style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _isTimelineExpanded = !_isTimelineExpanded);
                          },
                          child: Text(_isTimelineExpanded ? 'Collapse' : 'Expand'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TimelineView(
                      events: _isTimelineExpanded
                          ? incident.timeline
                          : incident.timeline.reversed.take(2).toList().reversed.toList(),
                      shrinkWrap: true,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContextualActionButton(
    BuildContext context,
    RescueGridState state,
    Incident incident,
  ) {
    switch (incident.status) {
      case IncidentStatus.assigned:
        return PrimaryButton(
          label: 'Start Navigation (En Route)',
          icon: PhosphorIconsRegular.navigationArrow,
          onPressed: () {
            state.updateIncidentStatus(incident.id, IncidentStatus.enRoute);
          },
        );

      case IncidentStatus.enRoute:
        return PrimaryButton(
          label: 'Mark Arrived on Scene',
          icon: PhosphorIconsRegular.mapPin,
          onPressed: () {
            state.updateIncidentStatus(incident.id, IncidentStatus.arrived);
          },
        );

      case IncidentStatus.arrived:
        return PrimaryButton(
          label: 'Mark Incident Resolved',
          icon: PhosphorIconsRegular.checkCircle,
          isSecondary: false,
          onPressed: () {
            _showResolveDialog(context, incident);
          },
        );

      case IncidentStatus.resolved:
        return PrimaryButton(
          label: 'Incident Resolved Â· Case Closed',
          icon: PhosphorIconsRegular.check,
          isSecondary: true,
          onPressed: () => context.go('/responder'),
        );

      default:
        return PrimaryButton(
          label: 'Acknowledge Assignment',
          onPressed: () {
            state.updateIncidentStatus(incident.id, IncidentStatus.enRoute);
          },
        );
    }
  }
}

class _RequestBackupSheet extends StatefulWidget {
  final Incident incident;
  final Function(String type, String note) onSubmitted;

  const _RequestBackupSheet({
    required this.incident,
    required this.onSubmitted,
  });

  @override
  State<_RequestBackupSheet> createState() => _RequestBackupSheetState();
}

class _RequestBackupSheetState extends State<_RequestBackupSheet> {
  String _selectedBackupType = 'Medical Backup';
  final _noteController = TextEditingController(text: 'Additional unit required for crowd management & patient support.');

  @override
  void dispose() {
    _noteController.dispose();
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
              const Icon(PhosphorIconsRegular.shieldPlus, color: RgColors.warning, size: 22),
              const SizedBox(width: 8),
              Text(
                'Request Backup Unit',
                style: RgTypography.headingMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Command Center will dispatch the closest available support personnel.',
            style: RgTypography.bodySmall,
          ),
          const SizedBox(height: 16),

          Text('Select Backup Type:', style: RgTypography.caption.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Medical Backup', 'Security Reinforcement', 'Fire Equipment'].map((type) {
              final isSelected = _selectedBackupType == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSelected,
                selectedColor: RgColors.warningLight,
                labelStyle: TextStyle(
                  color: isSelected ? RgColors.warning : RgColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedBackupType = type);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          Text('Situation Note:', style: RgTypography.caption.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _noteController,
            style: RgTypography.bodyMedium,
            decoration: const InputDecoration(
              hintText: 'Describe backup reason...',
            ),
          ),
          const SizedBox(height: 20),

          PrimaryButton(
            label: 'Send Backup Request',
            icon: PhosphorIconsRegular.broadcast,
            onPressed: () {
              widget.onSubmitted(_selectedBackupType, _noteController.text);
            },
          ),
        ],
      ),
    );
  }
}

class _ResolveIncidentDialog extends StatefulWidget {
  final Incident incident;
  final Function(String outcome, String note) onResolved;

  const _ResolveIncidentDialog({
    required this.incident,
    required this.onResolved,
  });

  @override
  State<_ResolveIncidentDialog> createState() => _ResolveIncidentDialogState();
}

class _ResolveIncidentDialogState extends State<_ResolveIncidentDialog> {
  String _outcome = 'Resolved / Stabilized';
  final _noteController = TextEditingController(text: 'Patient stabilized and transferred to Health Center.');

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(PhosphorIconsRegular.checkCircle, color: RgColors.success, size: 24),
          const SizedBox(width: 8),
          const Text('Resolve Emergency'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select final resolution outcome for incident #${widget.incident.id}:',
            style: RgTypography.bodySmall,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _outcome,
            items: const [
              DropdownMenuItem(value: 'Resolved / Stabilized', child: Text('Resolved / Stabilized')),
              DropdownMenuItem(value: 'Transferred to Hospital', child: Text('Transferred to Hospital')),
              DropdownMenuItem(value: 'False Alarm / Cleared', child: Text('False Alarm / Cleared')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _outcome = val);
            },
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            style: RgTypography.bodyMedium,
            decoration: const InputDecoration(
              labelText: 'Resolution Summary',
              hintText: 'Add closing summary notes...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => widget.onResolved(_outcome, _noteController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: RgColors.success,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm Resolution'),
        ),
      ],
    );
  }
}
