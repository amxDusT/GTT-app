import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/controllers/search/home_search_controller.dart';

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

    return Obx(() {
      final isSearching = searchController.showLeadingIcon.value;

      return Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Container(
            color: backgroundColor,
          ),
          if (title != null &&
              (!isSearching || defaultOp > _defaultOpacityBreak))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: AppBar(
                scrolledUnderElevation: 0.0,
                backgroundColor: Colors.transparent,
                title: title,
                leading: leading,
                actions: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: defaultOp <= _defaultOpacityBreak ? 1.0 : 0,
                    child: firstAction,
                  ),
                  if (actions != null) ...actions!,
                ],
                elevation: 0,
              ),
            ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 150),
                  offset: isSearching || defaultOp > _defaultOpacityBreak
                      ? Offset.zero
                      : const Offset(0, 0.2),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isSearching
                        ? 1.0
                        : defaultOp > _defaultOpacityBreak
                            ? defaultOp
                            : 0,
                    child: searchWidget,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  double defaultOpacity(double shrinkOffset) {
    final extentRange = maxExtent - minExtent;
    if (extentRange <= 0) {
      return 1.0;
    }

    return (1.0 - max(0.0, shrinkOffset) / extentRange).clamp(0.0, 1.0);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
