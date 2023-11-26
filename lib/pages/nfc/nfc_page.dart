import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/nfc_controller.dart';
import 'package:get/get.dart';

class NfcPage extends StatelessWidget {
  NfcPage({super.key});

  final _nfcController = Get.put(NfcController());

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'NFCPage',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leggi Carta'),
        ),
        body: Flex(
          direction: Axis.vertical,
          children: [
            Flexible(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(4),
                constraints: const BoxConstraints.expand(),
                decoration: BoxDecoration(border: Border.all()),
                child: const SingleChildScrollView(
                  child: Text('non importante'),
                ),
              ),
            ),
            Flexible(
              flex: 3,
              child: GridView.count(
                padding: const EdgeInsets.all(4),
                crossAxisCount: 2,
                childAspectRatio: 4,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                children: [
                  ElevatedButton(
                      onPressed: _nfcController.readCard,
                      child: const Text('Read Card')),
                  ElevatedButton(
                      onPressed: _nfcController.testTicket,
                      child: const Text('Test Ticket')),
                  ElevatedButton(
                      onPressed: _nfcController.testSmartCard,
                      child: const Text('Test SmartCard')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
