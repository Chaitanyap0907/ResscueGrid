import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/stat_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedRange = 'This Month';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RgColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Campus Safety Analytics',
                style: RgTypography.displayMedium,
              ),
              Text(
                'Aggregated response performance metrics, incident frequencies, and spatial hotspots',
                style: RgTypography.bodySmall,
              ),
              const SizedBox(height: 16),

              // Date Range Chips
              Row(
                children: ['Today', 'This Week', 'This Month', 'Semester'].map((range) {
                  final isSelected = _selectedRange == range;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(range),
                      selected: isSelected,
                      selectedColor: RgColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : RgColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedRange = range);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Top KPI Summary
              Row(
                children: const [
                  Expanded(
                    child: StatCard(
                      label: 'Total Incidents',
                      value: 48,
                      icon: PhosphorIconsRegular.warningOctagon,
                      trendText: '6%',
                      isTrendPositive: true,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Avg Response Time',
                      value: 2.8,
                      suffix: 'm',
                      icon: PhosphorIconsRegular.timer,
                      iconColor: RgColors.success,
                      trendText: '18%',
                      isTrendPositive: true,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Auto-Dispatch Match',
                      value: 94.2,
                      suffix: '%',
                      icon: PhosphorIconsRegular.checkCircle,
                      iconColor: Color(0xFF7A5AF8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Chart 1: Incidents by Category (Bar Chart)
              _buildChartContainer(
                title: 'Incidents by Category',
                subtitle: 'Breakdown of campus reports by emergency domain',
                child: SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 20,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            getTitlesWidget: (val, meta) => Text(
                              val.toInt().toString(),
                              style: const TextStyle(fontSize: 10, color: RgColors.textSecondary),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              const labels = ['Medic', 'Fire', 'Sec', 'Accident', 'Harass', 'Other'];
                              if (val.toInt() >= 0 && val.toInt() < labels.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    labels[val.toInt()],
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        _buildBar(0, 18, RgColors.secondary),
                        _buildBar(1, 6, const Color(0xFFF79009)),
                        _buildBar(2, 12, const Color(0xFF7A5AF8)),
                        _buildBar(3, 8, const Color(0xFFF04438)),
                        _buildBar(4, 4, const Color(0xFFEE46BC)),
                        _buildBar(5, 5, RgColors.primaryAccent),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Chart 2: Response Time Trend (Line Chart)
              _buildChartContainer(
                title: 'Average Response Time Trend (Minutes)',
                subtitle: 'Daily moving average from student report to responder arrival',
                child: SizedBox(
                  height: 170,
                  child: LineChart(
                    LineChartData(
                      minY: 1,
                      maxY: 6,
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            getTitlesWidget: (val, meta) => Text(
                              '${val.toInt()}m',
                              style: const TextStyle(fontSize: 10, color: RgColors.textSecondary),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                              if (val.toInt() >= 0 && val.toInt() < days.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    days[val.toInt()],
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 4.2),
                            FlSpot(1, 3.8),
                            FlSpot(2, 3.1),
                            FlSpot(3, 3.4),
                            FlSpot(4, 2.7),
                            FlSpot(5, 2.9),
                            FlSpot(6, 2.5),
                          ],
                          isCurved: true,
                          color: RgColors.primaryAccent,
                          barWidth: 3.5,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(
                            show: true,
                            color: RgColors.primaryAccent.withOpacity(0.12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Chart 3 & Table: Resolution Outcomes & Top Locations
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildChartContainer(
                      title: 'Resolution Outcomes',
                      subtitle: 'Resolved vs Transferred',
                      child: SizedBox(
                        height: 140,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 32,
                            sections: [
                              PieChartSectionData(
                                value: 72,
                                title: '72%',
                                color: RgColors.success,
                                radius: 28,
                                titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              PieChartSectionData(
                                value: 18,
                                title: '18%',
                                color: RgColors.primaryAccent,
                                radius: 28,
                                titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              PieChartSectionData(
                                value: 10,
                                title: '10%',
                                color: RgColors.warning,
                                radius: 28,
                                titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
                        border: Border.all(color: RgColors.border),
                        boxShadow: RgDimensions.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Top Hotspots', style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('High report locations', style: RgTypography.caption.copyWith(color: RgColors.textMuted)),
                          const SizedBox(height: 12),
                          _buildHotspotRow('Central Library', '14 calls'),
                          _buildHotspotRow('North Quad', '11 calls'),
                          _buildHotspotRow('Science Hall B', '9 calls'),
                          _buildHotspotRow('Sports Complex', '6 calls'),
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
    );
  }

  BarChartGroupData _buildBar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 14,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildChartContainer({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
        border: Border.all(color: RgColors.border),
        boxShadow: RgDimensions.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(subtitle, style: RgTypography.caption.copyWith(color: RgColors.textMuted)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildHotspotRow(String place, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(place, style: RgTypography.caption.copyWith(fontWeight: FontWeight.w600)),
          Text(count, style: RgTypography.caption.copyWith(color: RgColors.primaryAccent, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
