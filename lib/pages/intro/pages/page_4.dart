import 'package:flutter/material.dart';
import 'package:flutter_gtt/pages/intro/pages/page_template.dart';
import 'package:flutter_gtt/widgets/intro/custom_text.dart';
import 'package:flutter_gtt/widgets/intro/intro_image.dart';

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageTemplate(
      title: 'Fermata',
      children: [
        IntroImage(
          image: 'assets/images/intro_fermata.jpg',
          height: 210,
        ),
        CustomText(
          'Puoi visualizzare le linee che passano per la fermata selezionata e gli orari.',
        ),
        CustomText(
          'Cliccando su una linea potrai visualizzarne i veicoli in tempo reale.\n Puoi vedere più linee contemporaneamente selezionadole e cliccando su \'Guarda sulla mappa\'.',
        ),
      ],
    );
  }
}
