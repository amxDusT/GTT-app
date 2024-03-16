import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/search/search_controller.dart';
import 'package:flutter_gtt/widgets/search/disabled_focusnode.dart';
import 'package:get/get.dart';

class SearchTextField extends StatelessWidget {
  final MapSearchController searchController;
  final void Function()? onTap;
  final bool readOnly;
  final bool autofocus;
  final String? labelText;
  final bool hasSuffixIcon;
  final bool hasPrefixIcon;
  final bool useControllerFocus;
  final void Function()? onSuffixPressed;
  final void Function()? onPrefixPressed;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  const SearchTextField({
    super.key,
    required this.searchController,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.labelText,
    this.hasPrefixIcon = true,
    this.hasSuffixIcon = true,
    this.useControllerFocus = false,
    this.onPrefixPressed,
    this.onSuffixPressed,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      enableInteractiveSelection: autofocus,
      onTap: onTap,
      readOnly: readOnly,
      autofocus: autofocus,
      controller: searchController.controller,
      focusNode: useControllerFocus
          ? searchController.focusNode
          : autofocus
              ? null
              : AlwaysDisabledFocusNode(),
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
        labelText: labelText,
        prefixIcon: hasPrefixIcon
            ? IconButton(
                onPressed: onPrefixPressed, icon: const Icon(Icons.arrow_back))
            : null,
        suffixIcon: hasSuffixIcon
            ? IconButton(
                onPressed: onSuffixPressed,
                icon: const Icon(Icons.clear),
              )
            : null,
      ),
      keyboardType: TextInputType.text,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
