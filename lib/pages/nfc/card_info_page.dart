import 'package:flutter/material.dart';
import 'package:flutter_gtt/models/smart_card/smart_card.dart';
import 'package:flutter_gtt/widgets/card_info_widget.dart';

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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Informazioni carta:"),
            _infoCard(),
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
      height: 200,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text("Numero Carta: "),
              Text(smartCard.cardNumber.toString()),
            ],
          ),
          Row(
            children: [
              const Text("Tipo Carta: "),
              Text(smartCard.cardType.toString()),
            ],
          ),
          Row(
            children: [
              const Text("Emessa il: "),
              Text(smartCard.creationDate),
            ],
          ),
           Row(
            children: [
              const Text("Contratti: "),
              Text(smartCard.allContracts.length.toString()),
            ],
          ),
        ],
      ),
    );
  }
}
