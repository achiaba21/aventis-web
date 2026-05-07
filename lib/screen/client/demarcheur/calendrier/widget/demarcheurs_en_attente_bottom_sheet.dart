import 'package:flutter/material.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/screen/client/demarcheur/calendrier/helper/day_analysis.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Bottom sheet affichant les demandes EN_ATTENTE concurrentes sur un jour.
///
/// - Cas C : affiche la liste + bouton "Créer ma réservation"
/// - Cas D : affiche la liste en lecture seule (onCreateReservation == null)
class DemarcheursEnAttenteBottomSheet extends StatelessWidget {
  final List<CalendarPlage> plages;
  final String userTelephone;
  final VoidCallback? onCreateReservation;

  const DemarcheursEnAttenteBottomSheet({
    super.key,
    required this.plages,
    required this.userTelephone,
    this.onCreateReservation,
  });

  DayAnalysis get _analysis => DayAnalysis(
        plages: plages,
        userTelephone: userTelephone,
      );

  @override
  Widget build(BuildContext context) {
    final analysis = _analysis;
    final enAttente = analysis.enAttentePlages;
    final count = enAttente.length;
    final headerColor = analysis.headerColor;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HandleBar(),
          _Header(count: count, color: headerColor),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: enAttente.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _DemandeurItem(plage: enAttente[i]),
            ),
          ),
          if (onCreateReservation != null)
            _CreateButton(onTap: onCreateReservation!),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _HandleBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textSecondary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int count;
  final Color color;

  const _Header({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          TextSeed(
            '$count demande${count > 1 ? 's' : ''} en attente',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _DemandeurItem extends StatelessWidget {
  final CalendarPlage plage;

  const _DemandeurItem({required this.plage});

  String get _initial {
    final nom = plage.demarcheurNom ?? '';
    return nom.isNotEmpty ? nom[0].toUpperCase() : '?';
  }

  String get _nom => plage.demarcheurNom ?? 'Inconnu';

  String get _telephone => plage.demarcheurTelephone ?? '';

  String get _montant {
    // Formatage FCFA : séparateur espace par milliers (ex: 75 000 FCFA)
    final montantEntier = plage.montant.toInt();
    if (montantEntier >= 1000) {
      final parts = <String>[];
      var reste = montantEntier;
      while (reste > 0) {
        parts.insert(0, (reste % 1000).toString().padLeft(parts.isEmpty ? 1 : 3, '0'));
        reste ~/= 1000;
      }
      return '${parts.join(' ')} FCFA';
    }
    return '$montantEntier FCFA';
  }

  int get _dureeNuits {
    final dateDebut = DateTime(plage.debut.year, plage.debut.month, plage.debut.day);
    final dateFin = DateTime(plage.fin.year, plage.fin.month, plage.fin.day);
    return dateFin.difference(dateDebut).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Avatar(initial: _initial),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSeed(
                  _nom,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                if (_telephone.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  TextSeed(
                    _telephone,
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextSeed(
                _montant,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
              const SizedBox(height: 3),
              TextSeed(
                '$_dureeNuits nuit${_dureeNuits > 1 ? 's' : ''}',
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initial;

  const _Avatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha:0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: TextSeed(
          initial,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.textOnAccent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Créer ma réservation',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
