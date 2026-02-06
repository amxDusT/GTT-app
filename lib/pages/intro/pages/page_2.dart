import 'package:flutter/material.dart';
import 'package:torino_mobility/gen/assets.gen.dart';
import 'package:torino_mobility/pages/intro/pages/page_template.dart';
import 'package:torino_mobility/widgets/intro/custom_text.dart';
import 'package:torino_mobility/widgets/intro/intro_image.dart';

class Page2 extends StatelessWidget {
  const Page2({super.key});
  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Pagina iniziale',
      children: [
        IntroImage(
          image: Assets.images.introHome.path,
          height: 250,
          width: 250,
        ),
        const CustomText(
          'Puoi cercare le fermate per nome o numero.',
          type: CustomTextType.body,
        ),
        const CustomText(
          'Puoi cliccare sull\'icona a forma di stella per aggiungere o togliere una fermata ai preferiti.',
        ),
      ],
    );
  }
}
