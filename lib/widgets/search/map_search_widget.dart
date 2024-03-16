import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/search/search_controller.dart';
import 'package:flutter_gtt/pages/map/map_search.dart';
import 'package:flutter_gtt/widgets/search/search_textfield.dart';
import 'package:get/get.dart';

class SearchAddress extends StatelessWidget {
  final MapSearchController searchController;
  const SearchAddress({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8.0, right: 8.0, top: context.width * 0.12),
      width: double.infinity,
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
      child: SearchTextField(
          searchController: searchController,
          onTap: () =>
              Get.to(() => MapSearchPage(searchController: searchController)),
          readOnly: true,
          labelText: 'Cerca indirizzo...',
          onPrefixPressed: () => Get.back(),
          onSuffixPressed: () {
            searchController.controller.clear();
            searchController.mapAddress.addressReset();
          }),
    );
  }
}
