import 'package:flutter/material.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/models/smart_card/chip_paper.dart';

class TicketInfoPage extends StatelessWidget {
  final ChipPaper ticket;
  const TicketInfoPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ticketTitle(ticket.cardNumber.toString())),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.ticketInfoHeading),
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
        color: ticket.isExpired ? Colors.red : Colors.green,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(l10n.ticketNumberLabel),
              Text(ticket.cardNumber.toString()),
            ],
          ),
          Row(
            children: [
              Text(l10n.ticketTypeLabel),
              Text(ticket.typeName),
            ],
          ),
          Row(
            children: [
              Text(l10n.ticketFirstValidationLabel),
              Text(ticket.firstValidationDate),
            ],
          ),
          Row(
            children: [
              Text(l10n.ticketLastValidationLabel),
              Text(ticket.lastValidationDate),
            ],
          ),
          Row(
            children: [
              Text(l10n.ticketExpiresLabel),
              Text(ticket.expiredDate),
            ],
          ),
          Row(
            children: [
              Text(l10n.ticketMinutesRemainingLabel),
              Text(ticket.isExpired
                  ? l10n.ticketExpiredLabel
                  : ticket.remainingMinutes.toString()),
            ],
          ),
        ],
      ),
    );
  }
}
