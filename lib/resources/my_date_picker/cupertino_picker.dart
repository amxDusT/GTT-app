import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gtt/resources/debouncer.dart';

class DustCupertinoPicker extends StatefulWidget {
  final double itemHeight;
  final List<int> items;
  final int selectedItem;
  final Function(int index)? onSelectedItemChanged;
  const DustCupertinoPicker({
    super.key,
    required this.itemHeight,
    required this.selectedItem,
    required this.items,
    this.onSelectedItemChanged,
  });

  @override
  State<DustCupertinoPicker> createState() => _DustCupertinoPickerState();
}

class _DustCupertinoPickerState extends State<DustCupertinoPicker> {
  late final FixedExtentScrollController scrollController;
  Debouncer debouncer = Debouncer(duration: const Duration(milliseconds: 150));
  @override
  void initState() {
    super.initState();
    scrollController =
        FixedExtentScrollController(initialItem: widget.selectedItem);
  }

  @override
  void didUpdateWidget(covariant DustCupertinoPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    final int item = widget.selectedItem >= widget.items.length
        ? widget.items.length
        : widget.selectedItem;
    scrollController.animateToItem(
      item,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.itemHeight * 2,
      width: widget.itemHeight,
      child: ShaderMask(
        shaderCallback: (Rect rect) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple,
              Colors.transparent,
              Colors.transparent,
              Colors.purple
            ],
            stops: [
              0.0,
              0.1,
              0.9,
              1.0
            ], // 10% purple, 80% transparent, 10% purple
          ).createShader(rect);
        },
        blendMode: BlendMode.dstOut,
        child: CupertinoPicker(
          diameterRatio: 10,
          offAxisFraction: 0.0,
          //backgroundColor: Colors.white,
          itemExtent: widget.itemHeight,
          scrollController: scrollController,
          selectionOverlay: Container(
            decoration: BoxDecoration(
              border: Border.symmetric(
                  horizontal: BorderSide(
                      color: CupertinoDynamicColor.resolve(
                          Colors.grey.withOpacity(0.3), context),
                      width: 2)),
            ),
          ),
          onSelectedItemChanged: (int index) {
            if (widget.onSelectedItemChanged != null) {
              debouncer.run(() {
                widget.onSelectedItemChanged!(index);
              });
            }
          },
          /*
            List.generate(
              60,
              (index) => Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  textAlign: TextAlign.center,
                ),
              ),
            )),
            */
          children: widget.items
              .map((item) => Center(
                    child: Text(
                      item.toString().padLeft(2, '0'),
                      textAlign: TextAlign.center,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
