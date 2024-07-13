import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_controller.dart';
import 'package:flutter_gtt/controllers/search/home_search_controller.dart';
import 'package:flutter_gtt/models/marker.dart';
import 'package:flutter_gtt/widgets/map/map_info_widget.dart';
import 'package:get/get.dart';

class StopWidget extends StatefulWidget {
  final FermataMarker marker;
  final MapPageController? controller;
  const StopWidget({super.key, required this.marker, this.controller});

  @override
  State<StopWidget> createState() => _StopWidgetState();
}

class _StopWidgetState extends State<StopWidget> {
  late final ValueNotifier<bool> _isHighlighted = ValueNotifier(false);

  @override
  void dispose() {
    _isHighlighted.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isHighlighted.value = widget.marker.color != FermataMarker.defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Get.find<SearchStopsController>().openInfoPage(widget.marker.fermata);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${widget.marker.fermata.code} - ${widget.marker.fermata.name}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          MapInfoWidget(stop: widget.marker.fermata),
          if (widget.controller != null)
            SizedBox(
              //color: Colors.blue,
              width: 120,
              height: 30,
              child: TextButton(
                onPressed: () {
                  widget.controller!
                      .setHighlightedStop(widget.marker.fermata.code);
                  _isHighlighted.value = !_isHighlighted.value;
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                ),
                child: ValueListenableBuilder(
                    valueListenable: _isHighlighted,
                    builder: (context, bool isHighlighted, child) {
                      return Text(
                        isHighlighted ? 'Togli segno' : 'Segna',
                        style: TextStyle(
                          color: isHighlighted ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
              ),
            ),
        ],
      ),
    );
  }
}
