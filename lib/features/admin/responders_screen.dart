import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/dimensions.dart';
import '../../data/models/enums.dart';
import '../../data/models/responder.dart';
import '../../data/mock/rescue_grid_state.dart';
import '../../widgets/responder_card.dart';
import '../../widgets/stat_card.dart';

class RespondersScreen extends StatefulWidget {
  const RespondersScreen({super.key});

  @override
  State<RespondersScreen> createState() => _RespondersScreenState();
}

class _RespondersScreenState extends State<RespondersScreen> {
  ResponderType? _selectedType;
  DutyStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RescueGridState>();
    final responders = state.responders;

    var filtered = responders;
    if (_selectedType != null) {
      filtered = filtered.where((r) => r.type == _selectedType).toList();
    }
    if (_selectedStatus != null) {
      filtered = filtered.where((r) => r.dutyStatus == _selectedStatus).toList();
    }

    final onDutyCount = responders.where((r) => r.dutyStatus == DutyStatus.onDuty).length;
    final totalCapacity = responders.fold<int>(0, (sum, r) => sum + r.maxWorkload);
    final activeLoad = responders.fold<int>(0, (sum, r) => sum + r.currentWorkload);

    return Scaffold(
      backgroundColor: RgColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Title
              Text(
                'Campus Responders Roster',
                style: RgTypography.displayMedium,
              ),
              Text(
                'Live duty tracking, skill certifications, and active incident workloads',
                style: RgTypography.bodySmall,
              ),
              const SizedBox(height: 18),

              // Summary KPI Row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'On Active Duty',
                      value: onDutyCount,
                      suffix: '/${responders.length}',
                      icon: PhosphorIconsRegular.shieldCheck,
                      iconColor: RgColors.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Fleet Workload',
                      value: activeLoad,
                      suffix: '/$totalCapacity calls',
                      icon: PhosphorIconsRegular.pulse,
                      iconColor: RgColors.primaryAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Staff'),
                      selected: _selectedType == null && _selectedStatus == null,
                      onSelected: (_) {
                        setState(() {
                          _selectedType = null;
                          _selectedStatus = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ...ResponderType.values.map((t) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(t.label),
                            selected: _selectedType == t,
                            onSelected: (val) => setState(() => _selectedType = val ? t : null),
                          ),
                        )),
                    const SizedBox(width: 8),
                    ...DutyStatus.values.map((s) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(s.label),
                            selected: _selectedStatus == s,
                            onSelected: (val) => setState(() => _selectedStatus = val ? s : null),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Responders List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final resp = filtered[index];
                  return ResponderCard(
                    responder: resp,
                    onTap: () {
                      _showResponderDetailSheet(context, resp);
                    },
                    onCall: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Direct radio link connecting to ${resp.name}...')),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResponderDetailSheet(BuildContext context, Responder resp) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
              Row(
                children: [
                  Text(
                    resp.name,
                    style: RgTypography.headingMedium,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: resp.dutyStatus.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(RgDimensions.radiusFull),
                    ),
                    child: Text(
                      resp.dutyStatus.label,
                      style: TextStyle(
                        color: resp.dutyStatus.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '${resp.roleTitle} Â· Phone: ${resp.phone}',
                style: RgTypography.caption.copyWith(color: RgColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              Text('Verified Skill Certifications:', style: RgTypography.caption.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: resp.skills.map((s) => Chip(label: Text(s))).toList(),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Responses Completed Today: ${resp.responsesToday}', style: RgTypography.bodyMedium),
                  Text('Avg Time: ${resp.avgResponseTimeMinutes}m', style: RgTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
