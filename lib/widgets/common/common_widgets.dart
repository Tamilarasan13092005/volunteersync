import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

// ── Gradient Button ────────────────────────────────────────────────────────
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final Gradient? gradient;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          child: Ink(
            decoration: BoxDecoration(
              gradient: onPressed == null
                  ? const LinearGradient(
                      colors: [Color(0xFF334155), Color(0xFF334155)])
                  : (gradient ?? AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, size: 18, color: Colors.white),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Glass Card ────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color? color;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.color,
    this.borderRadius = AppConstants.radiusXL,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color ?? AppColors.surface,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.border),
          ),
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────
class AppSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppColors.textMuted, size: 20),
        hintStyle: const TextStyle(color: AppColors.textDisabled),
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────
class AppAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color? color;

  const AppAvatar({
    super.key,
    required this.name,
    this.radius = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    String initials(String n) {
      final parts = n.trim().split(' ');
      if (parts.isEmpty) return '?';
      if (parts.length == 1) return parts[0][0].toUpperCase();
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }

    final avatarColors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent1,
      AppColors.accent2,
      AppColors.accent5,
    ];
    final c = color ?? avatarColors[name.length % avatarColors.length];

    return CircleAvatar(
      radius: radius,
      backgroundColor: c.withOpacity(0.2),
      child: Text(
        initials(name),
        style: TextStyle(
          color: c,
          fontSize: radius * 0.65,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ── Shimmer Loading ───────────────────────────────────────────────────────
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceElevated,
      highlightColor: AppColors.surfaceHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              GradientButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}

// ── Filter Chip Row ───────────────────────────────────────────────────────
class FilterChipRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const FilterChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          final isSelected = opt == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(opt),
              child: AnimatedContainer(
                duration: AppConstants.durationFast,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  opt.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
