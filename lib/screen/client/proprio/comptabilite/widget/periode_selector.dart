import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

class PeriodeSelector extends StatelessWidget {
  final DateTime dateDebut;
  final DateTime dateFin;
  final Function(DateTime debut, DateTime fin) onPeriodeChanged;

  const PeriodeSelector({
    super.key,
    required this.dateDebut,
    required this.dateFin,
    required this.onPeriodeChanged,
  });

  static const List<String> _mois = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isMoisCourant = dateDebut.month == now.month && dateDebut.year == now.year;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Bouton précédent
          IconButton(
            onPressed: () => _moisPrecedent(),
            icon: const Icon(Icons.chevron_left),
            color: AppColors.accent,
            iconSize: 28,
          ),

          // Affichage du mois
          Expanded(
            child: GestureDetector(
              onTap: () => _showMonthPicker(context),
              child: Column(
                children: [
                  TextSeed(
                    _mois[dateDebut.month - 1],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  TextSeed(
                    dateDebut.year.toString(),
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),

          // Bouton suivant (désactivé si mois courant)
          IconButton(
            onPressed: isMoisCourant ? null : () => _moisSuivant(),
            icon: const Icon(Icons.chevron_right),
            color: isMoisCourant ? AppColors.textMuted : AppColors.accent,
            iconSize: 28,
          ),
        ],
      ),
    );
  }

  void _moisPrecedent() {
    final newDebut = DateTime(dateDebut.year, dateDebut.month - 1, 1);
    final newFin = DateTime(newDebut.year, newDebut.month + 1, 0);
    onPeriodeChanged(newDebut, newFin);
  }

  void _moisSuivant() {
    final now = DateTime.now();
    final newDebut = DateTime(dateDebut.year, dateDebut.month + 1, 1);

    // Ne pas dépasser le mois courant
    if (newDebut.isAfter(DateTime(now.year, now.month, 1))) {
      return;
    }

    final newFin = DateTime(newDebut.year, newDebut.month + 1, 0);
    onPeriodeChanged(newDebut, newFin);
  }

  void _showMonthPicker(BuildContext context) {
    final now = DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextSeed(
                "Sélectionner une période",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 20),

              // Raccourcis rapides
              Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PeriodeChip(
                  label: "Ce mois",
                  isSelected: dateDebut.month == now.month && dateDebut.year == now.year,
                  onTap: () {
                    Navigator.pop(ctx);
                    final debut = DateTime(now.year, now.month, 1);
                    final fin = DateTime(now.year, now.month + 1, 0);
                    onPeriodeChanged(debut, fin);
                  },
                ),
                _PeriodeChip(
                  label: "Mois dernier",
                  isSelected: dateDebut.month == now.month - 1 ||
                      (now.month == 1 && dateDebut.month == 12 && dateDebut.year == now.year - 1),
                  onTap: () {
                    Navigator.pop(ctx);
                    final debut = DateTime(now.year, now.month - 1, 1);
                    final fin = DateTime(debut.year, debut.month + 1, 0);
                    onPeriodeChanged(debut, fin);
                  },
                ),
                _PeriodeChip(
                  label: "Trimestre",
                  isSelected: false,
                  onTap: () {
                    Navigator.pop(ctx);
                    final trimestre = ((now.month - 1) ~/ 3) * 3 + 1;
                    final debut = DateTime(now.year, trimestre, 1);
                    final fin = DateTime(now.year, trimestre + 3, 0);
                    onPeriodeChanged(debut, fin);
                  },
                ),
                _PeriodeChip(
                  label: "Cette année",
                  isSelected: false,
                  onTap: () {
                    Navigator.pop(ctx);
                    final debut = DateTime(now.year, 1, 1);
                    final fin = DateTime(now.year, 12, 31);
                    onPeriodeChanged(debut, fin);
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Liste des 12 derniers mois
            TextSeed(
              "Ou choisissez un mois",
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final moisDate = DateTime(now.year, now.month - index, 1);
                  final isSelected = moisDate.month == dateDebut.month &&
                      moisDate.year == dateDebut.year;

                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      final debut = DateTime(moisDate.year, moisDate.month, 1);
                      final fin = DateTime(moisDate.year, moisDate.month + 1, 0);
                      onPeriodeChanged(debut, fin);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextSeed(
                        "${_mois[moisDate.month - 1].substring(0, 3)} ${moisDate.year.toString().substring(2)}",
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _PeriodeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
        child: TextSeed(
          label,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
