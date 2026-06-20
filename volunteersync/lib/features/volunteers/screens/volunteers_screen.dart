import 'package:volunteersync/widgets/cards/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../models/volunteer.dart';
import '../../../providers/volunteers_provider.dart';
import '../../../widgets/common/common_widgets.dart';

class VolunteersScreen extends StatefulWidget {
  const VolunteersScreen({super.key});

  @override
  State<VolunteersScreen> createState() => _VolunteersScreenState();
}

class _VolunteersScreenState extends State<VolunteersScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VolunteersProvider>().loadVolunteers();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<VolunteersProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Volunteers',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                          Text(
                              '${prov.totalCount} total · ${prov.activeCount} active',
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 14)),
                        ],
                      ),
                    ),
                    GradientButton(
                      label: 'Add Volunteer',
                      onPressed: () => _showAddDialog(context),
                      icon: Icons.person_add_rounded,
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 16),
                AppSearchBar(
                  hint: 'Search volunteers...',
                  controller: _searchCtrl,
                  onChanged: prov.setSearch,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                FilterChipRow(
                  options: const ['all', 'active', 'inactive', 'pending'],
                  selected: prov.filterStatus,
                  onSelected: prov.setFilter,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // List
          Expanded(
            child: prov.isLoading
                ? _buildShimmer()
                : prov.volunteers.isEmpty
                    ? const EmptyState(
                        icon: Icons.people_outline_rounded,
                        title: 'No volunteers found',
                        subtitle: 'Try adjusting your search or filters',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: prov.volunteers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final v = prov.volunteers[i];
                          return _VolunteerCard(
                            volunteer: v,
                            index: i,
                            onTap: () => _showDetail(context, v),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) =>
          const ShimmerBox(width: double.infinity, height: 88),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _AddVolunteerDialog(),
    );
  }

  void _showDetail(BuildContext context, Volunteer v) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _VolunteerDetailSheet(volunteer: v),
    );
  }
}

class _VolunteerCard extends StatelessWidget {
  final Volunteer volunteer;
  final int index;
  final VoidCallback onTap;

  const _VolunteerCard({
    required this.volunteer,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppUtils.colorFromStatus(volunteer.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            AppAvatar(name: volunteer.name, radius: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(volunteer.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                      StatusBadge(label: volunteer.status, color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(volunteer.role,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 13, color: AppColors.textDisabled),
                      const SizedBox(width: 4),
                      Text('${volunteer.totalHours}h logged',
                          style: const TextStyle(
                              color: AppColors.textDisabled, fontSize: 11)),
                      const SizedBox(width: 12),
                      const Icon(Icons.fact_check_rounded,
                          size: 13, color: AppColors.textDisabled),
                      const SizedBox(width: 4),
                      Text(
                          '${volunteer.attendanceRate.toStringAsFixed(0)}% attendance',
                          style: const TextStyle(
                              color: AppColors.textDisabled, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 50 * index))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05);
  }
}

class _VolunteerDetailSheet extends StatelessWidget {
  final Volunteer volunteer;
  const _VolunteerDetailSheet({required this.volunteer});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppUtils.colorFromStatus(volunteer.status);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppAvatar(name: volunteer.name, radius: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(volunteer.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              Text(volunteer.role,
                                  style: const TextStyle(
                                      color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        StatusBadge(
                            label: volunteer.status, color: statusColor),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 20),

                    _DetailRow(
                        icon: Icons.mail_outline_rounded,
                        label: 'Email',
                        value: volunteer.email),
                    _DetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: volunteer.phone),
                    _DetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value: volunteer.location),
                    _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Joined',
                        value: AppUtils.formatDate(volunteer.joinedDate)),

                    const SizedBox(height: 20),

                    // Stats
                    Row(
                      children: [
                        Expanded(
                            child: KpiCard(
                          label: 'Total Hours',
                          value: '${volunteer.totalHours}h',
                          color: AppColors.primary,
                          progressValue: volunteer.totalHours / 500,
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: KpiCard(
                          label: 'Attendance',
                          value:
                              '${volunteer.attendanceRate.toStringAsFixed(0)}%',
                          color: AppColors.accent2,
                          progressValue: volunteer.attendanceRate / 100,
                        )),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text('Skills',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: volunteer.skills
                          .map((s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(s,
                                    style: const TextStyle(
                                      color: AppColors.primaryLight,
                                      fontSize: 12,
                                    )),
                              ))
                          .toList(),
                    ),

                    if (volunteer.bio.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text('Bio',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(volunteer.bio,
                          style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                              height: 1.6)),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
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

class _AddVolunteerDialog extends StatefulWidget {
  const _AddVolunteerDialog();

  @override
  State<_AddVolunteerDialog> createState() => _AddVolunteerDialogState();
}

class _AddVolunteerDialogState extends State<_AddVolunteerDialog> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Volunteer',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    v?.contains('@') == false ? 'Invalid email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _roleCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration:
                    const InputDecoration(labelText: 'Role (e.g. Coordinator)'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: AppColors.textMuted)),
                  ),
                  const SizedBox(width: 12),
                  GradientButton(
                    label: 'Add',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final volunteer = Volunteer(
                          id: '',
                          name: _nameCtrl.text.trim(),
                          email: _emailCtrl.text.trim(),
                          phone: '',
                          role: _roleCtrl.text.trim().isEmpty
                              ? 'Volunteer'
                              : _roleCtrl.text.trim(),
                          status: 'active',
                          avatarUrl: '',
                          skills: [],
                          assignedEvents: [],
                          totalHours: 0,
                          attendanceRate: 0,
                          joinedDate: DateTime.now(),
                          location: '',
                          bio: '',
                        );
                        await context
                            .read<VolunteersProvider>()
                            .addVolunteer(volunteer);
                        if (context.mounted) {
                          Navigator.pop(context);
                          AppUtils.showSnackBar(
                              context, 'Volunteer added successfully!');
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
