import 'package:flutter/material.dart';
import 'package:torino_mobility/gen/assets.gen.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/pages/intro/pages/page_template.dart';
import 'package:torino_mobility/widgets/intro/custom_text.dart';
import 'package:torino_mobility/widgets/intro/intro_image.dart';

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: l10n.introStopTitle,
      children: [
        IntroImage(
          image: Assets.images.introFermata.path,
          height: 210,
        ),
        CustomText(
          l10n.introStopDescription,
        ),
        CustomText(
          l10n.introStopDescription2,
        ),
      ],
    );
  }
}
