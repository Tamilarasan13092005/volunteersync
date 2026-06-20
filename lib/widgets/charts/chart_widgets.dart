import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';

// ── Line / Area Chart ──────────────────────────────────────────────────────
class VolunteerGrowthChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const VolunteerGrowthChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = data
        .asMap()
        .entries
        .map((e) =>
            FlSpot(e.key.toDouble(), (e.value['count'] as int).toDouble()))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 50,
              reservedSize: 40,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox();
                return Text(
                  data[idx]['month'] as String,
                  style:
                      const TextStyle(color: AppColors.textMuted, fontSize: 11),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.primary,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.25),
                  AppColors.primary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        minY: 150,
      ),
    );
  }
}

// ── Bar Chart ─────────────────────────────────────────────────────────────
class AttendanceBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const AttendanceBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 50,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              reservedSize: 32,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox();
                return Text(
                  data[idx]['day'] as String,
                  style:
                      const TextStyle(color: AppColors.textMuted, fontSize: 11),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          final present = (e.value['present'] as int).toDouble();
          final absent = (e.value['absent'] as int).toDouble();
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: present,
                color: AppColors.primary,
                width: 10,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: absent,
                color: AppColors.accent4.withOpacity(0.6),
                width: 10,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Pie Chart ─────────────────────────────────────────────────────────────
class CategoryPieChart extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const CategoryPieChart({super.key, required this.data});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touched = -1;
                    } else {
                      _touched = response.touchedSection!.touchedSectionIndex;
                    }
                  });
                },
              ),
              sections: widget.data.asMap().entries.map((e) {
                final isTouched = e.key == _touched;
                return PieChartSectionData(
                  value: e.value['value'] as double,
                  color: Color(e.value['color'] as int),
                  radius: isTouched ? 65 : 55,
                  title: isTouched
                      ? '${(e.value['value'] as double).toStringAsFixed(0)}%'
                      : '',
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 40,
              sectionsSpace: 3,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.data.map((d) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(d['color'] as int),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    d['label'] as String,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(d['value'] as double).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Hours Line Chart ──────────────────────────────────────────────────────
class HoursLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const HoursLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = data
        .asMap()
        .entries
        .map((e) =>
            FlSpot(e.key.toDouble(), (e.value['hours'] as int).toDouble()))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (v, _) => Text(
                '${(v / 1000).toStringAsFixed(1)}K',
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox();
                return Text(data[idx]['month'] as String,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 10));
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.secondary,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withOpacity(0.2),
                  AppColors.secondary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        minY: 1000,
      ),
    );
  }
}
