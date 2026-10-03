import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/constants/dimensions.dart';
import '../data/models/responder.dart';
import 'user_avatar.dart';

class ResponderCard extends StatelessWidget {
  final Responder responder;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final bool showWorkload;
  final bool isSelected;

  const ResponderCard({
    super.key,
    required this.responder,
    this.onTap,
    this.onCall,
    this.showWorkload = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
            border: Border.all(
              color: isSelected ? RgColors.primaryAccent : RgColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? RgDimensions.elevatedShadow : RgDimensions.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      UserAvatar(
                        initials: responder.initials,
                        size: 46,
                        backgroundColor: Color(responder.avatarColorValue),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: responder.dutyStatus.color,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          responder.name,
                          style: RgTypography.subheading.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          responder.roleTitle,
                          style: RgTypography.caption.copyWith(
                            color: RgColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (onCall != null)
                    IconButton(
                      icon: const Icon(
                        PhosphorIconsRegular.phoneCall,
                        color: RgColors.primaryAccent,
                        size: 20,
                      ),
                      onPressed: onCall,
                      style: IconButton.styleFrom(
                        backgroundColor: RgColors.primaryLight,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Skills chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: responder.skills.take(3).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: RgColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: RgColors.border, width: 1),
                    ),
                    child: Text(
                      skill,
                      style: RgTypography.caption.copyWith(
                        fontSize: 11,
                        color: RgColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (showWorkload) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Workload',
                      style: RgTypography.caption.copyWith(
                        color: RgColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${responder.currentWorkload}/${responder.maxWorkload} active calls',
                      style: RgTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: responder.currentWorkload >= responder.maxWorkload
                            ? RgColors.warning
                            : RgColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: responder.currentWorkload / responder.maxWorkload,
                    backgroundColor: RgColors.surfaceMuted,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      responder.currentWorkload >= responder.maxWorkload
                          ? RgColors.warning
                          : RgColors.primaryAccent,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
