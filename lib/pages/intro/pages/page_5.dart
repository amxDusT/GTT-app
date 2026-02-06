import 'package:flutter/material.dart';
import 'package:torino_mobility/gen/assets.gen.dart';
import 'package:torino_mobility/pages/intro/pages/page_template.dart';
import 'package:torino_mobility/widgets/intro/custom_text.dart';
import 'package:torino_mobility/widgets/intro/intro_image.dart';

class Page5 extends StatelessWidget {
  const Page5({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Lista veicoli',
      children: [
        IntroImage(
          image: Assets.images.introRlist.path,
          height: 250,
        ),
        const CustomText(
          'Puoi visualizzare, cercare o salvare le linee che ti interessano.',
        ),
        const CustomText(
          'Cliccando su una linea potrai visualizzarne i veicoli in tempo reale.',
        ),
      ],
    );
  }
}
