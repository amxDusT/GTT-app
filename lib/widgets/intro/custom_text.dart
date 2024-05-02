import 'package:flutter/material.dart';

enum CustomTextType {
  title,
  subtitle,
  body;

  FontWeight get fontWeight {
    switch (this) {
      case CustomTextType.title:
        return FontWeight.bold;
      case CustomTextType.subtitle:
        return FontWeight.w500;
      case CustomTextType.body:
        return FontWeight.w400;
    }
  }

  double get fontSize {
    switch (this) {
      case CustomTextType.title:
        return 36;
      case CustomTextType.subtitle:
        return 24;
      case CustomTextType.body:
        return 16;
    }
  }
}

class CustomText extends StatelessWidget {
  final String text;
  final CustomTextType type;

  const CustomText(
    this.text, {
    super.key,
    this.type = CustomTextType.body,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: type.fontSize,
        fontWeight: type.fontWeight,
      ),
    );
  }
}
