import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/enums.dart';
import '../../data/models/incident.dart';
import '../../data/mock/rescue_grid_state.dart';
import '../../widgets/sos_button.dart';
import '../../widgets/category_tile.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/section_header.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RescueGridState>();
    final activeIncident = state.studentActiveIncident;
    final recentReports = state.incidents.take(2).toList();

    return Scaffold(
      backgroundColor: RgColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Simulated pull-to-refresh
            await Future.delayed(const Duration(milliseconds: 400));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                _buildHeader(context, state),
                const SizedBox(height: 20),

                // Active Incident Banner (if an active emergency exists)
                if (activeIncident != null &&
                    activeIncident.status != IncidentStatus.resolved) ...[
                  _buildActiveIncidentBanner(context, activeIncident),
                  const SizedBox(height: 24),
                ],

                // SOS Hero Section
                Center(
                  child: Column(
                    children: [
                      SosButton(
                        onTrigger: () {
                          // Quick SOS trigger -> opens report pre-populated with medical/unspecified
                          context.push(
                            '/student/report',
                            extra: IncidentCategory.medical,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 1,
                            width: 32,
                            color: RgColors.border,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR SELECT AN EMERGENCY TYPE',
                              style: RgTypography.caption.copyWith(
                                color: RgColors.textMuted,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Container(
                            height: 1,
                            width: 32,
                            color: RgColors.border,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Category Grid (2x3)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                  children: IncidentCategory.values.map((cat) {
                    return CategoryTile(
                      category: cat,
                      onTap: () {
                        context.push(
                          '/student/report',
                          extra: cat,
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Safety Info Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
                    border: Border.all(color: RgColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: RgColors.infoLight,
                        ),
                        child: const Icon(
                          PhosphorIconsRegular.shieldCheck,
                          color: RgColors.info,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your location and contact details are encrypted and shared only with verified assigned responders.',
                          style: RgTypography.caption.copyWith(
                            color: RgColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Recent Reports Section
                SectionHeader(
                  title: 'Recent Reports',
                  actionLabel: 'View all',
                  onAction: () => context.go('/student/reports'),
                ),
                const SizedBox(height: 8),

                if (recentReports.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
                      border: Border.all(color: RgColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'No previous reports on file.',
                        style: RgTypography.bodySmall,
                      ),
                    ),
                  )
                else
                  ...recentReports.map((report) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildRecentReportItem(context, report),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, RescueGridState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good evening,',
              style: RgTypography.caption.copyWith(
                color: RgColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              state.currentUser.name,
              style: RgTypography.headingLarge.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Campus location GPS active chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(RgDimensions.radiusFull),
                border: Border.all(color: RgColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: RgColors.success,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Central Campus',
                    style: RgTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: RgColors.textPrimary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Notification Bell with Badge
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
        ),
      ],
    );
  }

  Widget _buildActiveIncidentBanner(BuildContext context, Incident incident) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/student/tracking/${incident.id}'),
        borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
            border: Border.all(color: incident.severity.color.withOpacity(0.5), width: 1.5),
            boxShadow: RgDimensions.elevatedShadow,
          ),
          child: Column(
            children: [
              // Top colored strip
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: incident.severity.color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: incident.category.color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            incident.category.icon,
                            color: incident.category.color,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'ACTIVE EMERGENCY Â· ${incident.id}',
                                    style: RgTypography.caption.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: incident.severity.color,
                                      letterSpacing: 0.5,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const Spacer(),
                                  StatusBadge(status: incident.status),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                incident.title,
                                style: RgTypography.subheading.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              PhosphorIconsRegular.navigationArrow,
                              size: 15,
                              color: RgColors.primaryAccent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              incident.assignedResponderName != null
                                  ? '${incident.assignedResponderName} is responding'
                                  : 'Dispatching nearest responder...',
                              style: RgTypography.caption.copyWith(
                                color: RgColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Track Live',
                              style: RgTypography.caption.copyWith(
                                color: RgColors.primaryAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Icon(
                              PhosphorIconsRegular.caretRight,
                              size: 14,
                              color: RgColors.primaryAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentReportItem(BuildContext context, Incident report) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/student/tracking/${report.id}'),
        borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
            border: Border.all(color: RgColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: report.category.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  report.category.icon,
                  size: 16,
                  color: report.category.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: RgTypography.subheading.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${report.locationName} Â· ${RgFormatters.timeAgo(report.createdAt)}',
                      style: RgTypography.caption.copyWith(
                        color: RgColors.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: report.status),
            ],
          ),
        ),
      ),
    );
  }
}
