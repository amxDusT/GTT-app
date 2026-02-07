import 'dart:typed_data';

import 'package:torino_mobility/resources/utils/gtt_date.dart';
import 'package:torino_mobility/resources/utils/utils.dart';

class ChipPaper {
  late final DateTime _lastDate;
  late final DateTime _firstDate;
  late final DateTime _expiredDate;
  late final int _type;
  late final Uint8List _cardNumberList;
  int _remainingMins = 0;
  int remainingRides = 0;
  ChipPaper({required List<Uint8List> information}) {
    _cardNumberList = Uint8List.fromList(
        [...information[0].sublist(0, 3), ...information[1]]);

    _type = Utils.getBytesFromPage(information[5], 2, 2);
    int firstValMinutes = Utils.getBytesFromPage(information[10], 0, 3);
    int lastValMinutes = Utils.getBytesFromPage(information[12], 0, 3);
    if (_type == 9521) {
      firstValMinutes = Utils.getBytesFromPage(information[12], 0, 3);
    }
    _lastDate = GttDate.addMinutesToDate(lastValMinutes, GttDate.getGttEpoch());
    _firstDate =
        GttDate.addMinutesToDate(firstValMinutes, GttDate.getGttEpoch());

    int diff = DateTime.now().difference(_firstDate).inMinutes;
    int maxTime = 90;

    //city 100
    if (_type == 302 || _type == 304 || _type == 650 || _type == 651) {
      maxTime = 100;
    }

    //Tour 2 giorni
    if (_type == 288) {
      maxTime = 2 * 24 * 60;
    }
    //Tour 3 giorni
    if (_type == 289) {
      maxTime = 3 * 24 * 60;
    }
    if (_type != 303 && _type != 305) {
      _expiredDate = _firstDate.add(Duration(minutes: maxTime));
    }
    //daily
    if (_type == 303 || _type == 305) {
      _remainingMins = GttDate.getMinutesUntilEndOfService(_firstDate);
      _expiredDate = DateTime.now().add(Duration(minutes: _remainingMins));
    } else if (diff >= maxTime) {
      _remainingMins = 0;
    } else {
      _remainingMins = maxTime - diff;
    }

    // calcola le corse rimanenti
    // TODO: corse in metropolitana (forse bit più significativo pag. 3)
    int tickets;
    if (_type == 300) {
      //extraurbano
      tickets = ~Utils.getBytesFromPage(information[3], 0, 4);
    } else {
      tickets = ~Utils.getBytesFromPage(information[3], 2, 2) & 0xFFFF;
    }
    remainingRides = Utils.bitCount(tickets);
  }

  String get typeName {
    //http://www.gtt.to.it/cms/biglietti-abbonamenti/biglietti/biglietti-carnet
    switch (_type) {
      case 284:
        return 'Tour 2 giorni';
      case 285:
        return 'Tour 3 giorni';
      case 288:
        return 'OLD Tour 2 giorni';
      case 289:
        return 'OLD Tour 3 giorni';
      case 300:
        return 'Extraurbano';
      case 301:
        return 'Multicorsa extraurbano';
      case 302:
      case 304:
        return 'OLD City 100';
      case 364:
        return 'Biglietto rete Urbana Ivrea e Dintorni';
      case 370:
        return 'Carnet 5 corse rete Urbana Ivrea e Dintorni';
      case 371:
        return 'Carnet 15 corse rete Urbana Ivrea e Dintorni';
      case 375:
        return 'City 100';
      case 376:
        return 'Daily';
      case 303:
      case 305:
        return 'OLD Daily';
      case 650:
      case 651:
        return 'OLD MultiCity';
      case 658:
        return 'Multicity';
      case 702:
      case 706:
        return 'Carnet 5 corse';
      case 701:
      case 705:
        return 'Carnet 15 corse';
      case 9521:
        return 'Sadem Aeroporto Torino';
      default:
        return 'Non riconosciuto';
    }
  }

  String get firstValidationDate => Utils.dateToString(_lastDate);
  String get lastValidationDate => Utils.dateToString(_firstDate);
  String get expiredDate => Utils.dateToString(_expiredDate);
  bool get isExpired => DateTime.now().isAfter(_expiredDate);
  int get remainingMinutes => _remainingMins <= 0 ? 0 : _remainingMins;
  int get cardNumber =>
      Utils.getBytesFromPage(_cardNumberList, 0, _cardNumberList.length);
}
