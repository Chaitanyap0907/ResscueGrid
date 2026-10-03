import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/constants/dimensions.dart';

class RgTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  const RgTextField({
    super.key,
    required this.label,
    this.hint,
    this.hintText,
    this.controller,
    this.onChanged,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: RgTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: RgColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          style: RgTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: hintText ?? hint,
            hintStyle: RgTypography.bodyMedium.copyWith(color: RgColors.textMuted),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: RgColors.surfaceMuted,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
              borderSide: const BorderSide(color: RgColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
              borderSide: const BorderSide(color: RgColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
              borderSide: const BorderSide(color: RgColors.primaryAccent, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
              borderSide: const BorderSide(color: RgColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
              borderSide: const BorderSide(color: RgColors.error, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
