import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../data/models/enums.dart';

class IncidentStepper extends StatelessWidget {
  final IncidentStatus currentStatus;

  const IncidentStepper({
    super.key,
    required this.currentStatus,
  });

  static const List<IncidentStatus> steps = [
    IncidentStatus.reported,
    IncidentStatus.assigned,
    IncidentStatus.enRoute,
    IncidentStatus.arrived,
    IncidentStatus.resolved,
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = currentStatus.stepIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            Expanded(
              child: _buildStepItem(
                step: steps[i],
                index: i,
                activeIndex: activeIndex,
                isLast: i == steps.length - 1,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required IncidentStatus step,
    required int index,
    required int activeIndex,
    required bool isLast,
  }) {
    final isPassed = index < activeIndex;
    final isCurrent = index == activeIndex;

    Color stepColor;
    if (isCurrent) {
      stepColor = RgColors.primaryAccent;
    } else if (isPassed) {
      stepColor = RgColors.success;
    } else {
      stepColor = const Color(0xFFD0D5DD);
    }

    IconData stepIcon;
    switch (step) {
      case IncidentStatus.reported:
        stepIcon = PhosphorIconsRegular.paperPlaneTilt;
        break;
      case IncidentStatus.assigned:
        stepIcon = PhosphorIconsRegular.userCheck;
        break;
      case IncidentStatus.enRoute:
        stepIcon = PhosphorIconsRegular.navigationArrow;
        break;
      case IncidentStatus.arrived:
        stepIcon = PhosphorIconsRegular.mapPin;
        break;
      case IncidentStatus.resolved:
        stepIcon = PhosphorIconsRegular.check;
        break;
      default:
        stepIcon = PhosphorIconsRegular.circle;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Left connecting line
            Expanded(
              child: Container(
                height: 3,
                color: index == 0
                    ? Colors.transparent
                    : (index <= activeIndex ? RgColors.success : const Color(0xFFE4E7EC)),
              ),
            ),

            // Step circle node with animated glow if current
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? RgColors.primaryAccent
                    : (isPassed ? RgColors.success : Colors.white),
                border: Border.all(
                  color: stepColor,
                  width: isCurrent ? 2.5 : 2,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: RgColors.primaryAccent.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : const [],
              ),
              child: Center(
                child: Icon(
                  isPassed ? PhosphorIconsBold.check : stepIcon,
                  size: 15,
                  color: (isPassed || isCurrent) ? Colors.white : const Color(0xFF98A2B3),
                ),
              ),
            ),

            // Right connecting line
            Expanded(
              child: Container(
                height: 3,
                color: isLast
                    ? Colors.transparent
                    : (index < activeIndex ? RgColors.success : const Color(0xFFE4E7EC)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          step.label,
          style: RgTypography.caption.copyWith(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent
                ? RgColors.primaryAccent
                : (isPassed ? RgColors.textPrimary : RgColors.textMuted),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ],
    );
  }
}
