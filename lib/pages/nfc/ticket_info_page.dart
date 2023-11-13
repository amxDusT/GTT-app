import 'package:flutter/material.dart';
import 'package:flutter_gtt/models/smart_card/chip_paper.dart';

class TicketInfoPage extends StatelessWidget {
  final ChipPaper ticket;
  const TicketInfoPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Biglietto ${ticket.cardNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Informazioni biglietto:"),
            _infoTicket(),
          ],
        ),
      ),
    );
  }
  Widget _infoTicket() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 200,
      decoration: BoxDecoration(
        color: ticket.isExpired? Colors.red:Colors.green,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text("Numero Biglietto: "),
              Text(ticket.cardNumber.toString()),
            ],
          ),
          Row(
            children: [
              const Text("Tipo Biglietto: "),
              Text(ticket.typeName),
            ],
          ),
          Row(
            children: [
              const Text("Prima validazione il: "),
              Text(ticket.firstValidationDate),
            ],
          ),
          Row(
            children: [
              const Text("Ultima validazione il: "),
              Text(ticket.lastValidationDate),
            ],
          ),
          Row(
            children: [
              const Text("Scade il: "),
              Text(ticket.expiredDate),
            ],
          ),
          Row(
            children: [
              const Text("Minuti mancanti: "),
              Text(ticket.isExpired? 'Scaduto':ticket.remainingMinutes.toString()),
            ],
          ),
           
        ],
      ),
    );
  }
}