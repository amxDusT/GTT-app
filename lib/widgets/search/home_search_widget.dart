import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/home_controller.dart';
import 'package:torino_mobility/controllers/search/home_search_controller.dart';
import 'package:torino_mobility/models/gtt/stop.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class SearchStop extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  const SearchStop({
    super.key,
    required this.searchController,
    this.padding,
  });
  final SearchStopsController searchController;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TypeAheadField<Stop>(
            animationDuration: const Duration(milliseconds: 100),
            itemBuilder: (context, stop) {
              return GetBuilder<HomeController>(
                  builder: (controller) => ListTile(
                        title: Text(stop.name),
                        subtitle: Text(stop.code.toString()),
                        trailing: IconButton(
                          onPressed: () =>
                              controller.switchAddDeleteFermata(stop),
                          icon: controller.fermate.contains(stop)
                              ? const Icon(Icons.star)
                              : const Icon(Icons.star_border),
                        ),
                      ));
            },
            builder: (context, controller, focusNode) {
              searchController.setTextController(controller);
              searchController.setFocusNode(focusNode);

              return Obx(
                () => TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: Divider.createBorderSide(context)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    filled: true,
                    labelText: 'Cerca fermata...',
                    prefixIcon: searchController.showLeadingIcon.isTrue
                        ? IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              if (focusNode.hasFocus) {
                                focusNode.unfocus();
                              }
                            },
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.text,
                  onSubmitted: (value) => searchController.onSubmitted(value),
                ),
              );
            },
            loadingBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
            hideOnEmpty: true,
            debounceDuration: const Duration(milliseconds: 400),
            onSelected: (stop) {
              // so it calls clear on the searchController
              searchController.onSubmitted(stop.code.toString());
            },
            suggestionsCallback: searchController.getStopsFromValue,
          ),
        ],
      ),
    );
  }
}
