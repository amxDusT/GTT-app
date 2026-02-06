import 'package:flutter/material.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/pages/intro/pages/page_template.dart';
import 'package:torino_mobility/widgets/intro/custom_text.dart';
import 'package:torino_mobility/widgets/intro/intro_image.dart';

class Page6 extends StatelessWidget {
  const Page6({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: l10n.introTicketTitle,
      children: [
        const IntroImage(
          image: 'assets/images/intro_nfc.jpg',
          height: 230,
        ),
        CustomText(
          l10n.introTicketDescription,
        ),
        CustomText(
          l10n.introTicketDescription2,
        ),
      ],
    );
  }
}
