import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common/common_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _orgCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _agreed = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _orgCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please accept the terms to continue'),
        backgroundColor: AppColors.accent4,
      ));
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(_nameCtrl.text.trim(),
        _emailCtrl.text.trim(), _passCtrl.text, _orgCtrl.text.trim());
    if (mounted && ok) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) context.go(AppRouter.dashboard);
    } else if (mounted && !ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.errorMessage ?? 'Registration failed'),
        backgroundColor: AppColors.accent4,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.secondary.withOpacity(0.1),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  IconButton(
                    onPressed: () => context.go(AppRouter.login),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textMuted, size: 20),
                  ).animate().fadeIn(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(Icons.hub_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(AppConstants.appName,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          )),
                    ],
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 40),
                  Text('Create your account',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800))
                      .animate()
                      .fadeIn(delay: 200.ms),
                  const SizedBox(height: 6),
                  const Text('Start coordinating volunteers in minutes',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 14))
                      .animate()
                      .fadeIn(delay: 300.ms),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          key: const Key('register_name_field'),
                          controller: _nameCtrl,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline_rounded,
                                color: AppColors.textMuted, size: 20),
                          ),
                          validator: (v) => v == null || v.trim().length < 2
                              ? 'Enter your name'
                              : null,
                        ).animate().fadeIn(delay: 350.ms),

                        const SizedBox(height: 14),

                        TextFormField(
                          key: const Key('register_org_field'),
                          controller: _orgCtrl,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Organization',
                            prefixIcon: Icon(Icons.business_outlined,
                                color: AppColors.textMuted, size: 20),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Enter your organization'
                              : null,
                        ).animate().fadeIn(delay: 400.ms),

                        const SizedBox(height: 14),

                        TextFormField(
                          key: const Key('register_email_field'),
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Work Email',
                            prefixIcon: Icon(Icons.mail_outline_rounded,
                                color: AppColors.textMuted, size: 20),
                          ),
                          validator: (v) => v == null || !v.contains('@')
                              ? 'Enter a valid email'
                              : null,
                        ).animate().fadeIn(delay: 450.ms),

                        const SizedBox(height: 14),

                        TextFormField(
                          key: const Key('register_password_field'),
                          controller: _passCtrl,
                          obscureText: _obscure,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                color: AppColors.textMuted, size: 20),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                            ),
                          ),
                          validator: (v) => v == null || v.length < 8
                              ? 'Min 8 characters'
                              : null,
                        ).animate().fadeIn(delay: 500.ms),

                        const SizedBox(height: 20),

                        // Terms
                        GestureDetector(
                          onTap: () => setState(() => _agreed = !_agreed),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _agreed
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: _agreed
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: _agreed
                                    ? const Icon(Icons.check_rounded,
                                        size: 13, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'I agree to the Terms of Service and Privacy Policy',
                                  style: TextStyle(
                                      color: AppColors.textMuted, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 550.ms),

                        const SizedBox(height: 24),

                        GradientButton(
                          key: const Key('register_submit_button'),
                          label: 'Create Account',
                          onPressed: _submit,
                          isLoading: auth.status == AuthStatus.loading,
                          width: double.infinity,
                          icon: Icons.rocket_launch_rounded,
                        ).animate().fadeIn(delay: 600.ms),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 14)),
                      GestureDetector(
                        onTap: () => context.go(AppRouter.login),
                        child: const Text('Sign in',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            )),
                      ),
                    ],
                  ).animate().fadeIn(delay: 650.ms),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
