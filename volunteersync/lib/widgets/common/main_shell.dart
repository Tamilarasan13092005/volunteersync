import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  bool _sidebarExpanded = true;

  static final List<_NavItem> _navItems = [
    const _NavItem(
        icon: Icons.dashboard_rounded,
        label: 'Dashboard',
        route: AppRouter.dashboard),
    const _NavItem(
        icon: Icons.people_rounded,
        label: 'Volunteers',
        route: AppRouter.volunteers),
    const _NavItem(
        icon: Icons.event_rounded, label: 'Events', route: AppRouter.events),
    const _NavItem(
        icon: Icons.fact_check_rounded,
        label: 'Attendance',
        route: AppRouter.attendance),
    const _NavItem(
        icon: Icons.analytics_rounded,
        label: 'Reports',
        route: AppRouter.reports),
    const _NavItem(
        icon: Icons.auto_awesome_rounded,
        label: 'AI Assistant',
        route: AppRouter.aiChat,
        isPrimary: true),
    const _NavItem(
        icon: Icons.settings_rounded,
        label: 'Settings',
        route: AppRouter.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = AppUtils.isMobile(context);

    if (isMobile) {
      return _MobileShell(navItems: _navItems, child: widget.child);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _Sidebar(
            expanded: _sidebarExpanded,
            navItems: _navItems,
            onToggle: () =>
                setState(() => _sidebarExpanded = !_sidebarExpanded),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final bool expanded;
  final List<_NavItem> navItems;
  final VoidCallback onToggle;

  const _Sidebar({
    required this.expanded,
    required this.navItems,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final auth = context.read<AuthProvider>();

    return AnimatedContainer(
      duration: AppConstants.durationMedium,
      curve: Curves.easeInOut,
      width: expanded ? AppConstants.sidebarWidth : 72,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.hub_rounded,
                      color: Colors.white, size: 22),
                ),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              children: [
                ...navItems.map((item) => _SidebarItem(
                      item: item,
                      isActive: location == item.route,
                      expanded: expanded,
                      onTap: () => context.go(item.route),
                    )),
              ],
            ),
          ),

          const Divider(height: 1),

          // User info + collapse
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    AppUtils.initials(auth.user?.name ?? 'U'),
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (expanded) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.user?.name ?? '',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          auth.user?.role ?? '',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded,
                        size: 18, color: AppColors.textMuted),
                    onPressed: () async {
                      await auth.signOut();
                      if (context.mounted) context.go(AppRouter.login);
                    },
                    tooltip: 'Sign out',
                  ),
                ],
              ],
            ),
          ),

          // Collapse toggle
          InkWell(
            onTap: onToggle,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Icon(
                expanded
                    ? Icons.keyboard_double_arrow_left_rounded
                    : Icons.keyboard_double_arrow_right_rounded,
                color: AppColors.textMuted,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final bool expanded;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isActive,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: AppConstants.durationFast,
            padding: EdgeInsets.symmetric(
              horizontal: expanded ? 12 : 8,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isActive
                  ? (item.isPrimary
                      ? AppColors.primary.withOpacity(0.15)
                      : AppColors.primary.withOpacity(0.12))
                  : Colors.transparent,
              gradient: isActive && item.isPrimary
                  ? LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.2),
                        AppColors.secondary.withOpacity(0.15)
                      ],
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: isActive
                      ? (item.isPrimary
                          ? AppColors.primaryLight
                          : AppColors.primary)
                      : AppColors.textMuted,
                ),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: isActive
                            ? (item.isPrimary
                                ? AppColors.primaryLight
                                : AppColors.textPrimary)
                            : AppColors.textMuted,
                        fontSize: 14,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (item.isPrimary)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileShell extends StatelessWidget {
  final Widget child;
  final List<_NavItem> navItems;

  const _MobileShell({required this.child, required this.navItems});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final mainItems =
        navItems.where((n) => n.label != 'Settings').take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: mainItems.map((item) {
                final isActive = location == item.route;
                return GestureDetector(
                  onTap: () => context.go(item.route),
                  child: AnimatedContainer(
                    duration: AppConstants.durationFast,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textMuted,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  final bool isPrimary;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.isPrimary = false,
  });
}
