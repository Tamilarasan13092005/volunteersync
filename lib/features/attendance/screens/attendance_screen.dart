import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../models/attendance.dart';
import '../../../providers/events_provider.dart';
import '../../../widgets/common/common_widgets.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _loading = true;
  List<AttendanceRecord> _records = [];
  String _searchQuery = '';
  String _filterStatus = 'All';
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final response = await _supabase
          .from('attendance')
          .select()
          .order('created_at', ascending: false);

      _records = (response as List)
          .map<AttendanceRecord>((item) => AttendanceRecord(
                id: item['id'] ?? '',
                volunteerId: item['volunteer_id'] ?? '',
                volunteerName: item['volunteer_name'] ?? '',
                eventId: item['event_id'] ?? '',
                eventTitle: item['event_title'] ?? '',
                checkInTime: DateTime.parse(
                    item['checked_in_at'] ?? DateTime.now().toIso8601String()),
                status: item['status'] ?? 'present',
                hoursLogged: item['hours_logged'] ?? 0,
              ))
          .toList();

      if (_records.isEmpty) {
        final now = DateTime.now();
        _records = [
          AttendanceRecord(
            id: 'rec-1',
            volunteerId: 'v-1',
            volunteerName: 'Alex Mercer',
            eventId: 'mock-1',
            eventTitle: 'Community Park Cleanup',
            checkInTime: now.subtract(const Duration(days: 2, hours: 3, minutes: 45)),
            status: 'present',
            hoursLogged: 3,
          ),
          AttendanceRecord(
            id: 'rec-2',
            volunteerId: 'v-2',
            volunteerName: 'Jane Doe',
            eventId: 'mock-1',
            eventTitle: 'Community Park Cleanup',
            checkInTime: now.subtract(const Duration(days: 2, hours: 3, minutes: 30)),
            status: 'late',
            hoursLogged: 3,
          ),
          AttendanceRecord(
            id: 'rec-3',
            volunteerId: 'v-3',
            volunteerName: 'Robert Chen',
            eventId: 'mock-1',
            eventTitle: 'Community Park Cleanup',
            checkInTime: now.subtract(const Duration(days: 2, hours: 4)),
            status: 'present',
            hoursLogged: 3,
          ),
          AttendanceRecord(
            id: 'rec-4',
            volunteerId: 'v-4',
            volunteerName: 'Emily Watson',
            eventId: 'mock-2',
            eventTitle: 'Downtown Food Drive',
            checkInTime: now.subtract(const Duration(days: 1, hours: 2, minutes: 50)),
            status: 'present',
            hoursLogged: 3,
          ),
          AttendanceRecord(
            id: 'rec-5',
            volunteerId: 'v-5',
            volunteerName: 'Michael Chang',
            eventId: 'mock-2',
            eventTitle: 'Downtown Food Drive',
            checkInTime: now.subtract(const Duration(days: 1, hours: 2, minutes: 15)),
            status: 'absent',
            hoursLogged: 0,
          ),
          AttendanceRecord(
            id: 'rec-6',
            volunteerId: 'v-6',
            volunteerName: 'Sarah Jenkins',
            eventId: 'mock-2',
            eventTitle: 'Downtown Food Drive',
            checkInTime: now.subtract(const Duration(days: 1, hours: 2, minutes: 40)),
            status: 'present',
            hoursLogged: 3,
          ),
          AttendanceRecord(
            id: 'rec-7',
            volunteerId: 'v-7',
            volunteerName: 'David Kim',
            eventId: 'mock-1',
            eventTitle: 'Community Park Cleanup',
            checkInTime: now.subtract(const Duration(days: 2, hours: 3, minutes: 55)),
            status: 'present',
            hoursLogged: 3,
          ),
        ];
      }
    } catch (e) {
      debugPrint('Error loading attendance: $e');
      // Emergency mock data
      final now = DateTime.now();
      _records = [
        AttendanceRecord(
          id: 'rec-err-1',
          volunteerId: 'v-err',
          volunteerName: 'Fallback Volunteer',
          eventId: 'mock-1',
          eventTitle: 'Emergency Community Cleanup',
          checkInTime: now.subtract(const Duration(hours: 1)),
          status: 'present',
          hoursLogged: 2,
        ),
      ];
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  AttendanceSummary get _summary {
    final present = _records.where((r) => r.status == 'present').length;
    final absent = _records.where((r) => r.status == 'absent').length;
    final late = _records.where((r) => r.status == 'late').length;
    final excused = _records.where((r) => r.status == 'excused').length;
    final total = _records.length;
    final rate = total > 0 ? ((present + late) / total) * 100 : 0.0;
    return AttendanceSummary(
      total: total,
      present: present,
      absent: absent,
      late: late,
      excused: excused,
      rate: rate,
    );
  }

  List<AttendanceRecord> get _filteredRecords {
    var list = _records;
    if (_filterStatus != 'All') {
      list = list.where((r) => r.status.toLowerCase() == _filterStatus.toLowerCase()).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) =>
        r.volunteerName.toLowerCase().contains(q) ||
        r.eventTitle.toLowerCase().contains(q)
      ).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
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
                          Text('Attendance',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                          const Text('Track volunteer check-ins',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 14)),
                        ],
                      ),
                    ),
                    GradientButton(
                      label: 'Check In',
                      onPressed: () => _showCheckInDialog(context),
                      icon: Icons.qr_code_scanner_rounded,
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 20),
                if (!_loading) _SummaryRow(summary: _summary),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    controller: _tabCtrl,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Recent Records'),
                      Tab(text: 'By Event'),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),
                if (!_loading) ...[
                  Row(
                    children: [
                      Expanded(
                        child: AppSearchBar(
                          hint: 'Search volunteers or events...',
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Present', 'Late', 'Absent'].map((status) {
                        final isSelected = _filterStatus == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _filterStatus = status;
                                });
                              }
                            },
                            backgroundColor: AppColors.surface,
                            selectedColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? _buildShimmer()
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _RecordsList(records: _filteredRecords),
                      _EventAttendanceList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() => ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) =>
            const ShimmerBox(width: double.infinity, height: 80),
      );

  void _showCheckInDialog(BuildContext context) {
    final events = context.read<EventsProvider>().events;
    showDialog(
      context: context,
      builder: (_) => _CheckInDialog(
        events: events.map((e) => e.title).toList(),
        eventIds: events.map((e) => e.id).toList(),
        onCheckIn: (name, eventTitle, eventId) async {
          try {
            await _supabase.from('attendance').insert({
              'volunteer_name': name,
              'event_id': eventId,
              'event_title': eventTitle,
              'volunteer_id': 'manual',
              'status': 'present',
              'checked_in_at': DateTime.now().toIso8601String(),
              'hours_logged': 0,
            });
            await _load();
            if (context.mounted) {
              AppUtils.showSnackBar(context, '$name checked in successfully!');
            }
          } catch (e) {
            debugPrint('Check in error: $e');
          }
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final AttendanceSummary summary;
  const _SummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _SummaryChip(
                label: 'Present',
                value: summary.present.toString(),
                color: AppColors.accent2)),
        const SizedBox(width: 10),
        Expanded(
            child: _SummaryChip(
                label: 'Late',
                value: summary.late.toString(),
                color: AppColors.accent3)),
        const SizedBox(width: 10),
        Expanded(
            child: _SummaryChip(
                label: 'Absent',
                value: summary.absent.toString(),
                color: AppColors.accent4)),
        const SizedBox(width: 10),
        Expanded(
            child: _SummaryChip(
                label: 'Rate',
                value: '${summary.rate.toStringAsFixed(0)}%',
                color: AppColors.primary)),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _RecordsList extends StatelessWidget {
  final List<AttendanceRecord> records;
  const _RecordsList({required this.records});

  Color _statusColor(String s) {
    switch (s) {
      case 'present':
        return AppColors.accent2;
      case 'late':
        return AppColors.accent3;
      case 'absent':
        return AppColors.accent4;
      default:
        return AppColors.textMuted;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'present':
        return Icons.check_circle_rounded;
      case 'late':
        return Icons.watch_later_rounded;
      case 'absent':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const EmptyState(
        icon: Icons.fact_check_outlined,
        title: 'No records yet',
        subtitle: 'Attendance records will appear here',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final r = records[i];
        final c = _statusColor(r.status);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              AppAvatar(name: r.volunteerName, radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.volunteerName,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(r.eventTitle,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.login_rounded,
                            size: 12, color: AppColors.textDisabled),
                        const SizedBox(width: 4),
                        Text(AppUtils.formatTime(r.checkInTime),
                            style: const TextStyle(
                                color: AppColors.textDisabled, fontSize: 11)),
                        if (r.hoursLogged != null && r.hoursLogged! > 0) ...[
                          const SizedBox(width: 10),
                          const Icon(Icons.schedule_rounded,
                              size: 12, color: AppColors.textDisabled),
                          const SizedBox(width: 4),
                          Text('${r.hoursLogged}h',
                              style: const TextStyle(
                                  color: AppColors.textDisabled, fontSize: 11)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(_statusIcon(r.status), color: c, size: 20),
                  const SizedBox(height: 4),
                  Text(r.status.toUpperCase(),
                      style: TextStyle(
                          color: c,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                ],
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: 50 * i))
            .fadeIn(duration: 300.ms);
      },
    );
  }
}

class _EventAttendanceList extends StatefulWidget {
  @override
  State<_EventAttendanceList> createState() => _EventAttendanceListState();
}

class _EventAttendanceListState extends State<_EventAttendanceList> {
  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventsProvider>().events;
    final pastEvents = events.where((e) => e.isPast).toList();

    if (pastEvents.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy_rounded,
        title: 'No past events',
        subtitle: 'Completed events will appear here',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: pastEvents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final e = pastEvents[i];
        final rate = e.attendanceRate;
        final rateColor = rate > 0.9
            ? AppColors.accent2
            : rate > 0.7
                ? AppColors.accent3
                : AppColors.accent4;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(e.title,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                  Text('${(rate * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                          color: rateColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 6),
              Text(AppUtils.formatDate(e.startDate),
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${e.attendedVolunteers} / ${e.registeredVolunteers} attended',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: rate,
                      backgroundColor: AppColors.surfaceElevated,
                      valueColor: AlwaysStoppedAnimation<Color>(rateColor),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: 80 * i)).fadeIn();
      },
    );
  }
}

class _CheckInDialog extends StatefulWidget {
  final List<String> events;
  final List<String> eventIds;
  final void Function(String name, String eventTitle, String eventId) onCheckIn;
  const _CheckInDialog(
      {required this.events, required this.eventIds, required this.onCheckIn});

  @override
  State<_CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends State<_CheckInDialog> {
  final _nameCtrl = TextEditingController();
  late String _selectedEvent;
  late String _selectedEventId;

  @override
  void initState() {
    super.initState();
    _selectedEvent = widget.events.isNotEmpty ? widget.events[0] : '';
    _selectedEventId = widget.eventIds.isNotEmpty ? widget.eventIds[0] : '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.emeraldGradient,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Check In Volunteer',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Volunteer Name',
                prefixIcon: Icon(Icons.person_outline_rounded,
                    color: AppColors.textMuted, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            if (widget.events.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedEvent,
                    dropdownColor: AppColors.surfaceElevated,
                    isExpanded: true,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14),
                    items: widget.events
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      final idx = widget.events.indexOf(v!);
                      setState(() {
                        _selectedEvent = v;
                        _selectedEventId = widget.eventIds[idx];
                      });
                    },
                  ),
                ),
              )
            else
              const Text('No events available. Please create an event first.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
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
                  label: 'Check In',
                  gradient: AppColors.emeraldGradient,
                  onPressed: () {
                    if (_nameCtrl.text.trim().isNotEmpty &&
                        widget.events.isNotEmpty) {
                      Navigator.pop(context);
                      widget.onCheckIn(_nameCtrl.text.trim(), _selectedEvent,
                          _selectedEventId);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
