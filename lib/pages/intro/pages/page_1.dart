import 'package:flutter/material.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/pages/intro/pages/page_template.dart';
import 'package:torino_mobility/widgets/intro/custom_text.dart';

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: l10n.welcomeTitle,
      children: [
        CustomText(
          l10n.welcomeDescription,
        ),
        CustomText(
          l10n.welcomeDecription2,
        ),
      ],
    );
  }
}
