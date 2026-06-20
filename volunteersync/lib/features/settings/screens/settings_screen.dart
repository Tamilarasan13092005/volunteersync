import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifs = true;
  bool _pushNotifs = true;
  bool _aiInsights = true;
  bool _weeklyReport = false;
  bool _twoFA = false;
  String _language = 'English';
  String _timezone = 'Pacific Time (PT)';
  bool _changingPassword = false;

  Future<void> _changePassword() async {
    final auth = context.read<AuthProvider>();
    final email = auth.user?.email ?? '';
    if (email.isEmpty) return;

    setState(() => _changingPassword = true);
    try {
      final ok = await auth.forgotPassword(email);
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          ok
              ? 'Password reset email sent to $email!'
              : 'Failed to send reset email.',
        );
      }
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800))
                .animate()
                .fadeIn(delay: 100.ms),

            const SizedBox(height: 4),
            const Text('Manage your account & preferences',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14))
                .animate()
                .fadeIn(delay: 150.ms),

            const SizedBox(height: 28),

            // Profile section
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PROFILE',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      )),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      AppAvatar(name: user?.name ?? 'User', radius: 30),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.name ?? '',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                )),
                            Text(user?.email ?? '',
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 13)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                (user?.role ?? 'user').toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primaryLight,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 12),
                  _InfoRow('Email', user?.email ?? ''),
                  _InfoRow('Role', user?.role ?? 'admin'),
                  _InfoRow(
                      'Organization', user?.organization ?? 'VolunteerSync'),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Notifications
            _SettingsSection(
              title: 'Notifications',
              delay: 300,
              children: [
                _SwitchTile(
                  icon: Icons.email_outlined,
                  label: 'Email notifications',
                  subtitle: 'Receive event & volunteer updates',
                  value: _emailNotifs,
                  onChanged: (v) => setState(() => _emailNotifs = v),
                ),
                _SwitchTile(
                  icon: Icons.notifications_outlined,
                  label: 'Push notifications',
                  subtitle: 'Real-time alerts on your device',
                  value: _pushNotifs,
                  onChanged: (v) => setState(() => _pushNotifs = v),
                ),
                _SwitchTile(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI insights',
                  subtitle: 'Proactive recommendations from Volt',
                  value: _aiInsights,
                  onChanged: (v) => setState(() => _aiInsights = v),
                ),
                _SwitchTile(
                  icon: Icons.bar_chart_rounded,
                  label: 'Weekly digest',
                  subtitle: 'Summary report every Monday',
                  value: _weeklyReport,
                  onChanged: (v) => setState(() => _weeklyReport = v),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Security
            _SettingsSection(
              title: 'Security',
              delay: 400,
              children: [
                _SwitchTile(
                  icon: Icons.security_rounded,
                  label: 'Two-factor authentication',
                  subtitle: 'Add an extra layer of security',
                  value: _twoFA,
                  onChanged: (v) => setState(() => _twoFA = v),
                ),
                _ActionTile(
                  icon: Icons.lock_reset_rounded,
                  label: _changingPassword
                      ? 'Sending reset email...'
                      : 'Change password',
                  onTap: _changingPassword ? () {} : _changePassword,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Preferences
            _SettingsSection(
              title: 'Preferences',
              delay: 500,
              children: [
                _DropdownTile(
                  icon: Icons.language_rounded,
                  label: 'Language',
                  value: _language,
                  options: const ['English', 'Spanish', 'French', 'German'],
                  onChanged: (v) => setState(() => _language = v),
                ),
                _DropdownTile(
                  icon: Icons.schedule_rounded,
                  label: 'Timezone',
                  value: _timezone,
                  options: const [
                    'Pacific Time (PT)',
                    'Mountain Time (MT)',
                    'Central Time (CT)',
                    'Eastern Time (ET)',
                  ],
                  onChanged: (v) => setState(() => _timezone = v),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // About
            _SettingsSection(
              title: 'About',
              delay: 600,
              children: [
                _ActionTile(
                  icon: Icons.info_outline_rounded,
                  label: 'App version',
                  trailing: '1.0.0',
                  onTap: () {},
                ),
                _ActionTile(
                  icon: Icons.description_outlined,
                  label: 'Terms of Service',
                  onTap: () => AppUtils.showSnackBar(context, 'Coming soon!'),
                ),
                _ActionTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () => AppUtils.showSnackBar(context, 'Coming soon!'),
                ),
                _ActionTile(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  onTap: () => AppUtils.showSnackBar(
                      context, 'Contact: support@volunteersync.io'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sign out
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) context.go(AppRouter.login);
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent4,
                  side: BorderSide(color: AppColors.accent4.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 12),

            const Center(
              child: Text('VolunteerSync v1.0.0 · Made with ❤️',
                  style:
                      TextStyle(color: AppColors.textDisabled, fontSize: 11)),
            ).animate().fadeIn(delay: 750.ms),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final int delay;

  const _SettingsSection({
    required this.title,
    required this.children,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              )),
          const SizedBox(height: 14),
          ...children.asMap().entries.map((e) => Column(
                children: [
                  e.value,
                  if (e.key < children.length - 1)
                    const Divider(color: AppColors.border, height: 16),
                ],
              )),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.1);
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.textMuted, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
              Text(subtitle,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textMuted, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                )),
          ),
          if (trailing != null)
            Text(trailing!,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 13))
          else
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _DropdownTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.textMuted, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              )),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            dropdownColor: AppColors.surfaceElevated,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            icon: const Icon(Icons.expand_more_rounded,
                color: AppColors.textMuted, size: 18),
            items: options
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            onChanged: (v) => v != null ? onChanged(v) : null,
          ),
        ),
      ],
    );
  }
}
