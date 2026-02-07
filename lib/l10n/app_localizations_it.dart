// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'MobiliTO';

  @override
  String get stopsTitle => 'Fermate';

  @override
  String get close => 'Chiudi';

  @override
  String get settings => 'Impostazioni';

  @override
  String get followedVehicleRemoved =>
      'Il veicolo che stavi seguendo è stato rimosso';

  @override
  String get welcomeTitle => 'Benvenuto!';

  @override
  String get welcomeDescription =>
      'Con questa app potrai visualizzare gli orari dei mezzi pubblici di Torino,\n salvare le tue fermate preferite, vedere le linee in tempo reale e molto altro!';

  @override
  String get welcomeDecription2 =>
      'Ecco un breve tutorial per aiutarti a capire come funziona.';

  @override
  String get settingsDarkThemeTitle => 'Tema scuro';

  @override
  String get settingsShowFavoriteRoutesTitle =>
      'Mostra linee preferite nella pagina iniziale';

  @override
  String get settingsShowSecondsTitle =>
      'Mostra secondi dall\'ultimo aggiornamento';

  @override
  String get settingsShowStopOnMapTitle => 'Mostra fermata nella mappa';

  @override
  String get settingsShowStopOnMapSubtitle =>
      'Mostra popup della fermata iniziale nella mappa';

  @override
  String get settingsHighlightInitialStopTitle => '\'Segna\' fermata iniziale';

  @override
  String get settingsHighlightInitialStopSubtitle =>
      'Mostra la fermata iniziale di colore diverso nella mappa';

  @override
  String get settingsShowRoutesWithoutPassagesTitle =>
      'Visualizza tratte senza passaggi';

  @override
  String get settingsShowRoutesWithoutPassagesSubtitle =>
      'Mostra tratte senza passaggi da \'Guarda sulla mappa\'';

  @override
  String get settingsBetaFeaturesTitle => 'Beta features';

  @override
  String get settingsBetaFeaturesSubtitle => 'Clicca per informazioni';

  @override
  String get settingsShowTutorialTitle => 'Mostra tutorial';

  @override
  String get settingsRefreshDataTitle => 'Aggiorna dati GTT';

  @override
  String get settingsDownloadReleaseTitle => 'Download release';

  @override
  String get settingsBackupFavoritesTitle => 'Backup locale preferiti';

  @override
  String get settingsRestoreFavoritesTitle => 'Ripristina preferiti';

  @override
  String get settingsShareAppTitle => 'Condividi app';

  @override
  String get settingsInfoTitle => 'Informazioni app';

  @override
  String get settingsPageTitle => 'Impostazioni';

  @override
  String settingsVersion(String version) {
    return 'Versione: $version';
  }

  @override
  String get shareAppMessage =>
      'Sto usando questa app GTT, scaricala anche tu \nhttps://github.com/amxDusT/GTT-app/releases/latest';

  @override
  String get shareAppSubject => 'GTT app';

  @override
  String developedBy(String developer) {
    return 'Sviluppato da: $developer';
  }

  @override
  String get githubLabel => 'Github: ';

  @override
  String get betaFeaturesHeading => 'Funzionalità in fase di test:';

  @override
  String get betaFeaturesWarning =>
      'ATTENZIONE! Queste funzionalità non sono ancora completamente testate e potrebbero non funzionare correttamente.';

  @override
  String get betaFeaturesList =>
      '- mappa default senza tratte\n- map api da mapbox invece di openstreetmap';

  @override
  String get moveToTop => 'Sposta in cima';

  @override
  String get changeDescription => 'Cambia Descrizione';

  @override
  String get changeColor => 'Cambia Colore';

  @override
  String get delete => 'Elimina';

  @override
  String get chooseColorTitle => 'Scegli un colore';

  @override
  String deleteStopQuestion(String stop) {
    return 'Vuoi eliminare la fermata $stop?';
  }

  @override
  String get enterShortDescription => 'Scrivi una breve descrizione';

  @override
  String get confirm => 'Conferma';

  @override
  String get cancel => 'Annulla';

  @override
  String selectedRoutesCount(int selected, int total) {
    return '$selected / $total selezionate';
  }

  @override
  String get selectRoutes => 'Seleziona linee';

  @override
  String get saveToHome => 'Salva in home';

  @override
  String get removeFromHome => 'Rimuovi dalla home';

  @override
  String lastUpdate(String time) {
    return 'Ultimo aggiornamento: $time';
  }

  @override
  String get update => 'Aggiorna';

  @override
  String errorWithCode(int code) {
    return 'Errore $code';
  }

  @override
  String get errorTitle => 'Errore';

  @override
  String get genericErrorMessage =>
      'Ooops... Problema nel risolvere la richiesta.';

  @override
  String get retryOrUpdateDataMessage =>
      'Riprova, o prova ad aggiornare i dati di GTT nelle impostazioni.';

  @override
  String get invalidAddress => 'Indirizzo non valido';

  @override
  String get stopNotFound => 'La fermata non esiste';

  @override
  String get nfcNotAvailable => 'NFC non attivo. Attivalo nelle impostazioni';

  @override
  String get nfcCardUnsupported => 'Carta non supportata';

  @override
  String get nfcTicketUnsupported => 'Biglietto non supportato';

  @override
  String get nfcTicketRemovedTooSoon =>
      'Hai rimosso il biglietto troppo presto. Riprova';

  @override
  String get nfcCardRemovedTooSoon =>
      'Hai rimosso la carta troppo presto. Riprova';

  @override
  String get nfcEmptyCard => 'Carta vuota';

  @override
  String get readCardTitle => 'Leggi Carta';

  @override
  String cardTitle(String cardNumber) {
    return 'Carta $cardNumber';
  }

  @override
  String get cardInfoHeading => 'Informazioni carta';

  @override
  String get subscriptionsHeading => 'Abbonamenti';

  @override
  String get cardNumberLabel => 'Numero Carta: ';

  @override
  String get cardTypeLabel => 'Tipo Carta: ';

  @override
  String get cardIssuedOnLabel => 'Emessa il: ';

  @override
  String get contractsLabel => 'Contratti/Abbonamenti: ';

  @override
  String ticketTitle(String cardNumber) {
    return 'Biglietto $cardNumber';
  }

  @override
  String get ticketInfoHeading => 'Informazioni biglietto:';

  @override
  String get ticketNumberLabel => 'Numero Biglietto: ';

  @override
  String get ticketTypeLabel => 'Tipo Biglietto: ';

  @override
  String get ticketFirstValidationLabel => 'Prima validazione il: ';

  @override
  String get ticketLastValidationLabel => 'Ultima validazione il: ';

  @override
  String get ticketExpiresLabel => 'Scade il: ';

  @override
  String get ticketMinutesRemainingLabel => 'Minuti mancanti: ';

  @override
  String get ticketExpiredLabel => 'Scaduto';

  @override
  String stopTitle(String stopName) {
    return 'Fermata $stopName';
  }

  @override
  String get viewOnMap => 'Guarda sulla mappa';

  @override
  String get routesTitle => 'Linee';

  @override
  String get directionLabel => 'Direzione:';

  @override
  String get readTicketOrCard => 'Leggi Biglietto/Carta';

  @override
  String get defaultMap => 'Mappa Default';

  @override
  String get loadingFirstDownload => 'Scarico i dati GTT per la prima volta..';

  @override
  String updateAvailableTitle(String version) {
    return 'Nuova versione disponibile ($version)';
  }

  @override
  String get updateAvailableBody =>
      'È disponibile una nuova versione dell\'app';

  @override
  String get whatsNewTitle => '  Novità:';

  @override
  String get downloadNewVersion => 'Scarica la nuova versione';

  @override
  String get download => 'Scarica';

  @override
  String get contractExpiredSuffix => '- Scaduto';

  @override
  String get contractNotActivatedSuffix => '(Non attivato)';

  @override
  String get startLabel => 'Inizio: ';

  @override
  String get endLabel => 'Fine: ';

  @override
  String get directionsLabel => 'Indicazioni';

  @override
  String get nearbyStopsLabel => 'Fermate vicine';

  @override
  String get positionLabel => 'Posizione';

  @override
  String get chooseDateTimeTitle => 'Scegli la data e l\'ora';

  @override
  String get resetCurrentTime => 'Reimposta ora attuale';

  @override
  String get set => 'Imposta';

  @override
  String get nfcReading => 'Sto leggendo..';

  @override
  String get nfcRead => 'Leggi';

  @override
  String get locationServiceDisabled => 'Servizio disabilitato';

  @override
  String get locationPermissionDenied => 'Permesso negato';

  @override
  String get locationPermissionDeniedForever =>
      'Permesso negato. Abilita la posizione nelle impostazioni del dispositivo';

  @override
  String get introStopTitle => 'Fermata';

  @override
  String get introStopDescription =>
      'Puoi visualizzare le linee che passano per la fermata selezionata e gli orari.';

  @override
  String get introStopDescription2 =>
      'Cliccando su una linea potrai visualizzarne i veicoli in tempo reale.\n Puoi vedere più linee contemporaneamente selezionadole e cliccando su \'Guarda sulla mappa\'.';

  @override
  String get introFavoritesTitle => 'Preferiti';

  @override
  String get introFavoritesDescription =>
      'Puoi tenere premuta una fermata nei preferiti per modificarla.';

  @override
  String get introFavoritesDescription2 =>
      'Cliccando su \'Posizione\' verrai portato alla mappa con la fermata selezionata.\n Tenendolo premuto, potrai modificare la posizione della fermata nei preferiti.';

  @override
  String get introTicketTitle => 'Informazioni biglietto';

  @override
  String get introTicketDescription =>
      'Puoi visualizzare le informazioni del biglietto o della carta.';

  @override
  String get introTicketDescription2 =>
      'Dopo aver cliccato il tasto \'Leggi\' appoggia il biglietto o la carta dietro il telefono.\n(Solo per dispositivi con NFC abilitato)';

  @override
  String get introHomeTitle => 'Pagina iniziale';

  @override
  String get introHomeDescription =>
      'Puoi cercare le fermate per nome o numero.';

  @override
  String get introHomeDescription2 =>
      'Puoi cliccare sull\'icona a forma di stella per aggiungere o togliere una fermata ai preferiti.';

  @override
  String get introVehicleListTitle => 'Lista veicoli';

  @override
  String get introVehicleListDescription =>
      'Puoi visualizzare, cercare o salvare le linee che ti interessano.';

  @override
  String get introVehicleListDescription2 =>
      'Cliccando su una linea potrai visualizzarne i veicoli in tempo reale.';

  @override
  String get searchStop => 'Cerca fermata...';

  @override
  String get searchVehicle => 'Cerca veicolo...';

  @override
  String get searchAddress => 'Cerca indirizzo...';

  @override
  String get makeDefault => 'Rendi predefinito';

  @override
  String selectMaxVehicles(int maxRoutesInMap) {
    return 'Puoi selezionare al massimo $maxRoutesInMap veicoli';
  }
}
