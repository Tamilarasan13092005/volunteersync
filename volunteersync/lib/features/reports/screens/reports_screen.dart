import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../widgets/cards/stat_card.dart';
import '../../../widgets/charts/chart_widgets.dart';
import '../../../widgets/common/common_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'This Month';
  final _periods = ['This Week', 'This Month', 'Last 6 Months', 'All Time'];
  List<Map<String, dynamic>> _topVolunteers = [];
  bool _loadingVolunteers = true;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
      _loadTopVolunteers();
    });
  }

  Future<void> _loadTopVolunteers() async {
    setState(() => _loadingVolunteers = true);
    try {
      final res = await _supabase
          .from('volunteers')
          .select()
          .order('total_hours', ascending: false)
          .limit(5);
      setState(() {
        _topVolunteers = (res as List)
            .map<Map<String, dynamic>>((v) => {
                  'name': v['full_name'] ?? 'Unknown',
                  'hours': v['total_hours'] ?? 0,
                  'rate': v['rating'] ?? 0.0,
                  'events': v['events_attended'] ?? 0,
                })
            .toList();
      });
    } catch (e) {
      debugPrint('Top volunteers error: $e');
    }
    setState(() => _loadingVolunteers = false);
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final isMobile = AppUtils.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Reports & Analytics',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            const Text('Insights & performance metrics',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 14)),
                          ],
                        ),
                      ),
                      GradientButton(
                        label: 'Refresh',
                        onPressed: () {
                          context.read<DashboardProvider>().loadDashboard();
                          _loadTopVolunteers();
                          AppUtils.showSnackBar(context, 'Data refreshed!');
                        },
                        icon: Icons.refresh_rounded,
                        gradient: AppColors.emeraldGradient,
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 16),

                  // Period selector
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _periods.map((p) {
                        final isSelected = p == _selectedPeriod;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPeriod = p),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(p,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // KPI row
                  if (dash.stats != null) ...[
                    isMobile
                        ? GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.3,
                            children: [
                              StatCard(
                                label: 'Total Volunteers',
                                value: dash.stats!.totalVolunteers.toString(),
                                change:
                                    '+${dash.stats!.volunteerGrowthPercent.toStringAsFixed(1)}%',
                                icon: Icons.people_rounded,
                                gradient: AppColors.primaryGradient,
                                animationDelay: 300,
                              ),
                              StatCard(
                                label: 'Hours Logged',
                                value: AppUtils.formatNumber(
                                    dash.stats!.hoursThisMonth),
                                change: 'Total hours',
                                icon: Icons.schedule_rounded,
                                gradient: AppColors.emeraldGradient,
                                animationDelay: 400,
                              ),
                              StatCard(
                                label: 'Attendance Rate',
                                value:
                                    '${dash.stats!.attendanceRate.toStringAsFixed(1)}%',
                                change: 'Overall rate',
                                icon: Icons.fact_check_rounded,
                                gradient: AppColors.amberGradient,
                                animationDelay: 500,
                              ),
                              StatCard(
                                label: 'Events Run',
                                value: dash.stats!.totalEvents.toString(),
                                change:
                                    '${dash.stats!.upcomingEvents} upcoming',
                                icon: Icons.event_rounded,
                                gradient: AppColors.cyanGradient,
                                animationDelay: 600,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                  child: StatCard(
                                label: 'Total Volunteers',
                                value: dash.stats!.totalVolunteers.toString(),
                                change:
                                    '+${dash.stats!.volunteerGrowthPercent.toStringAsFixed(1)}%',
                                icon: Icons.people_rounded,
                                gradient: AppColors.primaryGradient,
                                animationDelay: 300,
                              )),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: StatCard(
                                label: 'Hours Logged',
                                value: AppUtils.formatNumber(
                                    dash.stats!.hoursThisMonth),
                                change: 'Total hours',
                                icon: Icons.schedule_rounded,
                                gradient: AppColors.emeraldGradient,
                                animationDelay: 400,
                              )),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: StatCard(
                                label: 'Attendance Rate',
                                value:
                                    '${dash.stats!.attendanceRate.toStringAsFixed(1)}%',
                                change: 'Overall rate',
                                icon: Icons.fact_check_rounded,
                                gradient: AppColors.amberGradient,
                                animationDelay: 500,
                              )),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: StatCard(
                                label: 'Events Run',
                                value: dash.stats!.totalEvents.toString(),
                                change:
                                    '${dash.stats!.upcomingEvents} upcoming',
                                icon: Icons.event_rounded,
                                gradient: AppColors.cyanGradient,
                                animationDelay: 600,
                              )),
                            ],
                          ),
                    const SizedBox(height: 28),
                  ],

                  // Volunteer Growth Chart
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: 'Volunteer Growth',
                          subtitle: 'Cumulative volunteer count',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: VolunteerGrowthChart(
                              data: dash.monthlyVolunteers),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 16),

                  // Two charts side by side
                  isMobile
                      ? Column(children: [
                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionHeader(title: 'Weekly Attendance'),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 200,
                                  child: AttendanceBarChart(
                                      data: dash.weeklyAttendance),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 800.ms),
                          const SizedBox(height: 16),
                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionHeader(title: 'Event Categories'),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 200,
                                  child: CategoryPieChart(
                                      data: dash.categoryDistribution),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 900.ms),
                        ])
                      : Row(children: [
                          Expanded(
                            child: GlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SectionHeader(
                                      title: 'Weekly Attendance'),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
                                    child: AttendanceBarChart(
                                        data: dash.weeklyAttendance),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 800.ms),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SectionHeader(
                                      title: 'Event Categories'),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
                                    child: CategoryPieChart(
                                        data: dash.categoryDistribution),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 900.ms),
                          ),
                        ]),

                  const SizedBox(height: 16),

                  // Top volunteers - real data
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: 'Top Volunteers',
                          subtitle: 'By total hours logged',
                        ),
                        const SizedBox(height: 16),
                        _loadingVolunteers
                            ? const Center(child: CircularProgressIndicator())
                            : _topVolunteers.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Text(
                                        'No volunteer data yet.\nAdd volunteers to see rankings here.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 13),
                                      ),
                                    ),
                                  )
                                : _TopVolunteersTable(
                                    volunteers: _topVolunteers),
                      ],
                    ),
                  ).animate().fadeIn(delay: 1000.ms),

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

class _TopVolunteersTable extends StatelessWidget {
  final List<Map<String, dynamic>> volunteers;
  const _TopVolunteersTable({required this.volunteers});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text('VOLUNTEER',
                      style: TextStyle(
                          color: AppColors.textDisabled,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8))),
              Expanded(
                  flex: 1,
                  child: Text('HOURS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textDisabled,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8))),
              Expanded(
                  flex: 1,
                  child: Text('EVENTS',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: AppColors.textDisabled,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8))),
            ],
          ),
        ),
        const Divider(color: AppColors.border, height: 1),
        ...volunteers.asMap().entries.map((e) {
          final v = e.value;
          final rank = e.key + 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: rank == 1
                            ? AppColors.accent3.withOpacity(0.2)
                            : AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('#$rank',
                            style: TextStyle(
                              color: rank == 1
                                  ? AppColors.accent3
                                  : AppColors.textMuted,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          AppAvatar(name: v['name'] as String, radius: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(v['name'] as String,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('${v['hours']}h',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('${v['events']}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              color: AppColors.accent2,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              if (rank < volunteers.length)
                const Divider(color: AppColors.border, height: 1),
            ],
          );
        }),
      ],
    );
  }
}
