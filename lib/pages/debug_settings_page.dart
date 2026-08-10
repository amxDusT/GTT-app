import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/models/toast.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/toast.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/widgets/settings/settings_kit.dart';

class DebugSettingsPage extends StatelessWidget {
  const DebugSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            SettingsHeader(
              eyebrow: 'Beta · Sviluppo'.hc,
              title: 'Debug'.hc,
              onBack: () => Get.back(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsSectionLabel(label: 'Toast di prova'.hc),
                  SettingsCard(children: [
                    SettingsRow(
                      icon: Icons.error_outline_rounded,
                      title: 'Toast di errore'.hc,
                      subtitle: 'Mostra un toast con tono errore'.hc,
                      danger: true,
                      onTap: () => Toasts.show(
                        'Qualcosa è andato storto'.hc,
                        message: 'Impossibile caricare i passaggi.'.hc,
                        tone: ToastTone.error,
                        closePrevious: true,
                      ),
                    ),
                    const SettingsDivider(),
                    SettingsRow(
                      icon: Icons.info_outline_rounded,
                      title: 'Toast informativo'.hc,
                      subtitle: 'Mostra un toast con tono info'.hc,
                      onTap: () => Toasts.show(
                        'Aggiornamento disponibile'.hc,
                        message: 'È disponibile una nuova versione.'.hc,
                        tone: ToastTone.info,
                        closePrevious: true,
                      ),
                    ),
                    const SettingsDivider(),
                    SettingsRow(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Toast di successo'.hc,
                      subtitle: 'Mostra un toast con tono successo'.hc,
                      onTap: () => Toasts.show(
                        'Operazione completata'.hc,
                        message: 'Le modifiche sono state salvate.'.hc,
                        tone: ToastTone.good,
                        closePrevious: true,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
