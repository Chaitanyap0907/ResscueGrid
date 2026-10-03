import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/dimensions.dart';
import '../../data/models/enums.dart';
import '../../data/models/incident.dart';
import '../../data/mock/rescue_grid_state.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/info_banner.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/campus_map_panel.dart';
import '../../widgets/user_avatar.dart';
import 'incident_detail_sheet.dart';

class CommandCenterScreen extends StatefulWidget {
  const CommandCenterScreen({super.key});

  @override
  State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen> {
  late Timer _clockTimer;
  String _currentTime = '';
  IncidentSeverity? _selectedSeverityFilter;
  Incident? _selectedIncident;
  bool _mobileShowMap = true;

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateClock();
    });
  }

  void _updateClock() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  void _openIncidentDetail(Incident incident) {
    setState(() => _selectedIncident = incident);
    final isWide = MediaQuery.of(context).size.width >= RgDimensions.mobileBreakpoint;

    if (!isWide) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => IncidentDetailSheet(incident: incident),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RescueGridState>();
    final isWide = MediaQuery.of(context).size.width >= RgDimensions.mobileBreakpoint;
    final incidents = state.incidents;
    final responders = state.responders;

    // Filter incidents
    var filteredIncidents = incidents;
    if (_selectedSeverityFilter != null) {
      filteredIncidents = filteredIncidents
          .where((i) => i.severity == _selectedSeverityFilter)
          .toList();
    }

    final activeCount = incidents.where((i) => i.status != IncidentStatus.resolved).length;
    final criticalCount = incidents.where((i) => i.severity == IncidentSeverity.critical && i.status != IncidentStatus.resolved).length;
    final escalatedIncident = incidents.where((i) => i.isEscalated).firstOrNull;
    final availableRespondersCount = responders.where((r) => r.dutyStatus == DutyStatus.onDuty).length;

    return Scaffold(
      backgroundColor: RgColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Control Room Top Bar
            _buildTopBar(context, state),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPI Strip (5 cards)
                    _buildKpiRow(
                      activeCount: activeCount,
                      criticalCount: criticalCount,
                      escalatedCount: escalatedIncident != null ? 1 : 0,
                      availableResponders: availableRespondersCount,
                      isWide: isWide,
                    ),
                    const SizedBox(height: 16),

                    // Escalation Alert Banner (Slide-down amber)
                    if (escalatedIncident != null) ...[
                      InfoBanner(
                        title: 'ESCALATION ALERT Â· REQUIRES MANUAL OVERRIDE',
                        message:
                            'Incident #${escalatedIncident.id} (${escalatedIncident.title}) was unaccepted after 30s. Click to assign available unit.',
                        type: BannerType.warning,
                        actionLabel: 'Assign Now',
                        onAction: () => _openIncidentDetail(escalatedIncident),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Filter chips row
                    _buildFiltersRow(),
                    const SizedBox(height: 16),

                    // Main Operational Layout (Desktop Split 60/40 vs Mobile Toggle)
                    if (isWide)
                      _buildDesktopSplitView(state, filteredIncidents)
                    else
                      _buildMobileOperationalView(state, filteredIncidents),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, RescueGridState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: RgColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: RgColors.success,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'COMMAND CENTER',
                style: RgTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: RgColors.primary,
                ),
              ),
              Text(
                'Central Campus Dispatch Grid',
                style: RgTypography.caption.copyWith(
                  color: RgColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Live Clock Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: RgColors.surfaceMuted,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: RgColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  PhosphorIconsRegular.clock,
                  size: 14,
                  color: RgColors.primaryAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  _currentTime,
                  style: RgTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: RgColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          UserAvatar(
            initials: state.currentUser.initials,
            size: 36,
            backgroundColor: RgColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow({
    required int activeCount,
    required int criticalCount,
    required int escalatedCount,
    required int availableResponders,
    required bool isWide,
  }) {
    final cards = [
      StatCard(
        label: 'Active Incidents',
        value: activeCount,
        icon: PhosphorIconsRegular.pulse,
        iconColor: RgColors.primaryAccent,
      ),
      StatCard(
        label: 'Critical Priority',
        value: criticalCount,
        icon: PhosphorIconsRegular.warningOctagon,
        iconColor: RgColors.secondary,
        isWarning: criticalCount > 0,
      ),
      StatCard(
        label: 'Escalated / Override',
        value: escalatedCount,
        icon: PhosphorIconsRegular.warning,
        iconColor: RgColors.warning,
        isWarning: escalatedCount > 0,
      ),
      StatCard(
        label: 'Responders On Duty',
        value: availableResponders,
        suffix: '/6',
        icon: PhosphorIconsRegular.shieldCheck,
        iconColor: RgColors.success,
      ),
      const StatCard(
        label: 'Avg Response Time',
        value: 3.1,
        suffix: 'm',
        icon: PhosphorIconsRegular.timer,
        iconColor: Color(0xFF7A5AF8),
        trendText: '14%',
      ),
    ];

    if (isWide) {
      return Row(
        children: cards
            .map((c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: c,
                  ),
                ))
            .toList(),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) => SizedBox(width: 160, child: cards[index]),
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Row(
      children: [
        Text(
          'Filter Severity:',
          style: RgTypography.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: RgColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('All'),
          selected: _selectedSeverityFilter == null,
          onSelected: (_) => setState(() => _selectedSeverityFilter = null),
          selectedColor: RgColors.primaryLight,
          labelStyle: RgTypography.caption.copyWith(
            fontWeight: _selectedSeverityFilter == null ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        ...IncidentSeverity.values.map((sev) {
          final isSelected = _selectedSeverityFilter == sev;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(sev.label),
              selected: isSelected,
              selectedColor: sev.bgColor,
              side: BorderSide(color: sev.color.withOpacity(isSelected ? 0.8 : 0.3)),
              labelStyle: RgTypography.caption.copyWith(
                color: isSelected ? sev.color : RgColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
              onSelected: (val) {
                setState(() => _selectedSeverityFilter = val ? sev : null);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDesktopSplitView(
    RescueGridState state,
    List<Incident> filteredIncidents,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left 60%: Interactive Map Panel
        Expanded(
          flex: 6,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
              border: Border.all(color: RgColors.border),
              boxShadow: RgDimensions.cardShadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsRegular.mapTrifold, size: 18, color: RgColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Live Campus Grid & Deployed Units',
                        style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Text(
                        'Click pin to inspect',
                        style: RgTypography.caption.copyWith(color: RgColors.textMuted),
                      ),
                    ],
                  ),
                ),
                CampusMapPanel(
                  height: 520,
                  allIncidents: filteredIncidents,
                  allResponders: state.responders,
                  activeIncident: _selectedIncident,
                  onIncidentTap: _openIncidentDetail,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),

        // Right 40%: Live Feed or Selected Incident Detail
        Expanded(
          flex: 4,
          child: _selectedIncident != null
              ? IncidentDetailSheet(
                  incident: _selectedIncident!,
                  isDrawerMode: true,
                  onClose: () => setState(() => _selectedIncident = null),
                )
              : _buildLiveIncidentFeed(filteredIncidents),
        ),
      ],
    );
  }

  Widget _buildMobileOperationalView(
    RescueGridState state,
    List<Incident> filteredIncidents,
  ) {
    return Column(
      children: [
        // Segmented toggle: Map vs List
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: RgColors.surfaceMuted,
            borderRadius: BorderRadius.circular(RgDimensions.radiusButton),
            border: Border.all(color: RgColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _mobileShowMap = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _mobileShowMap ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _mobileShowMap ? RgDimensions.cardShadow : const [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Campus Map View',
                      style: RgTypography.caption.copyWith(
                        fontWeight: _mobileShowMap ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _mobileShowMap = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !_mobileShowMap ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: !_mobileShowMap ? RgDimensions.cardShadow : const [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Live Incident Feed (${filteredIncidents.length})',
                      style: RgTypography.caption.copyWith(
                        fontWeight: !_mobileShowMap ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (_mobileShowMap)
          CampusMapPanel(
            height: 380,
            allIncidents: filteredIncidents,
            allResponders: state.responders,
            activeIncident: _selectedIncident,
            onIncidentTap: _openIncidentDetail,
          )
        else
          _buildLiveIncidentFeed(filteredIncidents),
      ],
    );
  }

  Widget _buildLiveIncidentFeed(List<Incident> incidents) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
        border: Border.all(color: RgColors.border),
        boxShadow: RgDimensions.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                PhosphorIconsRegular.broadcast,
                size: 18,
                color: RgColors.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Live Incident Feed',
                style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: RgColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${incidents.length} Active',
                  style: RgTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: RgColors.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: incidents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final incident = incidents[index];
              return IncidentCard(
                incident: incident,
                compact: true,
                onTap: () => _openIncidentDetail(incident),
              );
            },
          ),
        ],
      ),
    );
  }
}
