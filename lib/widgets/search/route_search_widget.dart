import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/route_list_controller.dart';
import 'package:torino_mobility/l10n/localization_service.dart';

class SearchRoute extends StatefulWidget {
  final RouteListController controller;
  const SearchRoute({super.key, required this.controller});

  @override
  State<SearchRoute> createState() => _SearchRouteState();
}

class _SearchRouteState extends State<SearchRoute> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _textController.clear();
      widget.controller.setSearchQuery('');
    }
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 18.0),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: l10n.searchVehicle,
          prefixIcon: _isFocused
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _focusNode.unfocus(),
                )
              : const Icon(Icons.search),
        ),
        keyboardType: TextInputType.text,
        onChanged: widget.controller.setSearchQuery,
      ),
    );
  }
}
