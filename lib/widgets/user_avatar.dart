import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';

class UserAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const UserAvatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? RgColors.primary;
    final fg = textColor ?? Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10101828),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: RgTypography.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
