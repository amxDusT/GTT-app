import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gtt/models/smart_card/card_files.dart';
import 'package:flutter_gtt/models/smart_card/chip_paper.dart';
import 'package:flutter_gtt/models/smart_card/smart_card.dart';
import 'package:flutter_gtt/pages/nfc/card_info_page.dart';
import 'package:flutter_gtt/pages/nfc/ticket_info_page.dart';
import 'package:flutter_gtt/resources/utils/apdu_utils.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

class NfcController extends GetxController with GetTickerProviderStateMixin {
  final RxBool isReading = false.obs;
  final _readBuffer = Uint8List(1024);
  static const Duration _duration = Duration(milliseconds: 500);
  static const _containerHeight = 150.0;

  late final AnimationController _animationController;
  late final Animation<double> animation;
  late final RxDouble value = _containerHeight.obs;

  @override
  void onInit() {
    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
    );
    animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    final Tween<double> tween =
        Tween(begin: _containerHeight, end: _containerHeight + 50);
    _animationController.addListener(() {
      value.value = tween.evaluate(animation);
    });
    isAvailable();
    super.onInit();
  }

  void isAvailable() async {
    final available = await NfcManager.instance.isAvailable();
    if (!available) {
      Get.back(closeOverlays: true);
      Utils.showSnackBar(
        'NFC non attivo. Attivalo nelle impostazioni',
        closePrevious: true,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () async {
            await NfcManager.instance.openNfcSettings();
          },
          child: const Text('Impostazioni'),
        ),
      );
    }
  }

  @override
  void onClose() {
    stopReading();
    _animationController.dispose();
    super.onClose();
  }

  void readCard() {
    isReading.value = true;
    _startAnimation();
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        await _handleResponse(tag);
      } on PlatformException {
        Utils.showSnackBar('Hai rimosso la carta troppo presto. Riprova');
      } finally {
        stopReading();
      }
    });
  }

  void _startAnimation() {
    _animationController.repeat(reverse: true);
  }

  void stopReading() {
    NfcManager.instance.stopSession();
    isReading.value = false;
    _animationController.reset();
  }

  Future<void> _handleResponse(NfcTag tag) async {
    final isoDepTag = IsoDep.from(tag);
    final nfcaTag = NfcA.from(tag);

    if (isoDepTag != null) {
      await _handleIsoDep(isoDepTag);
    } else if (nfcaTag != null) {
      await _handleNfcA(nfcaTag);
    } else {
      Utils.showSnackBar('Carta non supportata');
    }
  }

  Future<void> _handleNfcA(NfcA tag) async {
    Uint8List atqa = tag.atqa;
    if (tag.sak != 0x00 ||
        atqa.length != 2 ||
        atqa[0] != 0x44 ||
        atqa[1] != 0x00) {
      Utils.showSnackBar('Biglietto non supportato');
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
      Utils.showSnackBar('Hai rimosso il biglietto troppo presto. Riprova');
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
        Utils.showSnackBar('Carta vuota');
        //Get.snackbar('Error', 'Card is empty(?)');
        return;
      }

      /// all goood
    } else {
      //invalid
      Utils.showSnackBar('Carta non supportata');
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
