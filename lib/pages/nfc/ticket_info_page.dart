import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/models/smart_card/chip_paper.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';

class TicketInfoPage extends StatelessWidget {
  final ChipPaper ticket;
  const TicketInfoPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final bool valid = !ticket.isExpired;
    final rows = <List<String>>[
      ['Numero'.hc, ticket.cardNumber.toString()],
      ['Tipo'.hc, ticket.typeName],
      ['Prima convalida'.hc, ticket.firstValidationDate],
      ['Ultima convalida'.hc, ticket.lastValidationDate],
      ['Scadenza'.hc, ticket.expiredDate],
      [
        'Minuti rimanenti'.hc,
        valid ? '${ticket.remainingMinutes} min'.hc : 'Scaduto'.hc,
      ],
      if (ticket.remainingRides > 0)
        ['Corse rimanenti'.hc, ticket.remainingRides.toString()],
    ];
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: t.bgRaised,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.line),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: t.ink),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _badge(
                    t,
                    color: valid ? t.good : t.bad,
                    icon: valid ? Icons.check_rounded : Icons.close_rounded,
                    label: valid ? 'valido'.hc : 'scaduto'.hc,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biglietto · n° ${ticket.cardNumber}'.hc,
                    style: Fonts.subtitle(
                      fontSize: 10,
                      letterSpacing: 1.8,
                      color: t.inkMute,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Informazioni\n'.hc,
                          style: Fonts.title(
                            fontSize: 40,
                            height: 1.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                            color: t.ink,
                          ),
                        ),
                        TextSpan(
                          text: 'biglietto'.hc,
                          style: Fonts.title(
                            fontSize: 40,
                            height: 1.0,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                            letterSpacing: -1,
                            color: t.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: _infoCard(t, rows),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(AppTokens t, List<List<String>> rows) {
    return Container(
      decoration: BoxDecoration(
        color: t.bgRaised,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: t.line),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: i < rows.length - 1 ? t.line : Colors.transparent,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    rows[i][0].toUpperCase(),
                    style: Fonts.subtitle(fontSize: 11, color: t.inkMute),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rows[i][1],
                      textAlign: TextAlign.right,
                      style: Fonts.title(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                        color: t.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _badge(
    AppTokens t, {
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 6, 11, 6),
      decoration: BoxDecoration(
        color: t.soft(color),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 7),
          Text(
            label.toUpperCase(),
            style: Fonts.subtitle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
