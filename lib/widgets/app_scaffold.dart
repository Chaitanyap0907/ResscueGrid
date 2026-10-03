import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/constants/dimensions.dart';
import '../data/models/enums.dart';
import '../data/mock/rescue_grid_state.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final UserRole role;

  const AppScaffold({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= RgDimensions.mobileBreakpoint;
    final state = context.watch<RescueGridState>();

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _buildNavigationRail(context, state),
            const VerticalDivider(thickness: 1, width: 1, color: RgColors.border),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomBar(context, state),
    );
  }

  Widget _buildNavigationRail(BuildContext context, RescueGridState state) {
    return Container(
      width: 220,
      color: RgColors.primary,
      child: Column(
        children: [
          // Branded header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: RgColors.primaryAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      PhosphorIconsFill.shieldWarning,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RescueGrid',
                        style: RgTypography.subheading.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        role.displayName,
                        style: RgTypography.caption.copyWith(
                          color: const Color(0xFF8DA4C4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Color(0xFF1E3A5F), height: 1),
          const SizedBox(height: 12),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: _getNavItems(role, state.unreadNotificationCount).asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onItemTapped(context, index, role),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? RgColors.primaryAccent : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: isSelected ? Colors.white : const Color(0xFF8DA4C4),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.label,
                                style: RgTypography.bodyMedium.copyWith(
                                  color: isSelected ? Colors.white : const Color(0xFF8DA4C4),
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (item.badgeCount != null && item.badgeCount! > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: RgColors.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${item.badgeCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Bottom Rail Info: Logged-in User Profile & Sign Out
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFF081B33),
              border: Border(top: BorderSide(color: Color(0xFF1E3A5F))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: RgColors.primaryAccent,
                      child: Text(
                        state.currentUser.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.currentUser.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            role.displayName,
                            style: const TextStyle(
                              color: Color(0xFF8DA4C4),
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => context.go('/login'),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(PhosphorIconsRegular.signOut, color: Color(0xFFE63946), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Sign Out',
                          style: RgTypography.caption.copyWith(
                            color: const Color(0xFFE63946),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, RescueGridState state) {
    final items = _getNavItems(role, state.unreadNotificationCount);

    return NavigationBar(
      selectedIndex: selectedIndex.clamp(0, items.length - 1),
      onDestinationSelected: (idx) => _onItemTapped(context, idx, role),
      destinations: items.map((item) {
        return NavigationDestination(
          icon: Badge(
            isLabelVisible: item.badgeCount != null && item.badgeCount! > 0,
            label: Text('${item.badgeCount}'),
            backgroundColor: RgColors.secondary,
            child: Icon(item.icon),
          ),
          label: item.label,
        );
      }).toList(),
    );
  }

  List<_NavDestinationItem> _getNavItems(UserRole currentRole, [int? unreadCount]) {
    switch (currentRole) {
      case UserRole.student:
        return [
          const _NavDestinationItem(label: 'Home', icon: PhosphorIconsRegular.house),
          const _NavDestinationItem(label: 'My Reports', icon: PhosphorIconsRegular.clockCounterClockwise),
          _NavDestinationItem(label: 'Alerts', icon: PhosphorIconsRegular.bell, badgeCount: unreadCount),
          const _NavDestinationItem(label: 'Profile', icon: PhosphorIconsRegular.user),
        ];
      case UserRole.responder:
        return const [
          _NavDestinationItem(label: 'Dashboard', icon: PhosphorIconsRegular.shieldCheck),
          _NavDestinationItem(label: 'Active', icon: PhosphorIconsRegular.navigationArrow),
          _NavDestinationItem(label: 'History', icon: PhosphorIconsRegular.listDashes),
          _NavDestinationItem(label: 'Profile', icon: PhosphorIconsRegular.user),
        ];
      case UserRole.admin:
        return const [
          _NavDestinationItem(label: 'Command', icon: PhosphorIconsRegular.desktop),
          _NavDestinationItem(label: 'Incidents', icon: PhosphorIconsRegular.warningOctagon),
          _NavDestinationItem(label: 'Responders', icon: PhosphorIconsRegular.usersThree),
          _NavDestinationItem(label: 'Statistics', icon: PhosphorIconsRegular.chartLineUp),
        ];
    }
  }

  void _onItemTapped(BuildContext context, int index, UserRole currentRole) {
    switch (currentRole) {
      case UserRole.student:
        switch (index) {
          case 0:
            context.go('/student');
            break;
          case 1:
            context.go('/student/reports');
            break;
          case 2:
            context.go('/notifications');
            break;
          case 3:
            context.go('/profile');
            break;
        }
        break;

      case UserRole.responder:
        switch (index) {
          case 0:
            context.go('/responder');
            break;
          case 1:
            context.go('/responder/active');
            break;
          case 2:
            context.go('/responder/history');
            break;
          case 3:
            context.go('/profile');
            break;
        }
        break;

      case UserRole.admin:
        switch (index) {
          case 0:
            context.go('/admin');
            break;
          case 1:
            context.go('/admin/incidents');
            break;
          case 2:
            context.go('/admin/responders');
            break;
          case 3:
            context.go('/admin/statistics');
            break;
        }
        break;
    }
  }
}

class _NavDestinationItem {
  final String label;
  final IconData icon;
  final int? badgeCount;

  const _NavDestinationItem({
    required this.label,
    required this.icon,
    this.badgeCount,
  });
}
