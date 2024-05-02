import 'package:flutter/material.dart';
import 'package:flutter_gtt/pages/intro/pages/page_template.dart';
import 'package:flutter_gtt/widgets/intro/custom_text.dart';
import 'package:flutter_gtt/widgets/intro/intro_image.dart';

class Page6 extends StatelessWidget {
  const Page6({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageTemplate(
      title: 'Informazioni biglietto',
      children: [
        IntroImage(
          image: 'assets/images/intro_nfc.jpg',
          height: 230,
        ),
        CustomText(
          'Puoi visualizzare le informazioni del biglietto o della carta.',
        ),
        CustomText(
          'Dopo aver cliccato il tasto \'Leggi\' appoggia il biglietto o la carta dietro il telefono.\n(Solo per dispositivi con NFC abilitato)',
        ),
      ],
    );
  }
}
