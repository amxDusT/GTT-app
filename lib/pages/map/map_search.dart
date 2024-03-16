import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/search/search_controller.dart';
import 'package:flutter_gtt/models/map/address.dart';
import 'package:flutter_gtt/resources/debouncer.dart';
import 'package:flutter_gtt/widgets/map/distance_icon.dart';
import 'package:flutter_gtt/widgets/search/search_textfield.dart';
import 'package:get/get.dart';

class MapSearchPage extends StatelessWidget {
  final MapSearchController searchController;
  final _debouncer = Debouncer(duration: const Duration(milliseconds: 300));
  MapSearchPage({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    searchController.getSuggestions();
    var controller = searchController.controller;

    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: Get.context!.width * 0.12),
        width: double.infinity,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              padding:
                  const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
              child: SearchTextField(
                useControllerFocus: true,
                searchController: searchController,
                autofocus: true,
                labelText: 'Cerca indirizzo...',
                onPrefixPressed: () {
                  Get.back();
                },
                onSuffixPressed: () {
                  controller.clear();
                  searchController.getSuggestions();
                },
                onSubmitted: searchController.onSearch,
                onChanged: (value) =>
                    _debouncer.run(() => searchController.onSearch(value)),
              ),
            ),
            const Divider(),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  padding: const EdgeInsets.all(0.0),
                  shrinkWrap: true,
                  itemCount: searchController.suggestions.length,
                  itemBuilder: (context, index) {
                    return _addressTile(searchController.suggestions[index]);
                  },
                  separatorBuilder: (context, index) => const Divider(
                    indent: 10,
                    endIndent: 10,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*  Widget _oldContainer() {
    return Container(
      margin: EdgeInsets.only(
          /* left: 8.0, right: 8.0, */ top: Get.context!.width * 0.12),
      width: double.infinity,
      //padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TypeAheadField<AddressWithDetails>(
            itemSeparatorBuilder: (context, index) => Divider(
              indent: context.width * 0.18,
              height: 1.0,
            ),
            controller: searchController.controller,
            suggestionsController: searchController.suggestionsController,
            hideOnUnfocus: false,
            hideWithKeyboard: false,
            animationDuration: Durations.short1,
            hideOnEmpty: false,
            debounceDuration: const Duration(milliseconds: 300),
            onSelected: searchController.mapAddress.onSelected,
            suggestionsCallback: (val) =>
                searchController.mapAddress.getSuggestions(val),
            loadingBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
            itemBuilder: (context, address) {
              return _addressTile(address);
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
                onSubmitted: searchController.onSearch,
              );
            },
          ),
        ],
      ),
    );
  }
 */
  Widget _addressTile(AddressWithDetails address) {
    return ListTile(
      onTap: () {
        searchController.mapAddress.onSelected(address);
        searchController.controller.text = address.toString();
        Get.back();
      },
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
      trailing: InkWell(
          onTap: () => searchController.addToText(address),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.north_west),
          )),
    );
  }
}
