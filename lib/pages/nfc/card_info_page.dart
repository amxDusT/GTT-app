import 'package:flutter/material.dart';
import 'package:torino_mobility/models/smart_card/smart_card.dart';
import 'package:torino_mobility/widgets/card_info_widget.dart';
import 'package:get/get.dart';

class CardInfoPage extends StatelessWidget {
  final SmartCard smartCard;
  const CardInfoPage({super.key, required this.smartCard});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carta ${smartCard.cardNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Informazioni carta',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _infoCard(),
            const SizedBox(height: 20),
            const Text(
              'Abbonamenti',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Flexible(
              flex: 3,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shrinkWrap: true,
                itemCount: smartCard.allContracts.length,
                itemBuilder: (context, index) =>
                    CardInfoWidget(contract: smartCard.allContracts[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      //height: 200,
      decoration: BoxDecoration(
        color: Get.theme.primaryColorLight,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Numero Carta: '),
              Text(smartCard.cardNumber.toString()),
            ],
          ),
          Row(
            children: [
              const Text('Tipo Carta: '),
              Text(smartCard.cardType.toString()),
            ],
          ),
          Row(
            children: [
              const Text('Emessa il: '),
              Text(smartCard.creationDate),
            ],
          ),
          Row(
            children: [
              const Text('Contratti/Abbonamenti: '),
              Text(smartCard.allContracts.length.toString()),
            ],
          ),
        ],
      ),
    );
  }
}
