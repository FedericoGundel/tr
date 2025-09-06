import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Navigation item data structure for bottom navigation
class NavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;

  const NavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Custom BottomNavigationBar implementing adaptive navigation architecture
/// with gesture-enhanced interaction and contextual action revelation.
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final bool showLabels;
  final double? elevation;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.showLabels = true,
    this.elevation,
  });

  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      route: '/dashboard-screen',
    ),
    NavigationItem(
      icon: Icons.list_alt_outlined,
      activeIcon: Icons.list_alt,
      label: 'Lists',
      route: '/view-a-list-screen',
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Analytics',
      route: '/dashboard-screen', // Fallback to dashboard for now
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: '/dashboard-screen', // Fallback to dashboard for now
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex.clamp(0, _navigationItems.length - 1),
          onTap: (index) => _handleNavigation(context, index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: colorScheme.surface,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurfaceVariant,
          elevation: elevation ?? 0,
          showSelectedLabels: showLabels,
          showUnselectedLabels: showLabels,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
          ),
          items: _navigationItems
              .map((item) => _buildNavigationItem(
                    context,
                    item,
                    _navigationItems.indexOf(item) == currentIndex,
                  ))
              .toList(),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavigationItem(
    BuildContext context,
    NavigationItem item,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BottomNavigationBarItem(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: Container(
          key: ValueKey(isSelected),
          padding: const EdgeInsets.all(8),
          decoration: isSelected
              ? BoxDecoration(
                  color: colorScheme.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Icon(
            isSelected ? (item.activeIcon ?? item.icon) : item.icon,
            size: 24,
            color:
                isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      label: item.label,
      tooltip: item.label,
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) {
      // If tapping the same tab, scroll to top or refresh
      _handleSameTabTap(context, index);
      return;
    }

    // Provide haptic feedback
    _triggerHapticFeedback();

    // Navigate to the selected route
    final selectedItem = _navigationItems[index];
    Navigator.pushNamedAndRemoveUntil(
      context,
      selectedItem.route,
      (route) => route.isFirst,
    );

    // Call the onTap callback if provided
    onTap?.call(index);
  }

  void _handleSameTabTap(BuildContext context, int index) {
    // Handle same tab tap - could scroll to top, refresh, etc.
    final selectedItem = _navigationItems[index];

    // Show a subtle feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedItem.label} refreshed'),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 80,
          left: 16,
          right: 16,
        ),
      ),
    );
  }

  void _triggerHapticFeedback() {
    // Light haptic feedback for navigation
    // Note: You might want to add haptic_feedback package for more control
    // HapticFeedback.lightImpact();
  }

  /// Get the current route index based on the route name
  static int getIndexForRoute(String routeName) {
    for (int i = 0; i < _navigationItems.length; i++) {
      if (_navigationItems[i].route == routeName) {
        return i;
      }
    }
    return 0; // Default to first tab
  }

  /// Get the route name for a given index
  static String getRouteForIndex(int index) {
    if (index >= 0 && index < _navigationItems.length) {
      return _navigationItems[index].route;
    }
    return _navigationItems[0].route; // Default to first route
  }
}
