import 'package:connect_b/app/router/app_router.dart';
import 'package:connect_b/app/theme/app_theme.dart';
import 'package:connect_b/core/services/navigation_service.dart';
import 'package:connect_b/features/auth/presentation/providers/auth_provider.dart';
import 'package:connect_b/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
// shanu : update
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showMessage('Please enter your email.');
      return;
    }
    if (password.isEmpty) {
      _showMessage('Please enter your password.');
      return;
    }

    final error = await ref.read(authProvider.notifier).signIn(
      email: email,
      password: password,
    );

    if (error != null) {
      if (error.toLowerCase().contains('email not confirmed')) {
        await _resendVerification();
        return;
      }
      if (mounted) _showMessage(error);
      return;
    }

    if (mounted) {
      NavigationService.instance.pushReplacementNamed(AppRoutes.home);
    }
  }

  Future<void> _resendVerification() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty) {
      _showMessage('Enter your email first.');
      return;
    }
    final error = await ref.read(authProvider.notifier).resendVerification(email);
    if (mounted) {
      _showMessage(error ?? 'Verification email sent.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).status == AuthStatus.loading;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 840;

    return Scaffold(
      body: SafeArea(
        child: isDesktop ? _desktopLayout(isLoading) : _mobileLayout(width, isLoading),
      ),
    );
  }

  Widget _desktopLayout(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Row(
        children: [
          Expanded(child: _identityPanel()),
          const SizedBox(width: 28),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 470),
                child: _authCard(isLoading),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileLayout(double width, bool isLoading) {
    final hp = width >= 600 ? 40.0 : 20.0;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hp, 22, hp, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 470),
          child: Column(
            children: [
              _identityPanel(compact: true),
              const SizedBox(height: 18),
              _authCard(isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _identityPanel({bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(compact ? 22 : 34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            compact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: compact ? 56 : 68,
            height: compact ? 56 : 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              color: AppColors.lightGray,
            ),
            child: const Icon(Icons.forum_rounded,
                color: AppColors.nearBlack, size: 34),
          ),
          const SizedBox(height: 18),
          Text('BAUST Connect',
              textAlign: compact ? TextAlign.left : TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(
            'A focused social platform for students and alumni to build real academic and career connections.',
            textAlign: compact ? TextAlign.left : TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.stone),
          ),
        ],
      ),
    );
  }

  Widget _authCard(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text('Secure Login',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: AppColors.nearBlack)),
          ),
          const SizedBox(height: 14),
          Text('Welcome back',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text('Sign in to continue your BAUST network journey.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.stone)),
          const SizedBox(height: 20),
          AuthTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            obscureText: true,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: isLoading ? null : _signIn,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.pureWhite),
                  )
                : const Text('Sign In'),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('New here?',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.stone)),
              TextButton(
                onPressed: () {
                  NavigationService.instance.pushNamed(AppRoutes.signUp);
                },
                child: const Text('Create account'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
