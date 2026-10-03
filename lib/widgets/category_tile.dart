import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/constants/dimensions.dart';
import '../data/models/enums.dart';

class CategoryTile extends StatelessWidget {
  final IncidentCategory category;
  final VoidCallback onTap;
  final bool isSelected;

  const CategoryTile({
    super.key,
    required this.category,
    required this.onTap,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? category.color.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
            border: Border.all(
              color: isSelected ? category.color : RgColors.border,
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: isSelected ? RgDimensions.elevatedShadow : RgDimensions.cardShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                category.displayName,
                style: RgTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: RgColors.textPrimary,
                  fontSize: 12.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final IncidentCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? category.color : Colors.white,
          borderRadius: BorderRadius.circular(RgDimensions.radiusFull),
          border: Border.all(
            color: isSelected ? category.color : RgColors.border,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: category.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 16,
              color: isSelected ? Colors.white : category.color,
            ),
            const SizedBox(width: 6),
            Text(
              category.displayName,
              style: RgTypography.caption.copyWith(
                color: isSelected ? Colors.white : RgColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
