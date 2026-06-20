import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common/common_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _sent = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
              const SizedBox(height: 40),
              if (_sent) ..._buildSuccess() else ..._buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildForm() => [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.lock_reset_rounded,
              color: AppColors.primary, size: 28),
        ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.8, 0.8)),
        const SizedBox(height: 24),
        Text('Reset password',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800))
            .animate()
            .fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        const Text(
          "Enter your email and we'll send you a reset link.",
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 36),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.mail_outline_rounded,
                      color: AppColors.textMuted, size: 20),
                ),
                validator: (v) => v == null || !v.contains('@')
                    ? 'Enter a valid email'
                    : null,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 24),
              GradientButton(
                label: 'Send Reset Link',
                onPressed: _submit,
                isLoading: _loading,
                width: double.infinity,
                icon: Icons.send_rounded,
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ];

  List<Widget> _buildSuccess() => [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.accent2.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_rounded,
              color: AppColors.accent2, size: 34),
        ).animate().scale(begin: const Offset(0.5, 0.5)).fadeIn(),
        const SizedBox(height: 24),
        Text('Check your inbox',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800))
            .animate()
            .fadeIn(delay: 200.ms),
        const SizedBox(height: 10),
        Text(
          "We sent a reset link to ${_emailCtrl.text}. Check your email and follow the instructions.",
          style: const TextStyle(
              color: AppColors.textMuted, fontSize: 14, height: 1.6),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 36),
        GradientButton(
          label: 'Back to Sign In',
          onPressed: () => context.go(AppRouter.login),
          width: double.infinity,
        ).animate().fadeIn(delay: 400.ms),
      ];
}
