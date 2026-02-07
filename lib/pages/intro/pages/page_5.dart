import 'package:flutter/material.dart';
import 'package:torino_mobility/gen/assets.gen.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/pages/intro/pages/page_template.dart';
import 'package:torino_mobility/widgets/intro/custom_text.dart';
import 'package:torino_mobility/widgets/intro/intro_image.dart';

class Page5 extends StatelessWidget {
  const Page5({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: l10n.introVehicleListTitle,
      children: [
        IntroImage(
          image: Assets.images.introRlist.path,
          height: 250,
        ),
        CustomText(
          l10n.introVehicleListDescription,
        ),
        CustomText(
          l10n.introVehicleListDescription2,
        ),
      ],
    );
  }
}
