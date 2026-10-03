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
import '../../widgets/status_badge.dart';
import '../../widgets/incident_stepper.dart';
import '../../widgets/timeline_view.dart';
import '../../widgets/campus_map_panel.dart';
import '../../widgets/radar_sweep.dart';
import '../../widgets/user_avatar.dart';

class IncidentTrackingScreen extends StatefulWidget {
  final String? incidentId;

  const IncidentTrackingScreen({
    super.key,
    this.incidentId,
  });

  @override
  State<IncidentTrackingScreen> createState() => _IncidentTrackingScreenState();
}

class _IncidentTrackingScreenState extends State<IncidentTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<RescueGridState>();
    final incident = state.incidents.firstWhere(
      (i) => i.id == (widget.incidentId ?? 'RG-2041'),
      orElse: () => state.incidents.first,
    );

    final responder = state.responders.firstWhere(
      (r) => r.id == incident.assignedResponderId,
      orElse: () => state.responders.first,
    );

    final isSearching = incident.status == IncidentStatus.reported;
    final isResolved = incident.status == IncidentStatus.resolved;

    final routePoints = MockData.demoRouteCoordinates
        .map((coord) => LatLng(coord[0], coord[1]))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Top Map Area (about 38% height)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.42,
            child: CampusMapPanel(
              height: MediaQuery.of(context).size.height * 0.42,
              activeIncident: incident,
              activeResponder: isSearching ? null : responder,
              routePolyline: isSearching ? null : routePoints,
              showFloatingEta: !isSearching && !isResolved,
            ),
          ),

          // Top Header Buttons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: RgDimensions.cardShadow,
                      ),
                      child: IconButton(
                        icon: const Icon(PhosphorIconsRegular.arrowLeft, size: 22),
                        onPressed: () => context.go('/student'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(RgDimensions.radiusFull),
                        boxShadow: RgDimensions.cardShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: incident.status.color,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'LIVE TRACKING Â· ${incident.id}',
                            style: RgTypography.caption.copyWith(
                              fontWeight: FontWeight.w800,
                              color: RgColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Draggable Bottom Sheet with Snapping
          DraggableScrollableSheet(
            initialChildSize: 0.62,
            minChildSize: 0.58,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 20,
                      offset: Offset(0, -6),
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

                    // Status Header
                    Row(
                      children: [
                        Text(
                          incident.id,
                          style: RgTypography.headingMedium.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 8),
                        SeverityBadge(severity: incident.severity),
                        const SizedBox(width: 6),
                        StatusBadge(status: incident.status),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Horizontal Stepper
                    IncidentStepper(currentStatus: incident.status),
                    const SizedBox(height: 16),

                    // Searching State: Radar Sweep + Shimmer
                    if (isSearching) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: RgColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
                          border: Border.all(color: RgColors.border),
                        ),
                        child: Column(
                          children: [
                            const RadarSweep(size: 90),
                            const SizedBox(height: 14),
                            Text(
                              'Finding the nearest responder...',
                              style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Dispatch engine is scoring proximity, skill certification and current workloads.',
                              style: RgTypography.caption.copyWith(color: RgColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else if (isResolved) ...[
                      // Resolved Summary State
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: RgColors.successLight,
                          borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
                          border: Border.all(color: RgColors.success.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(PhosphorIconsRegular.checkCircle, color: RgColors.success, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Incident Resolved',
                                    style: RgTypography.subheading.copyWith(
                                      color: RgColors.success,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Campus responders have stabilized the scene. Stay safe!',
                                    style: RgTypography.caption.copyWith(color: RgColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      // Assigned Responder Card
                      _buildAssignedResponderCard(context, incident, responder),
                      const SizedBox(height: 16),
                    ],

                    // Incident Summary Card
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
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: incident.category.color.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(incident.category.icon, color: incident.category.color, size: 16),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  incident.title,
                                  style: RgTypography.subheading.copyWith(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            incident.description,
                            style: RgTypography.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(PhosphorIconsRegular.mapPin, size: 14, color: RgColors.textSecondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${incident.locationName} (${incident.locationDetail})',
                                  style: RgTypography.caption.copyWith(color: RgColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                          if (incident.photoBytes != null || incident.photoAsset != null) ...[
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: incident.photoBytes != null
                                      ? Image.memory(
                                          incident.photoBytes!,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          incident.photoAsset!,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 56,
                                            height: 56,
                                            color: RgColors.surfaceMuted,
                                            child: const Icon(PhosphorIconsRegular.image, size: 24),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Photo Evidence Attached',
                                        style: RgTypography.caption.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        incident.photoBytes != null
                                            ? 'Uploaded from device local storage'
                                            : 'Simulated dispatch evidence',
                                        style: RgTypography.caption.copyWith(
                                          color: RgColors.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Timeline
                    Text(
                      'Incident Timeline',
                      style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TimelineView(
                      events: incident.timeline,
                      shrinkWrap: true,
                    ),

                    const SizedBox(height: 12),
                    // Cancel button
                    if (!isResolved)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            state.updateIncidentStatus(incident.id, IncidentStatus.resolved);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Report cancelled as false alarm.')),
                            );
                          },
                          child: Text(
                            'Cancel report / False alarm',
                            style: RgTypography.caption.copyWith(color: RgColors.textMuted),
                          ),
                        ),
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

  Widget _buildAssignedResponderCard(
    BuildContext context,
    Incident incident,
    dynamic responder,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
        border: Border.all(color: RgColors.border),
        boxShadow: RgDimensions.cardShadow,
      ),
      child: Row(
        children: [
          UserAvatar(
            initials: incident.assignedResponderName != null
                ? incident.assignedResponderName![0]
                : 'M',
            size: 44,
            backgroundColor: RgColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incident.assignedResponderName ?? 'Assigned Medic',
                  style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  incident.assignedResponderRole ?? 'Campus Safety Responder',
                  style: RgTypography.caption.copyWith(color: RgColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: const [
                    _MiniBadge(label: 'BLS / ACLS'),
                    _MiniBadge(label: 'Triage Lead'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.phoneCall, color: RgColors.primaryAccent),
            style: IconButton.styleFrom(
              backgroundColor: RgColors.primaryLight,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Connecting to ${incident.assignedResponderName}...'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  const _MiniBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: RgColors.surfaceMuted,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: RgColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: RgColors.textSecondary),
      ),
    );
  }
}
