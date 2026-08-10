import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/models/smart_card/smart_card.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';

class CardInfoPage extends StatelessWidget {
  final SmartCard smartCard;
  const CardInfoPage({super.key, required this.smartCard});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final active = smartCard.allContracts.where((c) => !c.isExpired).length;
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
                    color: t.good,
                    icon: Icons.check_rounded,
                    label: 'tessera letta'.hc,
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
                    'Carta ${_cardTypeName(smartCard.cardType)} · n° ${smartCard.cardNumber}'
                        .hc,
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
                          text: 'carta'.hc,
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
              child: _infoCard(t, [
                ['Numero carta'.hc, smartCard.cardNumber.toString()],
                ['Tipo carta'.hc, _cardTypeName(smartCard.cardType)],
                ['Emessa il'.hc, smartCard.creationDate],
                ['Abbonamenti'.hc, smartCard.allContracts.length.toString()],
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Abbonamenti'.hc,
                    style: Fonts.title(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: t.ink,
                    ),
                  ),
                  Text(
                    '$active attivi · ${smartCard.allContracts.length} totali'
                        .hc,
                    style: Fonts.subtitle(fontSize: 11, color: t.inkMute),
                  ),
                ],
              ),
            ),
            for (final contract in smartCard.allContracts)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _contractCard(t, contract),
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

  Widget _contractCard(AppTokens t, Contract contract) {
    final bool isActive = !contract.isExpired;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isActive ? t.soft(t.good, light: 0.08, dark: 0.11) : t.bgInset,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? t.good.withValues(alpha: 0.3) : t.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  contract.typeName,
                  style: Fonts.title(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -0.1,
                    color: t.ink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _statusPill(t, isActive),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _dateField(t, 'Inizio'.hc, contract.startDate),
              const SizedBox(width: 24),
              _dateField(t, 'Fine'.hc, contract.endDate),
            ],
          ),
          if (!contract.isActivated) ...[
            const SizedBox(height: 12),
            Text(
              'non attivato'.hc,
              style: Fonts.subtitle(fontSize: 10, color: t.inkMute),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateField(AppTokens t, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style:
              Fonts.subtitle(fontSize: 9, letterSpacing: 1.4, color: t.inkMute),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Fonts.title(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: t.inkDim,
          ),
        ),
      ],
    );
  }

  Widget _statusPill(AppTokens t, bool isActive) {
    final Color bg = isActive ? t.good : t.soft(t.bad, light: 0.09, dark: 0.13);
    final Color fg = isActive ? t.onAccent : t.bad;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? Icons.check_rounded : Icons.close_rounded,
              size: 12, color: fg),
          const SizedBox(width: 5),
          Text(
            isActive ? 'Attivo'.hc : 'Scaduto'.hc,
            style: Fonts.subtitle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: fg,
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

  String _cardTypeName(CardType type) {
    switch (type) {
      case CardType.cardBip:
        return 'BIP';
      case CardType.cardPYou:
        return 'PYou';
      case CardType.cardEdisu:
        return 'Edisu';
      case CardType.cardNone:
        return '—';
    }
  }
}
