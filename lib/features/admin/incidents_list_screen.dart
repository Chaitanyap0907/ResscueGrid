import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/enums.dart';
import '../../data/mock/rescue_grid_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/rg_text_field.dart';
import 'incident_detail_sheet.dart';

class IncidentsListScreen extends StatefulWidget {
  const IncidentsListScreen({super.key});

  @override
  State<IncidentsListScreen> createState() => _IncidentsListScreenState();
}

class _IncidentsListScreenState extends State<IncidentsListScreen> {
  String _searchQuery = '';
  IncidentStatus? _selectedStatus;
  IncidentCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RescueGridState>();
    final incidents = state.incidents;

    var filtered = incidents.where((i) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = i.id.toLowerCase().contains(q) ||
            i.title.toLowerCase().contains(q) ||
            i.locationName.toLowerCase().contains(q);
        if (!match) return false;
      }
      if (_selectedStatus != null && i.status != _selectedStatus) {
        return false;
      }
      if (_selectedCategory != null && i.category != _selectedCategory) {
        return false;
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
                'Campus Incident Logs',
                style: RgTypography.displayMedium,
              ),
              Text(
                'Complete historical and active emergency dispatch events',
                style: RgTypography.bodySmall,
              ),
              const SizedBox(height: 16),

              // Search field
              RgTextField(
                label: 'Search Incidents',
                hint: 'Search by ID (#RG-2041), title, or location...',
                prefixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass, size: 20),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              const SizedBox(height: 14),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedStatus == null && _selectedCategory == null,
                      onSelected: (_) {
                        setState(() {
                          _selectedStatus = null;
                          _selectedCategory = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ...IncidentStatus.values.map((s) => Padding(
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

              // Incident Cards
              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No incidents match the selected search or filter criteria.',
                      style: RgTypography.bodySmall,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final inc = filtered[index];
                    return IncidentCard(
                      incident: inc,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => IncidentDetailSheet(incident: inc),
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
}
