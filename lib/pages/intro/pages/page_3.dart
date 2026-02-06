import 'package:flutter/material.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/pages/intro/pages/page_template.dart';
import 'package:torino_mobility/widgets/intro/custom_text.dart';
import 'package:torino_mobility/widgets/intro/intro_image.dart';

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: l10n.introFavoritesTitle,
      children: [
        // add image
        const IntroImage(
          image: 'assets/images/intro_favorites.jpg',
          height: 210,
        ),
        CustomText(
          l10n.introFavoritesDescription,
        ),
        CustomText(
          l10n.introFavoritesDescription2,
        ),
      ],
    );
  }
}
