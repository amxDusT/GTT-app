import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/route_list_controller.dart';
import 'package:flutter_gtt/controllers/search/list_search_controller.dart';
import 'package:flutter_gtt/models/gtt/route.dart' as gtt;
import 'package:flutter_gtt/widgets/route_list_tile_widget.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class ListSearchPage extends StatelessWidget {
  final RouteListController controller;
  final ListSearchController searchController;
  const ListSearchPage({
    super.key,
    required this.controller,
    required this.searchController,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 18.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TypeAheadField<gtt.Route>(
            animationDuration: const Duration(milliseconds: 100),
            itemBuilder: (context, route) {
              return RouteListTile(route: route, controller: controller);
            },
            builder: (context, controller, focusNode) {
              searchController.setSearchController(controller);
              searchController.listenUnfocus(focusNode);
              return TextField(
                //autofocus: true,
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: Divider.createBorderSide(context)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  filled: true,
                  labelText: 'Cerca veicolo...',
                ),
                keyboardType: TextInputType.text,
                onSubmitted: (value) => searchController.onSearch(value),
              );
            },
            loadingBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
            hideOnEmpty: true,
            debounceDuration: const Duration(milliseconds: 100),
            onSelected: (route) {},
            suggestionsCallback: (val) => searchController.getSuggestions(val),
          ),
        ],
      ),
    );
  }
}
