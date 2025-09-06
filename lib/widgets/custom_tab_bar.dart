import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tab item data structure for custom tab bar
class TabItem {
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final String? route;
  final VoidCallback? onTap;

  const TabItem({
    required this.label,
    this.icon,
    this.customIcon,
    this.route,
    this.onTap,
  });
}

/// Custom TabBar widget implementing intelligent loading hierarchies
/// and contextual action revelation with smooth transitions.
class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<TabItem> tabs;
  final TabController? controller;
  final bool isScrollable;
  final EdgeInsetsGeometry? labelPadding;
  final Color? indicatorColor;
  final double indicatorWeight;
  final TabBarIndicatorSize indicatorSize;
  final ValueChanged<int>? onTap;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
    this.labelPadding,
    this.indicatorColor,
    this.indicatorWeight = 2.0,
    this.indicatorSize = TabBarIndicatorSize.label,
    this.onTap,
  });

  /// Factory constructor for dashboard tabs
  factory CustomTabBar.dashboard({
    TabController? controller,
    ValueChanged<int>? onTap,
  }) {
    return CustomTabBar(
      controller: controller,
      onTap: onTap,
      tabs: const [
        TabItem(
          label: 'Overview',
          icon: Icons.dashboard_outlined,
        ),
        TabItem(
          label: 'Analytics',
          icon: Icons.analytics_outlined,
        ),
        TabItem(
          label: 'Reports',
          icon: Icons.assessment_outlined,
        ),
        TabItem(
          label: 'Settings',
          icon: Icons.settings_outlined,
        ),
      ],
    );
  }

  /// Factory constructor for list view tabs
  factory CustomTabBar.listView({
    TabController? controller,
    ValueChanged<int>? onTap,
  }) {
    return CustomTabBar(
      controller: controller,
      onTap: onTap,
      isScrollable: true,
      tabs: const [
        TabItem(
          label: 'All Items',
          icon: Icons.list_alt_outlined,
        ),
        TabItem(
          label: 'Active',
          icon: Icons.check_circle_outline,
        ),
        TabItem(
          label: 'Pending',
          icon: Icons.schedule_outlined,
        ),
        TabItem(
          label: 'Completed',
          icon: Icons.done_all_outlined,
        ),
        TabItem(
          label: 'Archived',
          icon: Icons.archive_outlined,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withAlpha(51),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs.map((tab) => _buildTab(context, tab)).toList(),
        isScrollable: isScrollable,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: indicatorColor ?? colorScheme.primary,
        indicatorWeight: indicatorWeight,
        indicatorSize: indicatorSize,
        labelPadding: labelPadding ??
            (isScrollable ? const EdgeInsets.symmetric(horizontal: 20) : null),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        overlayColor: WidgetStateProperty.all(
          colorScheme.primary.withAlpha(26),
        ),
        splashFactory: InkRipple.splashFactory,
        onTap: (index) => _handleTabTap(context, index),
      ),
    );
  }

  Widget _buildTab(BuildContext context, TabItem tabItem) {
    final theme = Theme.of(context);

    if (tabItem.icon != null || tabItem.customIcon != null) {
      return Tab(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: tabItem.customIcon ??
              Icon(
                tabItem.icon,
                size: 20,
              ),
        ),
        text: tabItem.label,
        iconMargin: const EdgeInsets.only(bottom: 4),
      );
    }

    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          tabItem.label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _handleTabTap(BuildContext context, int index) {
    final selectedTab = tabs[index];

    // Handle custom onTap if provided
    if (selectedTab.onTap != null) {
      selectedTab.onTap!();
      return;
    }

    // Handle route navigation if provided
    if (selectedTab.route != null) {
      Navigator.pushNamed(context, selectedTab.route!);
      return;
    }

    // Call the general onTap callback
    onTap?.call(index);

    // Provide subtle feedback
    _showTabFeedback(context, selectedTab.label);
  }

  void _showTabFeedback(BuildContext context, String tabLabel) {
    // Light haptic feedback could be added here
    // HapticFeedback.selectionClick();

    // Optional: Show subtle snackbar for debugging
    if (false) {
      // Set to true for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to $tabLabel'),
          duration: const Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}

/// Custom TabBarView wrapper with smooth transitions
class CustomTabBarView extends StatelessWidget {
  final List<Widget> children;
  final TabController? controller;


  const CustomTabBarView({
    super.key,
    required this.children,
    this.controller,

  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,

      children: children
          .map((child) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: child,
              ))
          .toList(),
    );
  }
}
