import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_extensions.dart';

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    required this.prompt,
    required this.action,
    required this.onActionPressed,
    super.key,
  });

  final String prompt;
  final String action;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.circleColors;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: prompt,
          style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          children: [
            TextSpan(
              text: action,
              recognizer: TapGestureRecognizer()..onTap = onActionPressed,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
