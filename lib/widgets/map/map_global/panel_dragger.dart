import 'package:flutter/material.dart';

class PanelDragger extends StatelessWidget {
  const PanelDragger({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 6),
      width: 70,
      height: 5,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
