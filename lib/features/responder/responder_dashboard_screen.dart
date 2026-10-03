import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/dimensions.dart';
import '../../data/models/enums.dart';
import '../../data/models/incident.dart';
import '../../data/mock/rescue_grid_state.dart';
import '../../widgets/duty_toggle_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/radar_sweep.dart';
import '../../widgets/section_header.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/user_avatar.dart';

class ResponderDashboardScreen extends StatelessWidget {
  const ResponderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RescueGridState>();
    final user = state.currentUser;
    final dutyStatus = state.responderDutyStatus;
    final isOffDuty = dutyStatus == DutyStatus.offDuty;
    final isOnBreak = dutyStatus == DutyStatus.breakTime;
    final activeIncident = state.responderActiveIncident;
    final queueIncidents = state.incidents.where((i) => i.id != activeIncident?.id).take(2).toList();

    return Scaffold(
      backgroundColor: RgColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Row
              _buildHeader(context, state, user),
              const SizedBox(height: 18),

              // Duty Toggle Card
              DutyToggleCard(
                currentStatus: dutyStatus,
                onStatusChanged: (newStatus) {
                  state.toggleDutyStatus(newStatus);
                },
              ),
              const SizedBox(height: 20),

              // Off-duty or On-break warning banner if applicable
              if (isOffDuty)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: RgColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
                    border: Border.all(color: RgColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsRegular.power, color: RgColors.textMuted, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You are currently OFF DUTY. Emergency dispatch notifications are paused.',
                          style: RgTypography.caption.copyWith(
                            color: RgColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (isOnBreak)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: RgColors.warningLight,
                    borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
                    border: Border.all(color: RgColors.warning.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsRegular.coffee, color: RgColors.warning, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'On 15-min break. Only Critical-level priority calls will ping your unit.',
                          style: RgTypography.caption.copyWith(
                            color: RgColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Stat row (3 KPI cards)
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Active Workload',
                      value: activeIncident != null ? 1 : 0,
                      suffix: '/3',
                      icon: PhosphorIconsRegular.pulse,
                      iconColor: RgColors.primaryAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: StatCard(
                      label: 'Responded Today',
                      value: 5,
                      icon: PhosphorIconsRegular.checkCircle,
                      iconColor: RgColors.success,
                      trendText: '20%',
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: StatCard(
                      label: 'Avg Response',
                      value: 3.2,
                      suffix: 'm',
                      icon: PhosphorIconsRegular.timer,
                      iconColor: Color(0xFF7A5AF8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Current Assignment or Awaiting State
              SectionHeader(
                title: 'Current Assignment',
                trailing: TextButton.icon(
                  icon: const Icon(PhosphorIconsRegular.bellRinging, size: 14),
                  label: const Text('Simulate Incoming'),
                  onPressed: () {
                    // Trigger Incoming Assignment modal screen for demo flow
                    context.push('/responder/incoming');
                  },
                ),
              ),
              const SizedBox(height: 8),

              if (activeIncident != null && !isOffDuty)
                _buildActiveAssignmentCard(context, activeIncident)
              else
                _buildAwaitingAssignmentsCard(context),

              const SizedBox(height: 24),

              // Nearby Incidents Queue
              SectionHeader(
                title: 'Campus Incidents Feed',
                actionLabel: 'View all',
                onAction: () => context.go('/responder/history'),
              ),
              const SizedBox(height: 8),

              ...queueIncidents.map((incident) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: IncidentCard(
                      incident: incident,
                      onTap: () {
                        context.push('/responder/active/${incident.id}');
                      },
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, RescueGridState state, dynamic user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            UserAvatar(
              initials: user.initials,
              size: 46,
              backgroundColor: RgColors.primary,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: RgTypography.headingMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.roleTitle ?? 'Campus Safety Responder',
                  style: RgTypography.caption.copyWith(
                    color: RgColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(PhosphorIconsRegular.bell, size: 22),
              onPressed: () => context.go('/notifications'),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: RgColors.border),
              ),
            ),
            if (state.unreadNotificationCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: RgColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveAssignmentCard(BuildContext context, Incident incident) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
        border: Border.all(color: incident.severity.color.withOpacity(0.6), width: 1.5),
        boxShadow: RgDimensions.elevatedShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
        child: Column(
          children: [
            Container(
              height: 4,
              color: incident.severity.color,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: incident.severity.bgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          incident.severity.label,
                          style: RgTypography.badgeLabel.copyWith(
                            color: incident.severity.color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        incident.id,
                        style: RgTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: RgColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'ETA: ${incident.responderEtaMinutes} min',
                        style: RgTypography.caption.copyWith(
                          color: RgColors.primaryAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    incident.title,
                    style: RgTypography.subheading.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${incident.locationName} Â· ${incident.locationDetail}',
                    style: RgTypography.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: 'Open Navigation & Route',
                          icon: PhosphorIconsRegular.navigationArrow,
                          height: 44,
                          onPressed: () {
                            context.push('/responder/active/${incident.id}');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAwaitingAssignmentsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
        border: Border.all(color: RgColors.border),
        boxShadow: RgDimensions.cardShadow,
      ),
      child: Column(
        children: [
          const RadarSweep(
            size: 110,
            color: RgColors.primaryAccent,
            centerChild: Icon(
              PhosphorIconsFill.shieldCheck,
              color: RgColors.primaryAccent,
              size: 26,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Awaiting Dispatch Assignments',
            style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Dispatch engine is monitoring campus zones. You will receive an audio-visual alert when prioritized.',
            style: RgTypography.bodySmall.copyWith(color: RgColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
