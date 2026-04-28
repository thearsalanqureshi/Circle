import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../extensions/theme_extensions.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixPressed,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixPressed;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.inputMinHeight),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        validator: validator,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          suffixIconConstraints: const BoxConstraints(
            minWidth: AppSizes.iconButton,
            minHeight: AppSizes.iconButton,
          ),
          suffixIcon: suffixIcon == null
              ? null
              : IconButton(
                  tooltip: hintText,
                  onPressed: onSuffixPressed,
                  icon: Icon(suffixIcon, color: colors.textSecondary),
                ),
        ),
      ),
    );
  }
}
