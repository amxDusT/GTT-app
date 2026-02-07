// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Torino Mobility';

  @override
  String get stopsTitle => 'Stops';

  @override
  String get close => 'Close';

  @override
  String get settings => 'Settings';

  @override
  String get followedVehicleRemoved =>
      'The vehicle you were following has been removed';

  @override
  String get welcomeTitle => 'Welcome!';

  @override
  String get welcomeDescription =>
      'With this app, you can view the schedules of public transport in Turin,\n save your favorite stops, see real-time lines, and much more!';

  @override
  String get welcomeDecription2 =>
      'Here\'s a brief tutorial to help you understand how it works.';

  @override
  String get settingsDarkThemeTitle => 'Dark theme';

  @override
  String get settingsShowFavoriteRoutesTitle => 'Show favorite lines on home';

  @override
  String get settingsShowSecondsTitle => 'Show seconds since last update';

  @override
  String get settingsShowStopOnMapTitle => 'Show stop on map';

  @override
  String get settingsShowStopOnMapSubtitle =>
      'Show the initial stop popup on the map';

  @override
  String get settingsHighlightInitialStopTitle => 'Highlight initial stop';

  @override
  String get settingsHighlightInitialStopSubtitle =>
      'Show the initial stop in a different color on the map';

  @override
  String get settingsShowRoutesWithoutPassagesTitle =>
      'Show routes without passages';

  @override
  String get settingsShowRoutesWithoutPassagesSubtitle =>
      'Show routes without passages from \"View on map\"';

  @override
  String get settingsBetaFeaturesTitle => 'Beta features';

  @override
  String get settingsBetaFeaturesSubtitle => 'Tap for information';

  @override
  String get settingsShowTutorialTitle => 'Show tutorial';

  @override
  String get settingsRefreshDataTitle => 'Refresh GTT data';

  @override
  String get settingsDownloadReleaseTitle => 'Download release';

  @override
  String get settingsBackupFavoritesTitle => 'Local favorites backup';

  @override
  String get settingsRestoreFavoritesTitle => 'Restore favorites';

  @override
  String get settingsShareAppTitle => 'Share app';

  @override
  String get settingsInfoTitle => 'App info';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String settingsVersion(String version) {
    return 'Version: $version';
  }

  @override
  String get shareAppMessage =>
      'I\'m using this GTT app, download it too \nhttps://github.com/amxDusT/GTT-app/releases/latest';

  @override
  String get shareAppSubject => 'GTT app';

  @override
  String developedBy(String developer) {
    return 'Developed by: $developer';
  }

  @override
  String get githubLabel => 'Github: ';

  @override
  String get betaFeaturesHeading => 'Features in testing:';

  @override
  String get betaFeaturesWarning =>
      'WARNING! These features are not fully tested and may not work correctly.';

  @override
  String get betaFeaturesList =>
      '- default map without routes\n- map API from Mapbox instead of OpenStreetMap';

  @override
  String get moveToTop => 'Move to top';

  @override
  String get changeDescription => 'Change description';

  @override
  String get changeColor => 'Change color';

  @override
  String get delete => 'Delete';

  @override
  String get chooseColorTitle => 'Choose a color';

  @override
  String deleteStopQuestion(String stop) {
    return 'Do you want to delete stop $stop?';
  }

  @override
  String get enterShortDescription => 'Write a short description';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String selectedRoutesCount(int selected, int total) {
    return '$selected / $total selected';
  }

  @override
  String get selectRoutes => 'Select routes';

  @override
  String get saveToHome => 'Save to home';

  @override
  String get removeFromHome => 'Remove from home';

  @override
  String lastUpdate(String time) {
    return 'Last update: $time';
  }

  @override
  String get update => 'Update';

  @override
  String errorWithCode(int code) {
    return 'Error $code';
  }

  @override
  String get errorTitle => 'Error';

  @override
  String get genericErrorMessage =>
      'Oops... Problem while processing the request.';

  @override
  String get retryOrUpdateDataMessage =>
      'Try again, or refresh GTT data in settings.';

  @override
  String get invalidAddress => 'Invalid address';

  @override
  String get stopNotFound => 'The stop does not exist';

  @override
  String get nfcNotAvailable => 'NFC is off. Enable it in settings';

  @override
  String get nfcCardUnsupported => 'Card not supported';

  @override
  String get nfcTicketUnsupported => 'Ticket not supported';

  @override
  String get nfcTicketRemovedTooSoon =>
      'You removed the ticket too soon. Try again';

  @override
  String get nfcCardRemovedTooSoon =>
      'You removed the card too soon. Try again';

  @override
  String get nfcEmptyCard => 'Empty card';

  @override
  String get readCardTitle => 'Read Card';

  @override
  String cardTitle(String cardNumber) {
    return 'Card $cardNumber';
  }

  @override
  String get cardInfoHeading => 'Card information';

  @override
  String get subscriptionsHeading => 'Subscriptions';

  @override
  String get cardNumberLabel => 'Card number: ';

  @override
  String get cardTypeLabel => 'Card type: ';

  @override
  String get cardIssuedOnLabel => 'Issued on: ';

  @override
  String get contractsLabel => 'Contracts/Subscriptions: ';

  @override
  String ticketTitle(String cardNumber) {
    return 'Ticket $cardNumber';
  }

  @override
  String get ticketInfoHeading => 'Ticket info:';

  @override
  String get ticketNumberLabel => 'Ticket number: ';

  @override
  String get ticketTypeLabel => 'Ticket type: ';

  @override
  String get ticketFirstValidationLabel => 'First validation on: ';

  @override
  String get ticketLastValidationLabel => 'Last validation on: ';

  @override
  String get ticketExpiresLabel => 'Expires on: ';

  @override
  String get ticketMinutesRemainingLabel => 'Minutes remaining: ';

  @override
  String get ticketExpiredLabel => 'Expired';

  @override
  String stopTitle(String stopName) {
    return 'Stop $stopName';
  }

  @override
  String get viewOnMap => 'View on map';

  @override
  String get routesTitle => 'Lines';

  @override
  String get directionLabel => 'Direction:';

  @override
  String get readTicketOrCard => 'Read Ticket/Card';

  @override
  String get defaultMap => 'Default Map';

  @override
  String get loadingFirstDownload =>
      'Downloading GTT data for the first time...';

  @override
  String updateAvailableTitle(String version) {
    return 'New version available ($version)';
  }

  @override
  String get updateAvailableBody => 'A new version of the app is available';

  @override
  String get whatsNewTitle => 'What\'s new:';

  @override
  String get downloadNewVersion => 'Download the new version';

  @override
  String get download => 'Download';

  @override
  String get contractExpiredSuffix => '- Expired';

  @override
  String get contractNotActivatedSuffix => '(Not activated)';

  @override
  String get startLabel => 'Start: ';

  @override
  String get endLabel => 'End: ';

  @override
  String get directionsLabel => 'Directions';

  @override
  String get nearbyStopsLabel => 'Nearby stops';

  @override
  String get positionLabel => 'Position';

  @override
  String get chooseDateTimeTitle => 'Choose date and time';

  @override
  String get resetCurrentTime => 'Reset to current time';

  @override
  String get set => 'Set';

  @override
  String get nfcReading => 'Reading...';

  @override
  String get nfcRead => 'Read';

  @override
  String get locationServiceDisabled => 'Location service disabled';

  @override
  String get locationPermissionDenied => 'Permission denied';

  @override
  String get locationPermissionDeniedForever =>
      'Permission denied. Enable location permissions in device settings';

  @override
  String get introStopTitle => 'Stop';

  @override
  String get introStopDescription =>
      'You can view the lines serving the selected stop and their schedules.';

  @override
  String get introStopDescription2 =>
      'By tapping on a line you can view its vehicles in real time.\nYou can see multiple lines at the same time by selecting them and tapping \"View on map\".';

  @override
  String get introFavoritesTitle => 'Favorites';

  @override
  String get introFavoritesDescription =>
      'Long-press a stop in favorites to edit it.';

  @override
  String get introFavoritesDescription2 =>
      'By tapping \"Position\" you go to the map with the selected stop. Long-pressing lets you change its position in favorites.';

  @override
  String get introTicketTitle => 'Ticket information';

  @override
  String get introTicketDescription =>
      'You can view the information of the ticket or card.';

  @override
  String get introTicketDescription2 =>
      'After pressing \"Read\" place the ticket or card on the back of the phone.\n(Only for devices with NFC enabled)';

  @override
  String get introHomeTitle => 'Home Page';

  @override
  String get introHomeDescription =>
      'You can search for stops by name or number.';

  @override
  String get introHomeDescription2 =>
      'You can click on the star icon to add or remove a stop from favorites.';

  @override
  String get introVehicleListTitle => 'Vehicle List';

  @override
  String get introVehicleListDescription =>
      'You can view, search, or save the lines you are interested in.';

  @override
  String get introVehicleListDescription2 =>
      'By tapping on a line you can view its vehicles in real time.';

  @override
  String get searchStop => 'Search stop...';

  @override
  String get searchVehicle => 'Search vehicle...';

  @override
  String get searchAddress => 'Search address...';

  @override
  String get makeDefault => 'Make default';

  @override
  String selectMaxVehicles(int maxRoutesInMap) {
    return 'You can select up to $maxRoutesInMap vehicles';
  }
}
