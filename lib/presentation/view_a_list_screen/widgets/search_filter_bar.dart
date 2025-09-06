import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchFilterBar extends StatefulWidget {
  final String searchQuery;
  final String selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback? onClearSearch;

  const SearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
    this.onClearSearch,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _filterOptions = [
    {'value': 'Todos', 'label': 'Todos'},
    {'value': 'Pendiente', 'label': 'Pendiente'},
    {'value': 'En reparto', 'label': 'En reparto'},
    {'value': 'Entregado', 'label': 'Entregado'},
    {'value': 'Entrega incompleta', 'label': 'Entrega incompleta'},
    {'value': 'Devuelto', 'label': 'Devuelto'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar pedidos...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                suffixIcon: widget.searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          widget.onClearSearch?.call();
                          _searchFocusNode.unfocus();
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.5.h,
                ),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          // Filter Chips
          // Filter Chips con scroll + flechas
          SizedBox(
            height: 5.h,
            child: Stack(
              children: [
                // Scroll horizontal
                ListView.separated(
                  controller: _scrollController, // 👈 importante
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 8.w), // espacio para flechas
                  itemCount: _filterOptions.length,
                  separatorBuilder: (context, index) => SizedBox(width: 2.w),
                  itemBuilder: (context, index) {
                    final filter = _filterOptions[index];
                    final isSelected = widget.selectedFilter == filter['value'];

                    return FilterChip(
                      label: Text(
                        filter['label']!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          widget.onFilterChanged(filter['value']!);
                        }
                      },
                      backgroundColor: colorScheme.surface,
                      selectedColor: colorScheme.primary,
                      checkmarkColor: colorScheme.onPrimary,
                      side: BorderSide(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  },
                ),

                // Flecha izquierda
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 8.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          colorScheme.surface,
                          colorScheme.surface.withValues(alpha: 0),
                        ],
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios, size: 18, color: colorScheme.primary),
                      onPressed: () {
                        _scrollController.animateTo(
                          _scrollController.offset - 100, // desplazamiento hacia atrás
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
                  ),
                ),

                // Flecha derecha
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 8.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          colorScheme.surface,
                          colorScheme.surface.withValues(alpha: 0),
                        ],
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios, size: 18, color: colorScheme.primary),
                      onPressed: () {
                        _scrollController.animateTo(
                          _scrollController.offset + 100, // desplazamiento hacia adelante
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
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
}
