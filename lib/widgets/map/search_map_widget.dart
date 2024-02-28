import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/search/search_controller.dart';
import 'package:flutter_gtt/models/map/address.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SearchAddress extends StatelessWidget {
  final MapSearchController searchController;
  const SearchAddress({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
      width: double.infinity,
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TypeAheadField<Address>(
            controller: searchController.controller,
            suggestionsController: searchController.suggestionsController,
            hideOnUnfocus: false,
            hideWithKeyboard: false,
            hideOnSelect: true,
            animationDuration: const Duration(milliseconds: 100),
            itemBuilder: (context, address) {
              return ListTile(
                title: Text(address.toDetailedString(
                    showCity: true, showHouseNumber: true)),
              );
            },
            builder: (context, controller, focusNode) {
              searchController.listenUnfocus(focusNode);
              return TextField(
                autofocus: true,
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: Divider.createBorderSide(context)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  filled: true,
                  labelText: 'Cerca indirizzo...',
                ),
                keyboardType: TextInputType.text,
                onSubmitted: searchController.onSearch,
              );
            },
            loadingBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
            hideOnEmpty: true,
            debounceDuration: const Duration(milliseconds: 600),
            onSelected: searchController.onSelected,
            suggestionsCallback: (val) => searchController.getSuggestions(val),
          ),
        ],
      ),
    );
  }
}
