import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/l10n/app_localizations.dart';

class LocalizationService {
  const LocalizationService(this._context);
  final BuildContext _context;

  AppLocalizations? get l10n => AppLocalizations.of(_context)!;
}

AppLocalizations get l10n =>
    Get.find<LocalizationService>().l10n ?? AppLocalizations.of(Get.context!)!;
