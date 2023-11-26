import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gtt/resources/utils/gtt_date.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:intl/intl.dart';

enum CardType { cardBip, cardPYou, cardEdisu, cardNone }

@immutable
class Contract {
  late final int code;
  final int counters;
  late final bool isValid;
  late final bool isTicket;
  late final bool isSubscription;
  late final DateTime _startDate;
  late final DateTime _endDate;
  late final bool _isActivated;
  Contract(
      {required Uint8List data,
      required this.counters,
      required bool activated}) {
    _isActivated = activated;
    int company = data[0];
    code = Utils.getBytesFromPage(data, 4, 2);
    //code = ((data[4] & 0xff) << 8) | data[5] & 0xff;
    if (code == 0 || company != 1) {
      isValid = false;
    } else {
      isValid = true;
    }
    if (ticketCodes.containsKey(code)) {
      isTicket = true;
      isSubscription = false;
    } else if (subscriptionCodes.containsKey(code)) {
      isTicket = false;
      isSubscription = true;
    } else {
      isTicket = false;
      isSubscription = false;
    }

    int minutes = ~(Utils.getBytesFromPage(data, 9, 3)) & 0xffffff;
    _startDate = GttDate.decodeFromMinutes(minutes);

    minutes = ~(Utils.getBytesFromPage(data, 12, 3)) & 0xffffff;
    _endDate = GttDate.decodeFromMinutes(minutes);
  }
  bool get isActivated => _isActivated;
  bool get isExpired => DateTime.now().isAfter(_endDate);
  String get startDate => Utils.dateToString(_startDate);
  String get endDate => Utils.dateToString(_endDate);
  int get rides => (code == 712 || code == 714)
      ? (((counters & 0x0000ff) & 0x78) >> 3)
      : (counters >> 19);
  String get typeName => isTicket
      ? ticketCodes[code]!
      : isSubscription
          ? subscriptionCodes[code]!
          : "Unknwon";
  @override
  String toString() {
    return "type: ${isTicket ? ticketCodes[code] : subscriptionCodes[code]}, endDate: ${_endDate.toString()}";
  }
}

class SmartCard {
  late final CardType cardType;
  final List<Contract> subscriptions = [];
  final List<Contract> tickets = [];
  final List<Contract> allContracts = [];
  Contract? mainSubscription;
  late final DateTime _creationDate;
  late final DateTime validationDate;
  late final int remainingMins;
  late final int cardNumber;
  int ridesLeft = 0;
  SmartCard({required List<Uint8List> information}) {
    Uint8List efEnvironment = information[1];

    cardNumber = Utils.getBytesFromPage(information[0], 29, 4);

    // get type of card
    int cardTypeInt = efEnvironment[28];
    if (cardTypeInt == 0xC0) {
      cardType = CardType.cardBip;
    } else if (cardTypeInt == 0xC1) {
      cardType = CardType.cardPYou;
    } else if (cardTypeInt == 0xC2) {
      cardType = CardType.cardEdisu;
    } else {
      cardType = CardType.cardNone;
    }

    int minutes = Utils.getBytesFromPage(efEnvironment, 9, 3);
    _creationDate = GttDate.decodeFromMinutes(minutes);

    getContracts(information);

    DateTime latestExpireDate = GttDate.getGttEpoch();

    for (Contract sub in subscriptions) {
      if (latestExpireDate.isBefore(sub._endDate)) {
        latestExpireDate = sub._endDate;
        mainSubscription = sub;
      }
    }
    final eventLogs1 = information[11];
    final eventLogs2 = information[12];
    final eventLogs3 = information[13];

    // last validation time
    int mins = Utils.getBytesFromPage(eventLogs1, 20, 3);
    if (mins == 0) {
      mins = Utils.getBytesFromPage(eventLogs2, 20, 3);
    }
    if (mins == 0) {
      mins = Utils.getBytesFromPage(eventLogs3, 20, 3);
    }
    validationDate = GttDate.addMinutesToDate(mins, GttDate.getGttEpoch());
    DateTime now = DateTime.now();
    int diff = now.difference(validationDate).inMinutes;

    int num = eventLogs1[25] >> 4;
    int ticketType = Utils.getBytesFromPage(information[num + 2], 4, 2);

    int maxtime = 90;
    //city 100
    if (ticketType == 714) {
      maxtime = 100;
    }
    //daily
    else if (ticketType == 715 || ticketType == 716) {
      remainingMins = GttDate.getMinutesUntilEndOfService(validationDate);
    } else if (diff >= maxtime) {
      remainingMins = 0;
    } else {
      remainingMins = maxtime - diff;
    }
  }

  void getContracts(List<Uint8List> information) {
    Uint8List contractsByte = information[2];
    Uint8List countersByte = information[14];
    for (int i = 1; i < 23; i += 3) {
      if (contractsByte[i] == 1) {
        // TODO: check if has been activated???
        // ignore: dead_code
        if (true || (contractsByte[i + 1] & 0x0f) == 1) {
          //int cpos = (((contractsByte[i + 2] & 0xff).abs() >> 4) - 1) * 3; // original
          int cpos = ((contractsByte[i + 2] >> 4) - 1) * 3;
          int counter = 0;
          if (cpos >= 0) {
            counter = Utils.getBytesFromPage(countersByte, cpos, 3);
          }
          var data = information[i ~/ 3 + 3];
          Contract contract = Contract(
              data: data,
              counters: counter,
              activated: (contractsByte[i + 1] & 0x0f) == 1);
          if (contract.isValid) {
            allContracts.add(contract);
            if (contract.isSubscription) {
              subscriptions.add(contract);
            } else {
              tickets.add(contract);
              ridesLeft += contract.rides;
            }
          }
        }
      }
    }
    allContracts.sort((c1, c2) {
      return c2._endDate.compareTo(c1._endDate);
    });
  }

  String get ticketName {
    if (hasTickets) {
      return "${cardType.toString()} - ${tickets[0].typeName}";
    } else {
      return cardType.toString();
    }
  }

  bool get hasTickets =>
      tickets.isNotEmpty || ridesLeft != 0 || remainingMins > 0;
  bool get hasSubscriptions => subscriptions.isNotEmpty;

  String get subscriptionName => hasSubscriptions
      ? "$cardType - ${mainSubscription!.typeName}"
      : cardType.toString();
  String get startDateAsString =>
      DateFormat('MMMM d, y H:mm a').format(mainSubscription!._startDate);
  String get expiredDateAsString =>
      DateFormat('MMMM d, y H:mm a').format(mainSubscription!._endDate);
  String get validationDateAsString =>
      DateFormat('MMMM d, y H:mm a').format(validationDate);
  bool get isSubscriptionExpired =>
      DateTime.now().isAfter(mainSubscription!._endDate);

  int get remainingRides => ridesLeft;
  int get remainingMinutes => remainingMins < 0 ? 0 : remainingMins;
  bool isExpired(DateTime date) => DateTime.now().isAfter(date);

  String get creationDate => Utils.dateToString(_creationDate);
}
