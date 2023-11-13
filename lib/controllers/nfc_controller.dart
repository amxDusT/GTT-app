import 'package:convert/convert.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gtt/models/smart_card/card_files.dart';
import 'package:flutter_gtt/models/smart_card/chip_paper.dart';
import 'package:flutter_gtt/models/smart_card/smart_card.dart';
import 'package:flutter_gtt/pages/nfc/card_info_page.dart';
import 'package:flutter_gtt/pages/nfc/ticket_info_page.dart';
import 'package:flutter_gtt/resources/utils/apdu_utils.dart';
import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

class NfcController extends GetxController {
  final _readBuffer = Uint8List(1024);
  void readCard() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        print('reading...');
        await _handleResponse(tag);
      } on PlatformException {
        Get.snackbar("Error", "You removed the card too fast. Try again");
      } finally {
        NfcManager.instance.stopSession();
      }
    });
  }

  void testSmartCard() {}
  void testTicket() {}
  void testDefault() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        await _testDefaultHandleResponse(tag);
        //await Future.delayed(Duration(seconds: 2));
      } on PlatformException {
        Get.snackbar("Error", "You removed the card too fast. Try again");
      } finally {
        NfcManager.instance.stopSession();
      }
    });
  }

  Future<void> _testDefaultHandleResponse(NfcTag tag) async {
    update();
  }

  Future<void> _handleResponse(NfcTag tag) async {
    final isoDepTag = IsoDep.from(tag);
    final nfcaTag = NfcA.from(tag);

    if (isoDepTag != null) {
      await _handleIsoDep(isoDepTag);
    } else if (nfcaTag != null) {
      print('nfcA tag');
      await _handleNfcA(nfcaTag);
    } else {
      Get.snackbar('Error', 'Card not supported');
    }
  }

  Future<void> _handleNfcA(NfcA tag) async {
    Uint8List atqa = tag.atqa;
    if (tag.sak != 0x00 ||
        atqa.length != 2 ||
        atqa[0] != 0x44 ||
        atqa[1] != 0x00) {
      Get.snackbar('Error', 'Card not supported');
      return;
    }

    int pagesRead;
    List<Uint8List> list = [];
    pagesRead = await rdNumPages(tag, 32);

    for (int i = 0; i < pagesRead * 4; i += 4) {
      Uint8List tagPage = Uint8List(4);
      tagPage.setRange(0, 4, _readBuffer, i);
      list.add(tagPage);
    }

    if (pagesRead >= 16) {
      //good
      ChipPaper chip = ChipPaper(information: list);
      Get.to(
          () => TicketInfoPage(
                ticket: chip,
              ),
          arguments: {'ticket': chip});
      /*for(int i = 0; i < list.length; i++){
        result.value.putIfAbsent(i.toString(), () => hex.encode(list[i]));
      }*/

      // print({
      //   'number': chip.cardNumber,
      //   'typeName': chip.typeName,
      //   'firstValidationDate': chip.firstValidationDate,
      //   'lastValidationDate': chip.lastValidationDate,
      //   'expiredDate': chip.expiredDate,
      //   'remainingMins': chip.remainingMinutes,
      //   'rides': chip.remainingRides,
      // });
    } else {
      Get.snackbar('Error', 'Could not read card');
    }
  }

  Future<int> rdNumPages(NfcA mfu, int num) async {
    int pagesRead = 0;

    while (await rdPages(mfu, pagesRead) == 0) {
      pagesRead++;
      if (pagesRead == num || pagesRead == 256) break;
    }
    return pagesRead;
  }

  Future<int> rdPages(NfcA tag, int pageOffset) async {
    Uint8List cmd = Uint8List.fromList([0x30, pageOffset]);
    Uint8List response = Uint8List(16);
    try {
      response = await tag.transceive(data: cmd);
    } catch (e) {
      return 1;
    }
    if (response.length != 16) {
      return 1;
    }
    _readBuffer.setRange(pageOffset * 4, (pageOffset * 4) + 4, response);

    return 0;
  }

  Future<void> _handleIsoDep(IsoDep tag) async {
    List<Uint8List> list = [];
    // select transport application
    list.add(await tag.transceive(
        data: ApduUtils.getSelectAIDCommand(
            Uint8List.fromList(hex.decode(CardFileType.DF1Hex)))));

    // EF Environment
    list.add(await ApduUtils.readRecordId(tag, CardFileType.EF_ENVIRONMENT, 1));
    // EF Contracts List
    list.add(
        await ApduUtils.readRecordId(tag, CardFileType.EF_CONTRACT_LIST, 1));

    // EF Contracts
    list.addAll(
        await ApduUtils.getReadRecordFile(tag, CardFileType.EF_CONTRACTS));

    // EF Event Logs
    list.addAll(
        await ApduUtils.getReadRecordFile(tag, CardFileType.EF_EVENTS_LOG));

    //EF Counters
    list.add(
        await ApduUtils.readRecordId(tag, CardFileType.TICKET_COUNTERS, 1));

    if (list.length == 15 && list[1][0] != 0) {
      if (list[2][1] == 0) {
        //empty smartcard
        Get.snackbar('Error', 'Card is empty(?)');
        return;
      }

      /// all goood
    } else {
      //invalid
      Get.snackbar('Error', 'Invalid card');
      return;
    }
    _readData(list);
  }

  void _readData(List<Uint8List> list) {
    SmartCard smartCard = SmartCard(information: list);
    Get.to(
        () => CardInfoPage(
              smartCard: smartCard,
            ),
        arguments: {'card': smartCard});

    // print({
    //   'type': 'smartcard',
    //   'cardType': smartCard.cardType,
    //   'creationDate': smartCard.creationDate,
    //   'subscriptions': smartCard.hasSubscriptions,
    //   'tickets': smartCard.hasTickets,
    //   'subType': smartCard.subscriptionName,
    //   //'tickType': smartCard.ticketName,
    //   'remainingRides': smartCard.remainingRides,
    //   'remainingMins': smartCard.remainingMinutes,
    //   'startDate': smartCard.startDateAsString,
    //   'expiredDate': smartCard.expiredDateAsString,
    //   'validationDate': smartCard.validationDateAsString,
    //   'isSubExpired': smartCard.isSubscriptionExpired,
    //   'subs': smartCard.subscriptions,
    //   'tickets2': smartCard.tickets,
    //   'cardNumber': smartCard.cardNumber,
    // });
  }
}
