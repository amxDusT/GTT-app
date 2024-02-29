import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/search/search_controller.dart';
import 'package:flutter_gtt/models/map/address.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

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
            itemSeparatorBuilder: (context, index) => Divider(
              indent: context.width * 0.18,
              height: 1.0,
            ),
            controller: searchController.controller,
            suggestionsController: searchController.suggestionsController,
            hideOnUnfocus: false,
            hideWithKeyboard: false,
            animationDuration: Duration.zero,
            hideOnEmpty: true,
            debounceDuration: const Duration(milliseconds: 300),
            onSelected: searchController.onSelected,
            suggestionsCallback: (val) => searchController.getSuggestions(val),
            loadingBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
            itemBuilder: (context, address) {
              return ListTile(
                contentPadding: const EdgeInsets.only(
                  left: 12.0,
                  right: 8.0,
                ),
                minVerticalPadding: 0.0,
                dense: true,
                title: Text(
                  address.toDetailedString(
                    showCity: false,
                    showHouseNumber: true,
                  ),
                ),
                subtitle: Text(address.toDetailedString(
                  showStreet: false,
                  showCity: true,
                  showProvince: true,
                )),
                leading: SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on),
                      Text(
                        address.distanceString,
                        style: const TextStyle(letterSpacing: -0.5),
                      ),
                    ],
                  ),
                ),
                trailing: GestureDetector(
                    onTap: () {
                      searchController.addToText(address);
                    },
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.north_west),
                    )),
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
                  suffixIcon: IconButton(
                    onPressed: () {
                      controller.clear();
                      searchController.suggestionsController
                          .close(retainFocus: true);
                      //searchController.suggestionsController.refresh();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
                keyboardType: TextInputType.text,
                onSubmitted: searchController.onSearch,
              );
            },
          ),
        ],
      ),
    );
  }
}
