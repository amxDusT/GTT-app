import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/search_controller.dart';
import 'package:flutter_gtt/models/gtt_stop.dart';
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


//          Padding(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 8.0, vertical: 18.0),
//             child: Form(
//               key: _homeController.key,
//               autovalidateMode: AutovalidateMode.disabled,
//               child: Obx(
//                 () => TextFormField(
//                   controller: _homeController.searchController.value,
//                   canRequestFocus: true,
//                   focusNode: _homeController.focusNode.value,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                         borderSide: Divider.createBorderSide(context)),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                     filled: true,
//                     labelText: 'Cerca fermata...',
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Non puoi lasciare il campo vuoto";
//                     }
//                     if (!value.isNumericOnly) {
//                       return "La fermata può essere solo un valore numerico";
//                     }
//                     if (value.length > 4) {
//                       return "La fermata non esiste";
//                     }
//                     int num = int.parse(value);
//                     if (num <= 0 && num >= 7000) {
//                       // boh
//                       return "La fermata non esiste";
//                     }
//                     return null;
//                   },
//                   onFieldSubmitted: (val) => _onSubmitted(),
//                 ),
//               ),
//             ),
//           ),