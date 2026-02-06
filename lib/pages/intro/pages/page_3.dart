import 'package:flutter/material.dart';
import 'package:torino_mobility/pages/intro/pages/page_template.dart';
import 'package:torino_mobility/widgets/intro/custom_text.dart';
import 'package:torino_mobility/widgets/intro/intro_image.dart';

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageTemplate(
      title: 'Preferiti',
      children: [
        // add image
        IntroImage(
          image: 'assets/images/intro_favorites.jpg',
          height: 210,
        ),
        CustomText(
          'Puoi tenere premuta una fermata nei preferiti per modificarla.',
        ),
        CustomText(
          'Cliccando su \'Posizione\' verrai portato alla mappa con la fermata selezionata.\n Tenendolo premuto, potrai modificare la posizione della fermata nei preferiti.',
        ),
      ],
    );
  }
}
