extension LocalizationExtension on String {
  /// cosi mi ricordo e trovo i testi hardcoded
  String get hc => this;
}

extension CapitalizeExtension on String {
  String get capitalizeWords => split(' ').map((word) {
        if (word.isEmpty) return word;
        if (word.isRomanNumeral) return word.toUpperCase();
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');

  bool get isRomanNumeral => RegExp(r'^[IVXLCDM]+$').hasMatch(this);
}
