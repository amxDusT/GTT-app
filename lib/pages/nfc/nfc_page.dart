import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/controllers/nav_shell_controller.dart';
import 'package:torino_mobility/controllers/nfc_controller.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/pages/nav_shell.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/widgets/app_header.dart';
import 'package:torino_mobility/widgets/settings/settings_kit.dart';

class NfcPage extends StatefulWidget {
  const NfcPage({super.key});

  @override
  State<NfcPage> createState() => _NfcPageState();
}

class _NfcPageState extends State<NfcPage>
    with SingleTickerProviderStateMixin {
  late final NfcController _nfc;
  late final AnimationController _rings;
  Worker? _indexWorker;
  Worker? _readingWorker;

  @override
  void initState() {
    super.initState();
    _nfc = Get.put(NfcController());
    _rings = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _readingWorker = ever<bool>(_nfc.isReading, (reading) {
      if (reading) {
        _rings.repeat();
      } else {
        _rings.stop();
      }
    });
    if (Get.isRegistered<NavShellController>()) {
      _indexWorker = ever<int>(
        Get.find<NavShellController>().currentIndex,
        (index) {
          if (index != NavShell.nfcIndex && _nfc.isReading.isTrue) {
            _nfc.stopReading();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _indexWorker?.dispose();
    _readingWorker?.dispose();
    _nfc.stopReading();
    _rings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final t = SettingsTokens.of(dark);
    return Hero(
      tag: 'NFCPage',
      child: Scaffold(
        backgroundColor: t.bg,
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(
                accentColor: t.accent,
                titleTop: 'avvicina'.hc,
                titleBottom: 'tessera'.hc,
                subtitle: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.accent,
                      ),
                      height: 5,
                      width: 5,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'NFC · BIP CARD'.hc,
                      style: Fonts.subtitle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        height: .9,
                        color: t.inkMute,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Obx(() {
                    final reading = _nfc.isReading.isTrue;
                    return GestureDetector(
                      onTap: reading ? _nfc.stopReading : _nfc.readCard,
                      child: SizedBox(
                        width: 240,
                        height: 240,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (reading)
                              AnimatedBuilder(
                                animation: _rings,
                                builder: (context, _) {
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: List.generate(3, (i) {
                                      final p = (_rings.value + i / 3) % 1.0;
                                      final scale = 0.7 + 0.8 * p;
                                      final opacity =
                                          (0.6 * (1 - p)).clamp(0.0, 1.0);
                                      return Opacity(
                                        opacity: opacity,
                                        child: Transform.scale(
                                          scale: scale,
                                          child: Container(
                                            width: 220,
                                            height: 220,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: t.accent,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: t.accent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: t.accent.withValues(alpha: 0.33),
                                    blurRadius: 50,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.credit_card_rounded,
                                size: 56,
                                color: t.bg,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Obx(() {
                  final reading = _nfc.isReading.isTrue;
                  return Column(
                    children: [
                      Text(
                        reading ? 'In ascolto…'.hc : 'Pronto'.hc,
                        style: Fonts.title(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: t.inkDim,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'tieni la tessera vicino al retro del telefono'.hc,
                        textAlign: TextAlign.center,
                        style: Fonts.subtitle(
                          fontSize: 12,
                          letterSpacing: 0.6,
                          color: t.inkMute,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _actionButton(t, reading),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(SettingsTokens t, bool reading) {
    if (reading) {
      return GestureDetector(
        onTap: _nfc.stopReading,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            color: t.bgRaised,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: t.line),
          ),
          child: Text(
            l10n.cancel,
            style: Fonts.title(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: t.ink,
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: _nfc.readCard,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        decoration: BoxDecoration(
          color: t.accent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          l10n.nfcRead,
          style: Fonts.title(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
