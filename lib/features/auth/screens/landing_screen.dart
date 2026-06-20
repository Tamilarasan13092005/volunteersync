import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common/common_widgets.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background orbs
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 400,
              height: 400,
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
            bottom: -120,
            left: -60,
            child: Container(
              width: 350,
              height: 350,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.hub_rounded,
                                  color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              AppConstants.appName,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 200.ms),
                        TextButton(
                          onPressed: () => context.go(AppRouter.login),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                      ],
                    ),

                    const SizedBox(height: 52),

                    // Hero badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.accent2,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AI-Powered Volunteer Management',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

                    const SizedBox(height: 24),

                    // Main heading
                    const Text(
                      'Turn one-time volunteers\ninto a community.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -1,
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

                    const SizedBox(height: 16),

                    const Text(
                      'Spreadsheets, group texts, and paper sign-ins are costing you volunteers. VolunteerSync replaces all of it — one platform for scheduling, check-ins, AI insights, and reporting.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ).animate().fadeIn(delay: 600.ms),

                    const SizedBox(height: 36),

                    // CTA buttons
                    Column(
                      children: [
                        GradientButton(
                          label: 'Get Started Free',
                          onPressed: () => context.go(AppRouter.register),
                          width: double.infinity,
                          icon: Icons.arrow_forward_rounded,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => context.go(AppRouter.login),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Sign In to Dashboard',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
// Hero image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=800&h=400&fit=crop',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ).animate().fadeIn(delay: 750.ms),

                    const SizedBox(height: 16),

// Social proof avatars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...[
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=60&h=60&fit=crop&crop=faces',
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=60&h=60&fit=crop&crop=faces',
                          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=60&h=60&fit=crop&crop=faces',
                          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=60&h=60&fit=crop&crop=faces',
                        ].asMap().entries.map((e) => Transform.translate(
                              offset: Offset(-(e.key * 12.0), 0),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.background, width: 2),
                                  image: DecorationImage(
                                    image: NetworkImage(e.value),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )),
                        const SizedBox(width: 4),
                        const Text(
                          '247+ volunteers joined',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 780.ms),

                    const SizedBox(height: 36),
                    const SizedBox(height: 48),

                    // Problem / Solution section
                    const _SectionCard(
                      icon: Icons.warning_amber_rounded,
                      iconColor: AppColors.accent3,
                      title: 'The problem we solve',
                      content:
                          'Most programs lose 60–70% of first-time volunteers because the experience is forgettable — and admin teams burn out rebuilding the roster every event.',
                      delay: 750,
                    ),

                    const SizedBox(height: 12),

                    const _SectionCard(
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.accent2,
                      title: 'The VolunteerSync solution',
                      content:
                          'One platform that handles scheduling, check-ins, hours, AI insights, and reporting — for volunteers, admins, and the whole organization.',
                      delay: 800,
                    ),

                    const SizedBox(height: 36),

                    // For Admins / For Volunteers
                    const _RoleCard(
                      icon: Icons.admin_panel_settings_rounded,
                      gradient: AppColors.primaryGradient,
                      title: 'For Admins',
                      subtitle:
                          'A real dashboard, not a glorified spreadsheet.',
                      points: [
                        'Add & manage volunteer profiles',
                        'Create and track events',
                        'One-tap attendance check-in',
                        'AI-powered insights & reports',
                      ],
                      delay: 850,
                    ),

                    const SizedBox(height: 12),

                    const _RoleCard(
                      icon: Icons.people_rounded,
                      gradient: AppColors.emeraldGradient,
                      title: 'For Volunteers',
                      subtitle: 'An experience they actually want to open.',
                      points: [
                        'View and join upcoming events',
                        'Track personal hours & attendance',
                        'Get recognized for contributions',
                        'Stay connected with the team',
                      ],
                      delay: 900,
                    ),

                    const SizedBox(height: 36),

                    // Feature grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                      children: _features
                          .asMap()
                          .entries
                          .map((e) => _FeatureCard(
                                feature: e.value,
                                delay: 950 + (e.key * 80),
                              ))
                          .toList(),
                    ),

                    const SizedBox(height: 36),

                    // Stats row
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Trusted by volunteer programs',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _statPill('247+', 'Volunteers'),
                              _vDivider(),
                              _statPill('32', 'Events'),
                              _vDivider(),
                              _statPill('94%', 'Attendance'),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 1100.ms),

                    const SizedBox(height: 36),

                    // Bottom CTA
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Stop running your program\non duct tape.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Replace spreadsheets and paper sign-ins with one platform built for the way your team actually works.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context.go(AppRouter.register),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Get Started Free →',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.2),

                    const SizedBox(height: 40),

                    // Footer
                    const Text(
                      '© 2026 VolunteerSync. Built for organizations that run on people.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textDisabled, fontSize: 11),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 36,
        color: AppColors.border,
      );

  Widget _statPill(String val, String label) => Column(
        children: [
          Text(val,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      );

  static const _features = [
    _Feature(
      icon: Icons.people_rounded,
      title: 'Volunteer Mgmt',
      desc: 'Profiles, skills & scheduling',
      gradient: AppColors.primaryGradient,
    ),
    _Feature(
      icon: Icons.auto_awesome_rounded,
      title: 'AI Assistant',
      desc: 'Smart insights & automation',
      gradient: AppColors.cyanGradient,
    ),
    _Feature(
      icon: Icons.analytics_rounded,
      title: 'Analytics',
      desc: 'Charts & KPI dashboards',
      gradient: AppColors.emeraldGradient,
    ),
    _Feature(
      icon: Icons.fact_check_rounded,
      title: 'Attendance',
      desc: 'Check-in tracking & reports',
      gradient: AppColors.amberGradient,
    ),
  ];
}

// ── Section Card ──────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final int delay;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 6),
                Text(content,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.6,
                    )),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideY(begin: 0.15);
  }
}

// ── Role Card ─────────────────────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Gradient gradient;
  final String title;
  final String subtitle;
  final List<String> points;
  final int delay;

  const _RoleCard({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      )),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...points.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_rounded,
                        size: 16, color: AppColors.accent2),
                    const SizedBox(width: 10),
                    Text(p,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              )),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideY(begin: 0.15);
  }
}

// ── Feature Card ──────────────────────────────────────────────────────────
class _Feature {
  final IconData icon;
  final String title;
  final String desc;
  final Gradient gradient;
  const _Feature({
    required this.icon,
    required this.title,
    required this.desc,
    required this.gradient,
  });
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  final int delay;
  const _FeatureCard({required this.feature, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: feature.gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(feature.icon, color: Colors.white, size: 18),
          ),
          const Spacer(),
          Text(feature.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 3),
          Text(feature.desc,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.2);
  }
}
