import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Torino Mobility'**
  String get appTitle;

  /// No description provided for @stopsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get stopsTitle;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @followedVehicleRemoved.
  ///
  /// In en, this message translates to:
  /// **'The vehicle you were following has been removed'**
  String get followedVehicleRemoved;

  /// No description provided for @settingsDarkThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get settingsDarkThemeTitle;

  /// No description provided for @settingsShowFavoriteRoutesTitle.
  ///
  /// In en, this message translates to:
  /// **'Show favorite lines on home'**
  String get settingsShowFavoriteRoutesTitle;

  /// No description provided for @settingsShowSecondsTitle.
  ///
  /// In en, this message translates to:
  /// **'Show seconds since last update'**
  String get settingsShowSecondsTitle;

  /// No description provided for @settingsShowStopOnMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Show stop on map'**
  String get settingsShowStopOnMapTitle;

  /// No description provided for @settingsShowStopOnMapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show the initial stop popup on the map'**
  String get settingsShowStopOnMapSubtitle;

  /// No description provided for @settingsHighlightInitialStopTitle.
  ///
  /// In en, this message translates to:
  /// **'Highlight initial stop'**
  String get settingsHighlightInitialStopTitle;

  /// No description provided for @settingsHighlightInitialStopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show the initial stop in a different color on the map'**
  String get settingsHighlightInitialStopSubtitle;

  /// No description provided for @settingsShowRoutesWithoutPassagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Show routes without passages'**
  String get settingsShowRoutesWithoutPassagesTitle;

  /// No description provided for @settingsShowRoutesWithoutPassagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show routes without passages from \"View on map\"'**
  String get settingsShowRoutesWithoutPassagesSubtitle;

  /// No description provided for @settingsBetaFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Beta features'**
  String get settingsBetaFeaturesTitle;

  /// No description provided for @settingsBetaFeaturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap for information'**
  String get settingsBetaFeaturesSubtitle;

  /// No description provided for @settingsShowTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Show tutorial'**
  String get settingsShowTutorialTitle;

  /// No description provided for @settingsRefreshDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Refresh GTT data'**
  String get settingsRefreshDataTitle;

  /// No description provided for @settingsDownloadReleaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Download release'**
  String get settingsDownloadReleaseTitle;

  /// No description provided for @settingsBackupFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Local favorites backup'**
  String get settingsBackupFavoritesTitle;

  /// No description provided for @settingsRestoreFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore favorites'**
  String get settingsRestoreFavoritesTitle;

  /// No description provided for @settingsShareAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Share app'**
  String get settingsShareAppTitle;

  /// No description provided for @settingsInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'App info'**
  String get settingsInfoTitle;

  /// No description provided for @settingsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPageTitle;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String settingsVersion(String version);

  /// No description provided for @shareAppMessage.
  ///
  /// In en, this message translates to:
  /// **'I\'m using this GTT app, download it too \nhttps://github.com/amxDusT/GTT-app/releases/latest'**
  String get shareAppMessage;

  /// No description provided for @shareAppSubject.
  ///
  /// In en, this message translates to:
  /// **'GTT app'**
  String get shareAppSubject;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by: {developer}'**
  String developedBy(String developer);

  /// No description provided for @githubLabel.
  ///
  /// In en, this message translates to:
  /// **'Github: '**
  String get githubLabel;

  /// No description provided for @betaFeaturesHeading.
  ///
  /// In en, this message translates to:
  /// **'Features in testing:'**
  String get betaFeaturesHeading;

  /// No description provided for @betaFeaturesWarning.
  ///
  /// In en, this message translates to:
  /// **'WARNING! These features are not fully tested and may not work correctly.'**
  String get betaFeaturesWarning;

  /// No description provided for @betaFeaturesList.
  ///
  /// In en, this message translates to:
  /// **'- default map without routes\n- map API from Mapbox instead of OpenStreetMap'**
  String get betaFeaturesList;

  /// No description provided for @moveToTop.
  ///
  /// In en, this message translates to:
  /// **'Move to top'**
  String get moveToTop;

  /// No description provided for @changeDescription.
  ///
  /// In en, this message translates to:
  /// **'Change description'**
  String get changeDescription;

  /// No description provided for @changeColor.
  ///
  /// In en, this message translates to:
  /// **'Change color'**
  String get changeColor;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @chooseColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a color'**
  String get chooseColorTitle;

  /// No description provided for @deleteStopQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete stop {stop}?'**
  String deleteStopQuestion(String stop);

  /// No description provided for @enterShortDescription.
  ///
  /// In en, this message translates to:
  /// **'Write a short description'**
  String get enterShortDescription;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @selectedRoutesCount.
  ///
  /// In en, this message translates to:
  /// **'{selected} / {total} selected'**
  String selectedRoutesCount(int selected, int total);

  /// No description provided for @selectRoutes.
  ///
  /// In en, this message translates to:
  /// **'Select routes'**
  String get selectRoutes;

  /// No description provided for @saveToHome.
  ///
  /// In en, this message translates to:
  /// **'Save to home'**
  String get saveToHome;

  /// No description provided for @removeFromHome.
  ///
  /// In en, this message translates to:
  /// **'Remove from home'**
  String get removeFromHome;

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last update: {time}'**
  String lastUpdate(String time);

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @errorWithCode.
  ///
  /// In en, this message translates to:
  /// **'Error {code}'**
  String errorWithCode(int code);

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @genericErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Oops... Problem while processing the request.'**
  String get genericErrorMessage;

  /// No description provided for @retryOrUpdateDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Try again, or refresh GTT data in settings.'**
  String get retryOrUpdateDataMessage;

  /// No description provided for @invalidAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid address'**
  String get invalidAddress;

  /// No description provided for @stopNotFound.
  ///
  /// In en, this message translates to:
  /// **'The stop does not exist'**
  String get stopNotFound;

  /// No description provided for @nfcNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'NFC is off. Enable it in settings'**
  String get nfcNotAvailable;

  /// No description provided for @nfcCardUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Card not supported'**
  String get nfcCardUnsupported;

  /// No description provided for @nfcTicketUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Ticket not supported'**
  String get nfcTicketUnsupported;

  /// No description provided for @nfcTicketRemovedTooSoon.
  ///
  /// In en, this message translates to:
  /// **'You removed the ticket too soon. Try again'**
  String get nfcTicketRemovedTooSoon;

  /// No description provided for @nfcCardRemovedTooSoon.
  ///
  /// In en, this message translates to:
  /// **'You removed the card too soon. Try again'**
  String get nfcCardRemovedTooSoon;

  /// No description provided for @nfcEmptyCard.
  ///
  /// In en, this message translates to:
  /// **'Empty card'**
  String get nfcEmptyCard;

  /// No description provided for @readCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Read Card'**
  String get readCardTitle;

  /// No description provided for @cardTitle.
  ///
  /// In en, this message translates to:
  /// **'Card {cardNumber}'**
  String cardTitle(String cardNumber);

  /// No description provided for @cardInfoHeading.
  ///
  /// In en, this message translates to:
  /// **'Card information'**
  String get cardInfoHeading;

  /// No description provided for @subscriptionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptionsHeading;

  /// No description provided for @cardNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Card number: '**
  String get cardNumberLabel;

  /// No description provided for @cardTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Card type: '**
  String get cardTypeLabel;

  /// No description provided for @cardIssuedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Issued on: '**
  String get cardIssuedOnLabel;

  /// No description provided for @contractsLabel.
  ///
  /// In en, this message translates to:
  /// **'Contracts/Subscriptions: '**
  String get contractsLabel;

  /// No description provided for @ticketTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket {cardNumber}'**
  String ticketTitle(String cardNumber);

  /// No description provided for @ticketInfoHeading.
  ///
  /// In en, this message translates to:
  /// **'Ticket info:'**
  String get ticketInfoHeading;

  /// No description provided for @ticketNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket number: '**
  String get ticketNumberLabel;

  /// No description provided for @ticketTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket type: '**
  String get ticketTypeLabel;

  /// No description provided for @ticketFirstValidationLabel.
  ///
  /// In en, this message translates to:
  /// **'First validation on: '**
  String get ticketFirstValidationLabel;

  /// No description provided for @ticketLastValidationLabel.
  ///
  /// In en, this message translates to:
  /// **'Last validation on: '**
  String get ticketLastValidationLabel;

  /// No description provided for @ticketExpiresLabel.
  ///
  /// In en, this message translates to:
  /// **'Expires on: '**
  String get ticketExpiresLabel;

  /// No description provided for @ticketMinutesRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Minutes remaining: '**
  String get ticketMinutesRemainingLabel;

  /// No description provided for @ticketExpiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get ticketExpiredLabel;

  /// No description provided for @stopTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop {stopName}'**
  String stopTitle(String stopName);

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get viewOnMap;

  /// No description provided for @routesTitle.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get routesTitle;

  /// No description provided for @directionLabel.
  ///
  /// In en, this message translates to:
  /// **'Direction:'**
  String get directionLabel;

  /// No description provided for @readTicketOrCard.
  ///
  /// In en, this message translates to:
  /// **'Read Ticket/Card'**
  String get readTicketOrCard;

  /// No description provided for @defaultMap.
  ///
  /// In en, this message translates to:
  /// **'Default Map'**
  String get defaultMap;

  /// No description provided for @loadingFirstDownload.
  ///
  /// In en, this message translates to:
  /// **'Downloading GTT data for the first time...'**
  String get loadingFirstDownload;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'New version available ({version})'**
  String updateAvailableTitle(String version);

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available'**
  String get updateAvailableBody;

  /// No description provided for @whatsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s new:'**
  String get whatsNewTitle;

  /// No description provided for @downloadNewVersion.
  ///
  /// In en, this message translates to:
  /// **'Download the new version'**
  String get downloadNewVersion;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @contractExpiredSuffix.
  ///
  /// In en, this message translates to:
  /// **'- Expired'**
  String get contractExpiredSuffix;

  /// No description provided for @contractNotActivatedSuffix.
  ///
  /// In en, this message translates to:
  /// **'(Not activated)'**
  String get contractNotActivatedSuffix;

  /// No description provided for @startLabel.
  ///
  /// In en, this message translates to:
  /// **'Start: '**
  String get startLabel;

  /// No description provided for @endLabel.
  ///
  /// In en, this message translates to:
  /// **'End: '**
  String get endLabel;

  /// No description provided for @directionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directionsLabel;

  /// No description provided for @nearbyStopsLabel.
  ///
  /// In en, this message translates to:
  /// **'Nearby stops'**
  String get nearbyStopsLabel;

  /// No description provided for @positionLabel.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get positionLabel;

  /// No description provided for @chooseDateTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose date and time'**
  String get chooseDateTimeTitle;

  /// No description provided for @resetCurrentTime.
  ///
  /// In en, this message translates to:
  /// **'Reset to current time'**
  String get resetCurrentTime;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @nfcReading.
  ///
  /// In en, this message translates to:
  /// **'Reading...'**
  String get nfcReading;

  /// No description provided for @nfcRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get nfcRead;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location service disabled'**
  String get locationServiceDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Enable location permissions in device settings'**
  String get locationPermissionDeniedForever;

  /// No description provided for @introStopTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get introStopTitle;

  /// No description provided for @introStopDescription.
  ///
  /// In en, this message translates to:
  /// **'You can view the lines serving the selected stop and their schedules.'**
  String get introStopDescription;

  /// No description provided for @introStopDescription2.
  ///
  /// In en, this message translates to:
  /// **'By tapping on a line you can view its vehicles in real time.\nYou can see multiple lines at the same time by selecting them and tapping \"View on map\".'**
  String get introStopDescription2;

  /// No description provided for @introFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get introFavoritesTitle;

  /// No description provided for @introFavoritesDescription.
  ///
  /// In en, this message translates to:
  /// **'Long-press a stop in favorites to edit it.'**
  String get introFavoritesDescription;

  /// No description provided for @introFavoritesDescription2.
  ///
  /// In en, this message translates to:
  /// **'By tapping \"Position\" you go to the map with the selected stop. Long-pressing lets you change its position in favorites.'**
  String get introFavoritesDescription2;

  /// No description provided for @introTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket information'**
  String get introTicketTitle;

  /// No description provided for @introTicketDescription.
  ///
  /// In en, this message translates to:
  /// **'You can view the information of the ticket or card.'**
  String get introTicketDescription;

  /// No description provided for @introTicketDescription2.
  ///
  /// In en, this message translates to:
  /// **'After pressing \"Read\" place the ticket or card on the back of the phone.\n(Only for devices with NFC enabled)'**
  String get introTicketDescription2;

  /// No description provided for @searchStop.
  ///
  /// In en, this message translates to:
  /// **'Search stop...'**
  String get searchStop;

  /// No description provided for @searchVehicle.
  ///
  /// In en, this message translates to:
  /// **'Search vehicle...'**
  String get searchVehicle;

  /// No description provided for @searchAddress.
  ///
  /// In en, this message translates to:
  /// **'Search address...'**
  String get searchAddress;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
