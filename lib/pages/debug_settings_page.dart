import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/controllers/settings_controller.dart';
import 'package:torino_mobility/models/toast.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/toast.dart';
import 'package:torino_mobility/widgets/settings/settings_kit.dart';

class DebugSettingsPage extends StatelessWidget {
  DebugSettingsPage({super.key});
  final _c = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final t = SettingsTokens.of(_c.isDarkMode.value);
      return Scaffold(
        backgroundColor: t.bg,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              SettingsHeader(
                tokens: t,
                eyebrow: 'Beta · Sviluppo'.hc,
                title: 'Debug'.hc,
                onBack: () => Get.back(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SettingsSectionLabel(tokens: t, label: 'Toast di prova'.hc),
                    SettingsCard(tokens: t, children: [
                      SettingsRow(
                        tokens: t,
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
                      SettingsDivider(tokens: t),
                      SettingsRow(
                        tokens: t,
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
                      SettingsDivider(tokens: t),
                      SettingsRow(
                        tokens: t,
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
    });
  }
}
