import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/auth_error_mapper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_error_banner.dart';
import '../../../../core/widgets/app_gradient_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() {
    return _ForgotPasswordScreenState();
  }
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final error = authState.hasError
        ? AuthErrorMapper.messageFor(authState.error)
        : null;

    return AuthScaffold(
      title: AppStrings.resetPassword,
      subtitle: AppStrings.forgotPasswordSubtitle,
      footer: AuthFooterLink(
        prompt: AppStrings.alreadyHaveAccount,
        action: AppStrings.login,
        onActionPressed: () => context.go(AppRoutes.login),
      ),
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              if (error != null) ...[
                AppErrorBanner(message: error),
                const SizedBox(height: AppSpacing.md),
              ],
              AppTextField(
                controller: _emailController,
                hintText: AppStrings.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                suffixIcon: Icons.mail_outline,
                validator: Validators.email,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppGradientButton(
                label: AppStrings.sendResetLink,
                isLoading: authState.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final success = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_emailController.text);

    if (success && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(AppStrings.resetEmailSent),
            duration: AppDurations.feedback,
          ),
        );
    }
  }
}
