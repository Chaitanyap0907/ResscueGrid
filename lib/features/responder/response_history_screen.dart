import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/mock/rescue_grid_state.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/incident_card.dart';

class ResponseHistoryScreen extends StatefulWidget {
  const ResponseHistoryScreen({super.key});

  @override
  State<ResponseHistoryScreen> createState() => _ResponseHistoryScreenState();
}

class _ResponseHistoryScreenState extends State<ResponseHistoryScreen> {
  String _selectedPeriod = 'Today';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RescueGridState>();
    final incidents = state.incidents;

    return Scaffold(
      backgroundColor: RgColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Response Log & History',
                style: RgTypography.displayMedium,
              ),
              Text(
                'Audited dispatch interventions and on-scene response records',
                style: RgTypography.bodySmall,
              ),
              const SizedBox(height: 16),

              // Summary Stats Row
              Row(
                children: const [
                  Expanded(
                    child: StatCard(
                      label: 'Total Completed Calls',
                      value: 14,
                      icon: PhosphorIconsRegular.checkCircle,
                      iconColor: RgColors.success,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Avg Response Time',
                      value: 2.9,
                      suffix: 'm',
                      icon: PhosphorIconsRegular.timer,
                      iconColor: Color(0xFF7A5AF8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Period filter chips
              Row(
                children: ['Today', 'This Week', 'This Month'].map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(period),
                      selected: isSelected,
                      selectedColor: RgColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : RgColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedPeriod = period);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // History list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: incidents.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final incident = incidents[index];
                  return IncidentCard(
                    incident: incident,
                    onTap: () {
                      context.push('/responder/active/${incident.id}');
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
}
