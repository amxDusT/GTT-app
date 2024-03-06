import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/search/search_controller.dart';
import 'package:flutter_gtt/models/map/address.dart';
import 'package:flutter_gtt/widgets/map/distance_icon.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class SearchAddress extends StatelessWidget {
  final MapSearchController searchController;
  const SearchAddress({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8.0, right: 8.0, top: context.width * 0.12),
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
            animationDuration: Durations.short1,
            hideOnEmpty: true,
            debounceDuration: const Duration(milliseconds: 300),
            onSelected: searchController.mapAddress.onSelected,
            suggestionsCallback: (val) =>
                searchController.mapAddress.getSuggestions(val),
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
                leading: DistanceWidget(address: address),
                trailing: GestureDetector(
                    onTap: () => searchController.addToText(address),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.north_west),
                    )),
              );
            },
            builder: (context, controller, focusNode) {
              searchController.listenFocus(focusNode);
              return TextField(
                autofocus: false,
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context)
                          .inputDecorationTheme
                          .fillColor
                          ?.withOpacity(0.7) ??
                      Get.theme.colorScheme.surfaceVariant.withOpacity(0.9),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      borderSide: Divider.createBorderSide(context)),
                  contentPadding: const EdgeInsets.only(left: 20, right: 20),
                  labelText: 'Cerca indirizzo...',
                  prefixIcon: IconButton(
                      onPressed: () {
                        if (focusNode.hasFocus ||
                            searchController.suggestionsController.isOpen) {
                          controller.clear();
                          focusNode.unfocus();
                          searchController.suggestionsController.close();
                        } else {
                          Get.back();
                        }
                      },
                      icon: const Icon(Icons.arrow_back)),
                  suffixIcon: IconButton(
                    onPressed: () {
                      controller.clear();

                      searchController.suggestionsController
                          .close(retainFocus: true);
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
                keyboardType: TextInputType.text,
                onSubmitted: searchController.mapAddress.onSearch,
              );
            },
          ),
        ],
      ),
    );
  }
}
