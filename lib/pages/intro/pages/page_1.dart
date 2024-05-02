import 'package:flutter/material.dart';
import 'package:flutter_gtt/pages/intro/pages/page_template.dart';
import 'package:flutter_gtt/widgets/intro/custom_text.dart';

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageTemplate(
      title: 'Benvenuto!',
      children: [
        CustomText(
          'Con questa app potrai visualizzare gli orari dei mezzi pubblici di Torino,\n salvare le tue fermate preferite, vedere le linee in tempo reale e molto altro!',
          type: CustomTextType.body,
        ),
        CustomText(
          'Ecco un breve tutorial per aiutarti a capire come funziona',
        ),
      ],
    );
  }
}
