import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/enums.dart';
import '../../data/mock/rescue_grid_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/empty_state.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RescueGridState>();
    final studentName = state.currentUser.name;

    // Filter reports reported by student or overall campus demo reports
    var reports = state.incidents.where((i) {
      if (_selectedFilter == 'Active') {
        return i.status != IncidentStatus.resolved;
      } else if (_selectedFilter == 'Resolved') {
        return i.status == IncidentStatus.resolved;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: RgColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Emergency Reports',
                style: RgTypography.displayMedium,
              ),
              Text(
                'Reports submitted by $studentName and verified response timelines',
                style: RgTypography.bodySmall,
              ),
              const SizedBox(height: 16),

              // Filter Chips
              Row(
                children: ['All', 'Active', 'Resolved'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: RgColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : RgColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              if (reports.isEmpty)
                EmptyState(
                  icon: PhosphorIconsRegular.shieldCheck,
                  title: 'No Reports Found',
                  message: 'You have not submitted any reports in the "$_selectedFilter" category.',
                  buttonLabel: 'Report Emergency',
                  onButtonPressed: () => context.push('/student/report'),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reports.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return IncidentCard(
                      incident: report,
                      onTap: () {
                        context.push('/student/tracking/${report.id}');
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
