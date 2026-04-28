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
import '../widgets/remember_me_tile.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final obscurePassword = ref.watch(loginPasswordObscuredProvider);
    final rememberMe = ref.watch(rememberMeProvider);
    final error = authState.hasError
        ? AuthErrorMapper.messageFor(authState.error)
        : null;

    return AuthScaffold(
      title: AppStrings.login,
      subtitle: AppStrings.welcomeBack,
      footer: AuthFooterLink(
        prompt: AppStrings.dontHaveAccount,
        action: AppStrings.signup,
        onActionPressed: () => context.go(AppRoutes.signup),
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
                textInputAction: TextInputAction.next,
                suffixIcon: Icons.person_outline,
                validator: Validators.email,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _passwordController,
                hintText: AppStrings.password,
                textInputAction: TextInputAction.done,
                obscureText: obscurePassword,
                suffixIcon: obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                onSuffixPressed: () {
                  ref.read(loginPasswordObscuredProvider.notifier).toggle();
                },
                validator: Validators.password,
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: RememberMeTile(
                  value: rememberMe,
                  onChanged: (value) {
                    ref.read(rememberMeProvider.notifier).setValue(value);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppGradientButton(
                label: AppStrings.login,
                isLoading: authState.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => context.go(AppRoutes.forgotPassword),
                child: const Text(AppStrings.forgotPassword),
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
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }
}
