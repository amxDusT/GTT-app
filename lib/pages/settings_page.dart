import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide ColorSwatch;
import 'package:get/get.dart';
import 'package:torino_mobility/controllers/settings_controller.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/pages/debug_settings_page.dart';
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/widgets/settings/color_swatch.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/widgets/settings/settings_kit.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});
  final _c = Get.find<SettingsController>();

  static const List<Color> _presetColors = [
    initialColor,
    Color(0xff7fa66e),
    Color(0xffd96a5e),
    Color(0xff6b9bd1),
    Color(0xffd4a017),
    Color(0xff9b6bd1),
    Color(0xff3aa697),
    Color(0xffd44c2e),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final t = context.tokens;
      return Scaffold(
        backgroundColor: t.bg,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              SettingsHeader(
                eyebrow: 'Preferenze'.hc,
                title: l10n.settingsPageTitle,
                onBack: () => Get.back(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SettingsSectionLabel(label: 'Aspetto'.hc),
                    SettingsCard(children: [
                      _themeRow(context),
                      const SettingsDivider(),
                      _colorRow(context),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.star_outline_rounded,
                        title: l10n.settingsShowFavoriteRoutesTitle,
                        trailing: SettingsSwitch(
                          value: _c.isFavoritesRoutesShowing.value,
                          onChanged: (_) => _c.switchFavoritesRoutesShowing(),
                        ),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.timer_outlined,
                        title: l10n.settingsShowSecondsTitle,
                        trailing: SettingsSwitch(
                          value: _c.showSecondsInUpdates.value,
                          onChanged: (_) => _c.switchShowSecondsInUpdates(),
                        ),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.location_on_outlined,
                        title: l10n.settingsShowStopOnMapTitle,
                        subtitle: l10n.settingsShowStopOnMapSubtitle,
                        trailing: SettingsSwitch(
                          value: _c.isFermataShowing.value,
                          onChanged: (_) => _c.switchFermataShowing(),
                        ),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.push_pin_outlined,
                        title: l10n.settingsHighlightInitialStopTitle,
                        subtitle: l10n.settingsHighlightInitialStopSubtitle,
                        trailing: SettingsSwitch(
                          value: _c.isInitialHighlighted.value,
                          onChanged: (_) => _c.switchInitialHighlighted(),
                        ),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.alt_route_outlined,
                        title: l10n.settingsShowRoutesWithoutPassagesTitle,
                        subtitle:
                            l10n.settingsShowRoutesWithoutPassagesSubtitle,
                        trailing: SettingsSwitch(
                          value: _c.isRouteWithoutPassagesShowing.value,
                          onChanged: (_) =>
                              _c.switchRouteWithoutPassagesShowing(),
                        ),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.animation_outlined,
                        title: l10n.settingsDirectionArrowsAnimationTitle,
                        subtitle: l10n.settingsDirectionArrowsAnimationSubtitle,
                        trailing: SettingsSwitch(
                          value: _c.showDirectionArrowsAnimation.value,
                          onChanged: (_) => _c.switchDirectionArrowsAnimation(),
                        ),
                      ),
                      if (kDebugMode) ...[
                        const SettingsDivider(),
                        SettingsRow(
                          icon: Icons.science_outlined,
                          title: l10n.settingsBetaFeaturesTitle,
                          subtitle: l10n.settingsBetaFeaturesSubtitle,
                          onTap: () => _c.betaFeaturesInfo(),
                          trailing: SettingsSwitch(
                            value: _c.showBetaFeatures.value,
                            onChanged: (_) => _c.switchBetaFeatures(),
                          ),
                        ),
                        if (_c.showBetaFeatures.value) ...[
                          const SettingsDivider(),
                          SettingsRow(
                            icon: Icons.bug_report_outlined,
                            title: 'Impostazioni debug'.hc,
                            subtitle: 'Strumenti di sviluppo'.hc,
                            trailing: Icon(Icons.chevron_right_rounded,
                                size: 22, color: t.inkDim),
                            onTap: () =>
                                Get.to(() => const DebugSettingsPage()),
                          ),
                        ],
                      ],
                    ]),
                    SettingsSectionLabel(label: 'Backup & ripristino'.hc),
                    SettingsCard(children: [
                      SettingsRow(
                        icon: Icons.file_upload_outlined,
                        title: l10n.settingsBackupFavoritesTitle,
                        subtitle: 'Salva i preferiti in un file .json'.hc,
                        onTap: () => _c.exportFavorites(),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.file_download_outlined,
                        title: l10n.settingsRestoreFavoritesTitle,
                        subtitle: 'Importa i preferiti da un file .json'.hc,
                        onTap: () => _c.importFavorites(),
                      ),
                    ]),
                    SettingsSectionLabel(label: 'Avanzate'.hc),
                    SettingsCard(children: [
                      SettingsRow(
                        icon: Icons.refresh_rounded,
                        title: l10n.settingsRefreshDataTitle,
                        onTap: () => _c.resetData(),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.school_outlined,
                        title: l10n.settingsShowTutorialTitle,
                        onTap: () => _c.showTutorial(),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.ios_share_outlined,
                        title: l10n.settingsShareAppTitle,
                        onTap: () => _c.shareApp(),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.delete_outline_rounded,
                        title: 'Cancella cache'.hc,
                        subtitle: _c.cacheSize.value.isEmpty
                            ? 'Mappe salvate localmente'.hc
                            : 'Libera ${_c.cacheSize.value}'.hc,
                        danger: true,
                        onTap: () => _c.clearCache(),
                      ),
                    ]),
                    SettingsSectionLabel(label: 'Info'.hc),
                    SettingsCard(children: [
                      SettingsRow(
                        icon: Icons.directions_bus_outlined,
                        title: 'Versione'.hc,
                        trailing: Text(
                          _c.version.value,
                          style: Fonts.subtitle(
                            fontSize: 12,
                            color: t.inkMute,
                          ),
                        ),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.info_outline_rounded,
                        title: l10n.settingsInfoTitle,
                        trailing: Icon(Icons.arrow_outward_rounded,
                            size: 18, color: t.inkDim),
                        onTap: () => _c.infoApp(),
                      ),
                    ]),
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 8),
                      child: Text(
                        'fatto con ☕ a Torino'.hc,
                        textAlign: TextAlign.center,
                        style: Fonts.title(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: t.inkMute,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static IconData _themeIcon(ThemeMode mode) => switch (mode) {
        ThemeMode.system => Icons.brightness_auto_outlined,
        ThemeMode.light => Icons.light_mode_outlined,
        ThemeMode.dark => Icons.dark_mode_outlined,
      };

  Widget _themeRow(BuildContext context) {
    final t = context.tokens;
    final ThemeMode current = _c.themeMode.value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SettingsIconChip(icon: _themeIcon(current)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l10n.settingsThemeTitle,
                  style: Fonts.title(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    color: t.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SettingsSegmented<ThemeMode>(
            value: current,
            onChanged: _c.setThemeMode,
            options: [
              SettingsSegmentOption(
                value: ThemeMode.system,
                icon: Icons.brightness_auto_outlined,
                label: l10n.settingsThemeSystem,
              ),
              SettingsSegmentOption(
                value: ThemeMode.light,
                icon: Icons.light_mode_outlined,
                label: l10n.settingsThemeLight,
              ),
              SettingsSegmentOption(
                value: ThemeMode.dark,
                icon: Icons.dark_mode_outlined,
                label: l10n.settingsThemeDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _colorRow(BuildContext context) {
    final t = context.tokens;
    final Color current = _c.defaultColor.value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SettingsIconChip(icon: Icons.color_lens_outlined),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Colore predefinito'.hc,
                      style: Fonts.title(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                        color: t.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Colore di default delle fermate salvate'.hc,
                      style: Fonts.title(fontSize: 12, color: t.inkMute),
                    ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: current,
                  shape: BoxShape.circle,
                  border: Border.all(color: t.bgRaised, width: 2),
                  boxShadow: [
                    BoxShadow(color: t.line, spreadRadius: 1, blurRadius: 0),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final color in _presetColors)
                ColorSwatch(
                  color: color,
                  selected: color.toARGB32() == current.toARGB32(),
                  onTap: () => _c.setDefaultColor(color),
                ),
              GestureDetector(
                onTap: () => _c.chooseDefaultColor(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: t.lineStrong),
                  ),
                  child: Icon(Icons.add, size: 16, color: t.inkMute),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
