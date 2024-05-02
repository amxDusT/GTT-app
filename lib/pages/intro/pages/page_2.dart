import 'package:flutter/material.dart';
import 'package:flutter_gtt/pages/intro/pages/page_template.dart';
import 'package:flutter_gtt/widgets/intro/custom_text.dart';
import 'package:flutter_gtt/widgets/intro/intro_image.dart';

class Page2 extends StatelessWidget {
  const Page2({super.key});
  @override
  Widget build(BuildContext context) {
    return const PageTemplate(
      title: 'Pagina iniziale',
      children: [
        IntroImage(
          image: 'assets/images/intro_home.jpg',
          height: 250,
          width: 250,
        ),
        CustomText(
          'Puoi cercare le fermate per nome o numero.',
          type: CustomTextType.body,
        ),
        CustomText(
          'Puoi cliccare sull\'icona a forma di stella per aggiungere o togliere una fermata ai preferiti.',
        ),
      ],
    );
  }
}
