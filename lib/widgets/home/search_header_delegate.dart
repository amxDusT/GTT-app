import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/search/home_search_controller.dart';

class SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget searchWidget;
  final SearchStopsController searchController;
  final double maxHeight;
  final double minHeight;
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Widget firstAction;
  final Icon icon;
  SearchHeaderDelegate({
    required this.searchWidget,
    this.maxHeight = 150,
    required this.searchController,
    this.backgroundColor,
    this.title,
    this.leading,
    this.actions,
    this.minHeight = 100,
    this.icon = const Icon(Icons.search),
    VoidCallback? onSearch,
  }) : firstAction = IconButton(
          icon: icon,
          onPressed: onSearch ?? searchController.searchButton,
        ) {
    assert(maxHeight >= minHeight, 'maxHeight must be >= minHeight');
  }

  static const double _defaultOpacityBreak = 0.6;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final defaultOp = defaultOpacity(shrinkOffset);
    final inverseOpacity = 1.0 - defaultOp;
    final isSearching = searchController.focusNode?.hasFocus ?? false;

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        Container(
          color: backgroundColor,
        ),
        if (title != null && (!isSearching || defaultOp > _defaultOpacityBreak))
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: AppBar(
              scrolledUnderElevation: 0.0,
              backgroundColor: Colors.transparent,
              title: title,
              leading: leading,
              actions: [
                Opacity(
                  opacity: iconOpacity(defaultOp),
                  child: firstAction,
                ),
                if (actions != null) ...actions!,
              ],
              elevation: 0,
            ),
          ),
        Positioned(
          right: isSearching ? 0 : inverseOpacity * 50,
          left: isSearching ? 0 : inverseOpacity * 300,
          bottom: 0,
          child: Opacity(
            opacity: isSearching ? 1.0 : childOpacity(defaultOp),
            child: searchWidget,
          ),
        ),
      ],
    );
  }

  double iconOpacity(double defaultOpacity) {
    return defaultOpacity < _defaultOpacityBreak
        ? defaultOpacity == 0
            ? 1.0
            : _defaultOpacityBreak - defaultOpacity
        : 0;
  }

  double childOpacity(double defaultOpacity) {
    return defaultOpacity < 0.2 ? 0.0 : defaultOpacity;
  }

  double defaultOpacity(double shrinkOffset) {
    return (1.0 - max(0.0, shrinkOffset) / (maxExtent - minExtent))
        .clamp(0.0, 1.0);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
