import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text);
    if (mounted && ok) context.go(AppRouter.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient orbs
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withOpacity(0.18),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.secondary.withOpacity(0.14),
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

                  // Back button
                  IconButton(
                    onPressed: () => context.go(AppRouter.landing),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textMuted, size: 20),
                  ).animate().fadeIn(),

                  const SizedBox(height: 32),

                  // Hero top section
                  Center(
                    child: Column(
                      children: [
                        // Logo with glow
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withOpacity(0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.hub_rounded,
                              color: Colors.white, size: 32),
                        )
                            .animate()
                            .scale(begin: const Offset(0.7, 0.7))
                            .fadeIn(),

                        const SizedBox(height: 16),

                        const Text(
                          AppConstants.appName,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ).animate().fadeIn(delay: 100.ms),

                        const SizedBox(height: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text(
                            'Volunteer Management Platform',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ).animate().fadeIn(delay: 150.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Welcome text
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Welcome back 👋',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                        const SizedBox(height: 6),
                        const Text(
                          'Sign in to manage your volunteers and events',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 250.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Form card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email
                          const Text(
                            'Email address',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            key: const Key('login_email_field'),
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'you@example.com',
                              hintStyle: TextStyle(
                                  color: AppColors.textDisabled, fontSize: 14),
                              prefixIcon: Icon(Icons.mail_outline_rounded,
                                  color: AppColors.textMuted, size: 20),
                            ),
                            validator: (v) => v == null || !v.contains('@')
                                ? 'Enter a valid email'
                                : null,
                          ).animate().fadeIn(delay: 350.ms),

                          const SizedBox(height: 20),

                          // Password
                          const Text(
                            'Password',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            key: const Key('login_password_field'),
                            controller: _passCtrl,
                            obscureText: _obscure,
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: const TextStyle(
                                  color: AppColors.textDisabled, fontSize: 14),
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
                            validator: (v) => v == null || v.length < 6
                                ? 'Min 6 characters'
                                : null,
                          ).animate().fadeIn(delay: 400.ms),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  context.go(AppRouter.forgotPassword),
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                    color: AppColors.primary, fontSize: 12),
                              ),
                            ),
                          ).animate().fadeIn(delay: 430.ms),

                          // Error message
                          if (auth.status == AuthStatus.error) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.accent4.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.accent4
                                        .withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      color: AppColors.accent4, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      auth.errorMessage ?? 'An error occurred',
                                      style: const TextStyle(
                                          color: AppColors.accent4,
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Sign in button
                          GradientButton(
                            key: const Key('login_submit_button'),
                            label: 'Sign In',
                            onPressed: _submit,
                            isLoading: auth.status == AuthStatus.loading,
                            width: double.infinity,
                          ).animate().fadeIn(delay: 500.ms),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // Sign up link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ",
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 14)),
                        GestureDetector(
                          onTap: () => context.go(AppRouter.register),
                          child: const Text(
                            'Sign up free →',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
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
