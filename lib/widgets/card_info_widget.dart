import 'package:flutter/material.dart';
import 'package:torino_mobility/models/smart_card/smart_card.dart';

class CardInfoWidget extends StatelessWidget {
  final Contract contract;
  const CardInfoWidget({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: contract.isExpired ? null : Colors.green,
      child: ListTile(
        isThreeLine: true,
        title: Text(
            '${contract.typeName} ${contract.isExpired ? '- Scaduto' : ''} ${contract.isActivated ? '' : '(Non attivato)'}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inizio: ${contract.startDate}'),
            Text('Fine: ${contract.endDate}'),
          ],
        ),
      ),
    );
  }
}
