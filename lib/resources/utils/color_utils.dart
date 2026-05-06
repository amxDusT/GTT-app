import 'package:flutter/material.dart';

class ColorUtils {
  static const List<Color> defaultColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.amber,
    Colors.cyan
  ];
  static const List<Color> bigColorList = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.amber,
    Colors.cyan,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.lime,
    Colors.indigo,
    Colors.brown,
    Colors.blueGrey,
  ];
  static Color indexColor(int index) {
    return bigColorList[index % bigColorList.length];
  }

  static Color normalize(Color color, {bool dark = false}) {
    if (dark) {
      return darken(color, 30);
    } else {
      return lighten(color);
    }
  }

  static int _channelToInt(double channel) =>
      (channel * 255.0).round().clamp(0, 255);

  static Color darken(Color c, [int percent = 50]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(
      _channelToInt(c.a),
      _channelToInt(c.r * f),
      _channelToInt(c.g * f),
      _channelToInt(c.b * f),
    );
  }

  static Color lighten(Color c, [int percent = 50]) {
    assert(1 <= percent && percent <= 100);
    var p = percent / 100;
    return Color.fromARGB(
      _channelToInt(c.a),
      _channelToInt(c.r + ((255 - c.r) * p)),
      _channelToInt(c.g + ((255 - c.g) * p)),
      _channelToInt(c.b + ((255 - c.b) * p)),
    );
  }
}
