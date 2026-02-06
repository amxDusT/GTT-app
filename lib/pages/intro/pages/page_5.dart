import 'package:flutter/material.dart';
import 'package:torino_mobility/pages/intro/pages/page_template.dart';
import 'package:torino_mobility/widgets/intro/custom_text.dart';
import 'package:torino_mobility/widgets/intro/intro_image.dart';

class Page5 extends StatelessWidget {
  const Page5({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageTemplate(
      title: 'Lista veicoli',
      children: [
        IntroImage(
          image: 'assets/images/intro_rlist.jpg',
          height: 250,
        ),
        CustomText(
          'Puoi visualizzare, cercare o salvare le linee che ti interessano.',
        ),
        CustomText(
          'Cliccando su una linea potrai visualizzarne i veicoli in tempo reale.',
        ),
      ],
    );
  }
}
