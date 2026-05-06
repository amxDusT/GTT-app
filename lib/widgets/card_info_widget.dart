import 'package:flutter/material.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/models/smart_card/smart_card.dart';

class CardInfoWidget extends StatelessWidget {
  final Contract contract;
  const CardInfoWidget({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    final expiredSuffix =
        contract.isExpired ? ' ${l10n.contractExpiredSuffix}' : '';
    final notActivatedSuffix =
        contract.isActivated ? '' : ' ${l10n.contractNotActivatedSuffix}';
    return Card(
      color: contract.isExpired ? null : Colors.green,
      child: ListTile(
        isThreeLine: true,
        title: Text('${contract.typeName}$expiredSuffix$notActivatedSuffix'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.startLabel}${contract.startDate}'),
            Text('${l10n.endLabel}${contract.endDate}'),
          ],
        ),
      ),
    );
  }
}
