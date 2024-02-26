import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/search_controller.dart';
import 'package:flutter_gtt/models/gtt/stop.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class SearchPage extends StatelessWidget {
  SearchPage({super.key});
  final _searchController = Get.find<SearchStopsController>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 18.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TypeAheadField<Stop>(
            animationDuration: const Duration(milliseconds: 100),
            itemBuilder: (context, stop) {
              return ListTile(
                title: Text(stop.name),
                subtitle: Text(stop.code.toString()),
              );
            },
            builder: (context, controller, focusNode) {
              _searchController.setTextController(controller);
              _searchController.setFocusNode(focusNode);
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: Divider.createBorderSide(context)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  filled: true,
                  labelText: 'Cerca fermata...',
                ),
                keyboardType: TextInputType.text,
                onSubmitted: (value) => _searchController.onSubmitted(value),
              );
            },
            loadingBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
            hideOnEmpty: true,
            debounceDuration: const Duration(milliseconds: 400),
            onSelected: (stop) {
              // so it calls clear on the searchController
              _searchController.onSubmitted(stop.code.toString());
            },
            suggestionsCallback: _searchController.getStopsFromValue,
          ),
        ],
      ),
    );
  }
}
