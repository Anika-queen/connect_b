import 'package:connect_b/app/theme/app_theme.dart';
import 'package:connect_b/core/services/navigation_service.dart';
import 'package:connect_b/features/auth/presentation/providers/auth_provider.dart';
import 'package:connect_b/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//nipa : update this
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _departmentController = TextEditingController();
  final _batchController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'Student';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    _batchController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final department = _departmentController.text.trim();
    final batch = _batchController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullName.length < 2) {
      _showMessage('Please enter your full name.');
      return;
    }
    if (email.isEmpty) {
      _showMessage('Please enter your email.');
      return;
    }
    if (department.length < 2) {
      _showMessage('Please enter your department.');
      return;
    }
    if (batch.isEmpty) {
      _showMessage('Please enter your batch.');
      return;
    }
    if (password.length < 8) {
      _showMessage('Password must be at least 8 characters.');
      return;
    }
    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    final error = await ref.read(authProvider.notifier).signUp(
          email: email,
          password: password,
          fullName: fullName,
          role: _selectedRole,
          department: department,
          batch: batch,
        );

    if (error != null) {
      if (mounted) _showMessage(error);
      return;
    }

    if (mounted) {
      _showMessage('Account created. Check your email for verification.');
      NavigationService.instance.pop();
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
    final hp = width >= 600 ? 40.0 : 20.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hp, 20, hp, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 510),
              child: Column(
                children: [
                  _topHeader(),
                  const SizedBox(height: 16),
                  _signupCard(isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              color: AppColors.lightGray,
            ),
            child: const Icon(Icons.person_add_alt_1,
                color: AppColors.nearBlack),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create your profile',
                    style: Theme.of(context).textTheme.titleLarge),
                Text('Join the BAUST community in minutes.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.stone)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _signupCard(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTextField(
            controller: _nameController,
            label: 'Full name',
            hint: 'Your name',
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),
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
            controller: _departmentController,
            label: 'Department',
            hint: 'CSE, EEE, BBA...',
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.apartment_rounded,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _batchController,
            label: 'Batch',
            hint: 'e.g. 2019',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.numbers_rounded,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Minimum 8 characters',
            obscureText: true,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _confirmPasswordController,
            label: 'Confirm password',
            hint: 'Re-enter your password',
            obscureText: true,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.verified_user_outlined,
          ),
          const SizedBox(height: 16),
          Text('Role', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment<String>(
                value: 'Student',
                icon: Icon(Icons.school_outlined, size: 18),
                label: Text('Student'),
              ),
              ButtonSegment<String>(
                value: 'Alumni',
                icon: Icon(Icons.workspace_premium_outlined, size: 18),
                label: Text('Alumni'),
              ),
            ],
            selected: {_selectedRole},
            onSelectionChanged: (v) => setState(() => _selectedRole = v.first),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: isLoading ? null : _createAccount,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.pureWhite),
                  )
                : const Text('Create Account'),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account?',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.stone)),
              TextButton(
                onPressed: () => NavigationService.instance.pop(),
                child: const Text('Sign in'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.snow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'After sign up, verify your email from the Supabase magic link.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
