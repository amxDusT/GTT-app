import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';

class StopTimelineRow extends StatelessWidget {
  const StopTimelineRow({
    super.key,
    required this.name,
    required this.isFirst,
    required this.isLast,
  });

  final String name;
  final bool isFirst;
  final bool isLast;

  static const _accent = Color(0xfff3ede0);
  static const _surface = Color(0xff221d17);

  @override
  Widget build(BuildContext context) {
    final isEndpoint = isFirst || isLast;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isFirst ? Colors.transparent : _accent,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isLast ? Colors.transparent : _accent,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: isEndpoint ? 14 : 11,
                  height: isEndpoint ? 14 : 11,
                  decoration: BoxDecoration(
                    color: isEndpoint ? _accent : _surface,
                    shape: BoxShape.circle,
                    border: isEndpoint
                        ? null
                        : Border.all(color: _accent, width: 2),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Text(
                name,
                style: Fonts.title(
                  fontSize: 15,
                  fontWeight: isEndpoint ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
