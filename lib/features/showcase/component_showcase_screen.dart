import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/dimensions.dart';
import '../../data/models/enums.dart';
import '../../data/mock/rescue_grid_state.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/outline_action_button.dart';
import '../../widgets/sos_button.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/severity_badge.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/rg_text_field.dart';
import '../../widgets/rg_app_bar.dart';
import '../../widgets/section_header.dart';
import '../../widgets/category_tile.dart';
import '../../widgets/duty_toggle_card.dart';
import '../../widgets/countdown_ring.dart';
import '../../widgets/info_banner.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/incident_stepper.dart';
import '../../widgets/radar_sweep.dart';
import '../../widgets/campus_map_panel.dart';

class ComponentShowcaseScreen extends StatefulWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  State<ComponentShowcaseScreen> createState() => _ComponentShowcaseScreenState();
}

class _ComponentShowcaseScreenState extends State<ComponentShowcaseScreen> {
  DutyStatus _dutyStatus = DutyStatus.onDuty;
  IncidentStatus _stepperStatus = IncidentStatus.enRoute;
  IncidentCategory _selectedCategory = IncidentCategory.medical;
  int _sosTriggerCount = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RescueGridState>();
    final sampleIncident = state.incidents.first;

    return Scaffold(
      appBar: const RgAppBar(
        title: 'Design System & Component Showcase',
        subtitle: 'Tokens, Atoms, Micro-interactions',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Section: Brand & Calm Authority Tokens
          const SectionHeader(
            title: '1. Brand Palette & Color Scale',
            subtitle: 'Calm authority navy base; red reserved for SOS/critical only',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildColorSwatch('Primary Navy', RgColors.primary),
              _buildColorSwatch('Accent Blue', RgColors.primaryAccent),
              _buildColorSwatch('SOS Red', RgColors.secondary),
              _buildColorSwatch('Success', RgColors.success),
              _buildColorSwatch('Warning', RgColors.warning),
              _buildColorSwatch('Surface Muted', RgColors.surfaceMuted, isLight: true),
            ],
          ),
          const SizedBox(height: 28),

          // Section: Badges & Statuses
          const SectionHeader(
            title: '2. Status & Severity Badges',
            subtitle: 'Never color alone; always paired with icon and label',
          ),
          const SizedBox(height: 12),
          Text('Severity Scale:', style: RgTypography.caption.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              SeverityBadge(severity: IncidentSeverity.low),
              SeverityBadge(severity: IncidentSeverity.medium),
              SeverityBadge(severity: IncidentSeverity.high),
              SeverityBadge(severity: IncidentSeverity.critical),
              SeverityBadge(severity: IncidentSeverity.critical, isFilled: true),
            ],
          ),
          const SizedBox(height: 16),
          Text('Lifecycle Statuses:', style: RgTypography.caption.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              StatusBadge(status: IncidentStatus.reported),
              StatusBadge(status: IncidentStatus.assigned),
              StatusBadge(status: IncidentStatus.enRoute),
              StatusBadge(status: IncidentStatus.arrived),
              StatusBadge(status: IncidentStatus.resolved),
              StatusBadge(status: IncidentStatus.escalated),
            ],
          ),
          const SizedBox(height: 28),

          // Section: SOS Button with Pulse and Hold Progress
          const SectionHeader(
            title: '3. SOS Hero & Radar Sweep',
            subtitle: '168px circular button, soft pulse rings, 1.5s hold progress, haptics',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
              border: Border.all(color: RgColors.border),
              boxShadow: RgDimensions.cardShadow,
            ),
            child: Column(
              children: [
                SosButton(
                  onTrigger: () {
                    setState(() => _sosTriggerCount++);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('SOS Triggered! Count: $_sosTriggerCount'),
                        backgroundColor: RgColors.secondary,
                      ),
                    );
                  },
                ),
                if (_sosTriggerCount > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'SOS Activation successfully confirmed ($_sosTriggerCount times)',
                    style: RgTypography.caption.copyWith(
                      color: RgColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const RadarSweep(size: 110),
                  const SizedBox(height: 8),
                  Text('Radar Sweep (Awaiting)', style: RgTypography.caption),
                ],
              ),
              Column(
                children: [
                  CountdownRing(
                    durationSeconds: 30,
                    size: 90,
                    onExpired: () {},
                  ),
                  const SizedBox(height: 8),
                  Text('30s Countdown Ring', style: RgTypography.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Section: KPI & Stat Cards
          const SectionHeader(
            title: '4. KPI & Stat Cards with Count-up',
            subtitle: 'Tabular figures, animated count-up and trend chip',
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: StatCard(
                  label: 'Active Incidents',
                  value: 4,
                  icon: PhosphorIconsRegular.warningOctagon,
                  trendText: '12%',
                  isTrendPositive: false,
                  isWarning: true,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Avg Response Time',
                  value: 3.4,
                  suffix: 'm',
                  icon: PhosphorIconsRegular.clockCountdown,
                  trendText: '8%',
                  isTrendPositive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Section: Buttons & Inputs
          const SectionHeader(
            title: '5. Buttons & Form Fields',
            subtitle: '52px height, 14px radius, focused blue rings',
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Primary Navy Button',
            icon: PhosphorIconsRegular.shieldCheck,
            onPressed: () {},
          ),
          const SizedBox(height: 10),
          OutlineActionButton(
            label: 'Secondary Outlined Action',
            icon: PhosphorIconsRegular.phoneCall,
            onPressed: () {},
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Critical Alert Action',
            isDestructive: true,
            icon: PhosphorIconsRegular.bellRinging,
            onPressed: () {},
          ),
          const SizedBox(height: 14),
          const RgTextField(
            label: 'Emergency Location Description',
            hint: 'e.g., Near water fountain on 2nd floor',
          ),
          const SizedBox(height: 28),

          // Section: Category Selection
          const SectionHeader(
            title: '6. Category Grid & Chips',
            subtitle: 'Tinted containers and active selection states',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: IncidentCategory.values.map((cat) {
              return CategoryChip(
                category: cat,
                isSelected: _selectedCategory == cat,
                onTap: () => setState(() => _selectedCategory = cat),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Section: Duty Toggle Card
          const SectionHeader(
            title: '7. Responder Duty Toggle Card',
            subtitle: 'Live duty control with GPS status dot and shift tracker',
          ),
          const SizedBox(height: 12),
          DutyToggleCard(
            currentStatus: _dutyStatus,
            onStatusChanged: (status) => setState(() => _dutyStatus = status),
          ),
          const SizedBox(height: 28),

          // Section: Incident Stepper & Cards
          const SectionHeader(
            title: '8. Incident Lifecycle Stepper & Card',
            subtitle: 'Animated horizontal status transitions & severity left edge',
          ),
          const SizedBox(height: 12),
          IncidentStepper(currentStatus: _stepperStatus),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  final nextIndex = (_stepperStatus.stepIndex + 1) % 5;
                  setState(() => _stepperStatus = IncidentStatus.values[nextIndex]);
                },
                child: const Text('Next Step (Test animation)'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          IncidentCard(
            incident: sampleIncident,
            onTap: () {},
          ),
          const SizedBox(height: 28),

          // Section: Banners
          const SectionHeader(
            title: '9. Informational & Escalation Banners',
          ),
          const SizedBox(height: 12),
          InfoBanner(
            title: 'ESCALATION ALERT',
            message: 'Incident #RG-2039 was not accepted within 30s. Manual override required.',
            type: BannerType.warning,
            actionLabel: 'Assign Now',
            onAction: () {},
          ),
          const SizedBox(height: 28),

          // Section: Map Panel
          const SectionHeader(
            title: '10. Interactive Map Panel & Fallback',
            subtitle: 'Online OSM tiles + stylised campus vector fallback',
          ),
          const SizedBox(height: 12),
          CampusMapPanel(
            activeIncident: sampleIncident,
            activeResponder: state.responders.first,
            height: 220,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(String name, Color color, {bool isLight = false}) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: RgColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: isLight ? Border.all(color: RgColors.border) : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: RgTypography.caption.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
