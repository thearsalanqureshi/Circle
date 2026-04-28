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
import '../providers/auth_form_state_providers.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_scaffold.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final obscurePassword = ref.watch(signUpPasswordObscuredProvider);
    final obscureConfirmPassword = ref.watch(
      signUpConfirmPasswordObscuredProvider,
    );
    final error = authState.hasError
        ? AuthErrorMapper.messageFor(authState.error)
        : null;

    return AuthScaffold(
      title: AppStrings.createAccount,
      subtitle: AppStrings.createAccountSubtitle,
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
                controller: _nameController,
                hintText: AppStrings.fullName,
                textInputAction: TextInputAction.next,
                suffixIcon: Icons.person_outline,
                validator: Validators.required,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _emailController,
                hintText: AppStrings.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                suffixIcon: Icons.mail_outline,
                validator: Validators.email,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _passwordController,
                hintText: AppStrings.password,
                textInputAction: TextInputAction.next,
                obscureText: obscurePassword,
                suffixIcon: obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                onSuffixPressed: () {
                  ref.read(signUpPasswordObscuredProvider.notifier).toggle();
                },
                validator: Validators.password,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _confirmPasswordController,
                hintText: AppStrings.confirmPassword,
                textInputAction: TextInputAction.done,
                obscureText: obscureConfirmPassword,
                suffixIcon: obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                onSuffixPressed: () {
                  ref
                      .read(signUpConfirmPasswordObscuredProvider.notifier)
                      .toggle();
                },
                validator: (value) {
                  return Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppGradientButton(
                label: AppStrings.createAccount,
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
        .createAccount(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }
}
