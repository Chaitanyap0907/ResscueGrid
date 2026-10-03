import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/constants/dimensions.dart';
import '../data/models/enums.dart';

class DutyToggleCard extends StatelessWidget {
  final DutyStatus currentStatus;
  final ValueChanged<DutyStatus> onStatusChanged;
  final String shiftDuration;
  final bool isGpsActive;

  const DutyToggleCard({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
    this.shiftDuration = '3h 24m active',
    this.isGpsActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
        border: Border.all(color: RgColors.border, width: 1),
        boxShadow: RgDimensions.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentStatus.color,
                      boxShadow: [
                        BoxShadow(
                          color: currentStatus.color.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DUTY STATUS',
                    style: RgTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: RgColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.navigationArrow,
                    size: 13,
                    color: isGpsActive ? RgColors.success : RgColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isGpsActive ? 'Live GPS Active' : 'GPS Offline',
                    style: RgTypography.caption.copyWith(
                      fontSize: 11,
                      color: isGpsActive ? RgColors.success : RgColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 3-way segmented control
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: RgColors.surfaceMuted,
              borderRadius: BorderRadius.circular(RgDimensions.radiusButton),
              border: Border.all(color: RgColors.border, width: 1),
            ),
            child: Row(
              children: [
                _buildSegment(
                  status: DutyStatus.onDuty,
                  label: 'On Duty',
                  icon: PhosphorIconsRegular.shieldCheck,
                  activeColor: RgColors.success,
                ),
                _buildSegment(
                  status: DutyStatus.breakTime,
                  label: 'Break',
                  icon: PhosphorIconsRegular.coffee,
                  activeColor: RgColors.warning,
                ),
                _buildSegment(
                  status: DutyStatus.offDuty,
                  label: 'Off Duty',
                  icon: PhosphorIconsRegular.power,
                  activeColor: RgColors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shift started at 08:30 AM',
                style: RgTypography.caption.copyWith(
                  color: RgColors.textSecondary,
                  fontSize: 11.5,
                ),
              ),
              Text(
                shiftDuration,
                style: RgTypography.caption.copyWith(
                  color: RgColors.primaryAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required DutyStatus status,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = currentStatus == status;

    return Expanded(
      child: GestureDetector(
        onTap: () => onStatusChanged(status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(RgDimensions.radiusSmall),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: Color(0x10101828),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? activeColor : RgColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: RgTypography.caption.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? RgColors.textPrimary : RgColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
