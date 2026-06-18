import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../models/event.dart';
import '../../../providers/events_provider.dart';
import '../../../widgets/common/common_widgets.dart';
import '../../../widgets/cards/stat_card.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsProvider>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<EventsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
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
                          Text('Events',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                          const Text('Manage all volunteer events',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 14)),
                        ],
                      ),
                    ),
                    GradientButton(
                      label: 'New Event',
                      onPressed: () => _showAddDialog(context),
                      icon: Icons.add_rounded,
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 16),
                AppSearchBar(
                  hint: 'Search events...',
                  onChanged: prov.setSearch,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                FilterChipRow(
                  options: const ['all', 'upcoming', 'completed', 'draft'],
                  selected: prov.filterStatus,
                  onSelected: prov.setFilter,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: prov.isLoading
                ? _buildShimmer()
                : prov.events.isEmpty
                    ? const EmptyState(
                        icon: Icons.event_busy_rounded,
                        title: 'No events found',
                        subtitle: 'Create your first event to get started',
                        actionLabel: 'Create Event',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: prov.events.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) => _EventCard(
                          event: prov.events[i],
                          index: i,
                          onTap: () => _showDetail(ctx, prov.events[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() => ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) =>
            const ShimmerBox(width: double.infinity, height: 140),
      );

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _AddEventDialog(),
    );
  }

  void _showDetail(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EventDetailSheet(event: event),
    );
  }
}

class _AddEventDialog extends StatefulWidget {
  const _AddEventDialog();

  @override
  State<_AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<_AddEventDialog> {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _organizerCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _category = 'Education';
  final DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  final DateTime _endDate = DateTime.now().add(const Duration(days: 2));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Event',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _organizerCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Organizer'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration:
                    const InputDecoration(labelText: 'Target Volunteers'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  'Education',
                  'Food Security',
                  'Environment',
                  'Health & Wellness',
                  'Housing',
                  'Digital Inclusion',
                ]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
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
                    label: 'Create',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final event = Event(
                          id: '',
                          title: _titleCtrl.text.trim(),
                          description: _descCtrl.text.trim(),
                          location: _locationCtrl.text.trim(),
                          startDate: _startDate,
                          endDate: _endDate,
                          status: 'upcoming',
                          category: _category,
                          targetVolunteers: int.tryParse(_targetCtrl.text) ?? 0,
                          registeredVolunteers: 0,
                          attendedVolunteers: 0,
                          organizer: _organizerCtrl.text.trim(),
                          volunteerIds: [],
                          imageUrl: '',
                          tags: [],
                        );
                        await context.read<EventsProvider>().addEvent(event);
                        if (context.mounted) {
                          Navigator.pop(context);
                          AppUtils.showSnackBar(
                              context, 'Event created successfully!');
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

class _EventCard extends StatelessWidget {
  final Event event;
  final int index;
  final VoidCallback onTap;

  const _EventCard(
      {required this.event, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppUtils.colorFromStatus(event.status);
    final categoryColors = {
      'Food Security': AppColors.accent3,
      'Education': AppColors.primary,
      'Environment': AppColors.accent2,
      'Digital Inclusion': AppColors.accent1,
      'Housing': AppColors.secondary,
      'Health & Wellness': AppColors.accent5,
    };
    final catColor = categoryColors[event.category] ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
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
                    color: catColor.withValues(alpha:  0.15),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(Icons.event_rounded, color: catColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          )),
                      Text(event.category,
                          style: TextStyle(color: catColor, fontSize: 11)),
                    ],
                  ),
                ),
                StatusBadge(label: event.status, color: statusColor),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: AppColors.textDisabled),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(event.location,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppColors.textDisabled),
                const SizedBox(width: 4),
                Text(AppUtils.formatDate(event.startDate),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.people_outline_rounded,
                    size: 13, color: AppColors.textDisabled),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              '${event.registeredVolunteers}/${event.targetVolunteers} volunteers',
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 11)),
                          Text('${(event.fillRate * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                  color: event.fillRate > 0.8
                                      ? AppColors.accent2
                                      : AppColors.accent3,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: event.fillRate,
                          backgroundColor: AppColors.surfaceElevated,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            event.fillRate > 0.8
                                ? AppColors.accent2
                                : AppColors.accent3,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1);
  }
}

class _EventDetailSheet extends StatelessWidget {
  final Event event;
  const _EventDetailSheet({required this.event});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppUtils.colorFromStatus(event.status);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2))),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(event.category,
                                  style: const TextStyle(
                                      color: AppColors.primary, fontSize: 12)),
                            ],
                          ),
                        ),
                        StatusBadge(label: event.status, color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(event.description,
                        style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            height: 1.6)),
                    const SizedBox(height: 20),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 16),
                    _row(
                        Icons.location_on_outlined, 'Location', event.location),
                    _row(Icons.calendar_today_outlined, 'Start',
                        AppUtils.formatDateTime(event.startDate)),
                    _row(Icons.event_outlined, 'End',
                        AppUtils.formatDateTime(event.endDate)),
                    _row(Icons.person_outlined, 'Organizer', event.organizer),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                            child: KpiCard(
                          label: 'Registered',
                          value:
                              '${event.registeredVolunteers}/${event.targetVolunteers}',
                          color: AppColors.primary,
                          progressValue: event.fillRate,
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: KpiCard(
                          label: 'Attended',
                          value: event.attendedVolunteers > 0
                              ? '${(event.attendanceRate * 100).toStringAsFixed(0)}%'
                              : 'N/A',
                          color: AppColors.accent2,
                        )),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (event.tags.isNotEmpty) ...[
                      const Text('Tags',
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: event.tags
                            .map((t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text('#$t',
                                      style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11)),
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 32),
                    GradientButton(
                      label: 'Manage Volunteers',
                      onPressed: () => Navigator.pop(context),
                      width: double.infinity,
                      icon: Icons.people_rounded,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Text('$label: ',
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ),
          ],
        ),
      );
}
