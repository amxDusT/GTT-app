import 'package:flutter/widgets.dart';

class BottomButtons extends StatelessWidget {
  final int lines;
  final List<Widget> children;
  final Widget verticalSpacer;
  final Widget horizontalSpacer;
  final bool allowVerticalSpacer;
  final bool allowHorizontalSpacer;
  final EdgeInsetsGeometry? padding;
  const BottomButtons({
    super.key,
    this.lines = 2,
    required this.children,
    this.allowHorizontalSpacer = true,
    this.allowVerticalSpacer = true,
    this.verticalSpacer = const SizedBox(
      height: 10,
    ),
    this.horizontalSpacer = const SizedBox(
      width: 10,
    ),
    this.padding,
  });
  List<Widget> _getRows() {
    List<Widget> rows = [];
    List<Widget> row = [];
    int followValue = lines;
    int addedToLine = 0;
    for (var i = 0; i < children.length; i++) {
      if (i == 0 && children.length % lines != 0) {
        followValue = children.length % lines;
      }

      if (i > 0 && allowHorizontalSpacer) {
        row.add(horizontalSpacer);
      }
      row.add(children[i]);
      addedToLine++;
      if (addedToLine >= followValue) {
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: List.from(row),
        ));

        addedToLine = 0;
        row = [];
        followValue = lines;

        if (i < children.length - 1 && allowVerticalSpacer) {
          rows.add(verticalSpacer);
        }
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomRight,
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _getRows(),
      ),
    );
  }
}
