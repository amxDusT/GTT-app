import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/nfc_controller.dart';
import 'package:get/get.dart';

class NfcPage extends StatelessWidget {
  final NfcController _nfcController;
  NfcPage({super.key}) : _nfcController = Get.put(NfcController());

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'NFCPage',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leggi Carta'),
        ),
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Align(
              alignment: Alignment.center,
              child: Obx(
                () => InkWell(
                  //radius: 100,
                  borderRadius: BorderRadius.circular(100),
                  onTap: _nfcController.isReading.isTrue
                      ? _nfcController.stopReading
                      : _nfcController.readCard,
                  child: Ink(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Get.theme.primaryColorLight,
                          shape: BoxShape.circle,
                          border: Border.all(width: 1)
                          //borderRadius: BorderRadius.circular(100),
                          ),
                      child: Center(
                        child: Text(
                          _nfcController.isReading.isTrue
                              ? 'Sto leggendo..'
                              : 'Leggi',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      )),
                ),
              ),
            ),
            Obx(
              () => Positioned(
                bottom: _nfcController.isReading.isTrue ? 20 : 20,
                child: TextButton(
                  onPressed: _nfcController.stopReading,
                  style: TextButton.styleFrom(
                    backgroundColor: Get.theme.colorScheme.errorContainer,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Get.theme.colorScheme.secondary,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    'Annulla',
                    style: TextStyle(color: Get.theme.colorScheme.secondary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
