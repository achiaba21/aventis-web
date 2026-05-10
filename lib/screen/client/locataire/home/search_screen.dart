import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/screen/client/locataire/home/widget/search_date_input.dart';
import 'package:asfar/screen/client/locataire/home/widget/search_display_input.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/badge/asfar_chip.dart';
import 'package:asfar/widget/bottom_nav/bottom_bar.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/input/budget_slider.dart';

/// Écran de filtres de recherche du Locataire.
///
/// Reproduit `LocataireSearch` du proto : destination, dates,
/// budget/nuit (slider gold), chambres (chips), équipements (grid 2 cols),
/// CTA bottom "Voir N logements".
class LocataireSearchScreen extends StatefulWidget {
  const LocataireSearchScreen({super.key});

  @override
  State<LocataireSearchScreen> createState() => _LocataireSearchScreenState();
}

class _LocataireSearchScreenState extends State<LocataireSearchScreen> {
  static const _bedrooms = ['Studio', '1', '2', '3', '4+'];
  static const _amenities = [
    _AmenityFilter(icon: Icons.wifi, label: 'WiFi'),
    _AmenityFilter(icon: Icons.local_parking, label: 'Parking'),
    _AmenityFilter(icon: Icons.shield_outlined, label: 'Sécurité'),
    _AmenityFilter(icon: Icons.kitchen_outlined, label: 'Cuisine'),
  ];

  double _price = 60000;
  int _selectedBedrooms = 1;
  final Set<String> _activeAmenities = {'WiFi', 'Parking'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Filtres',
        leading: IconBoutton(
          icon: Icons.close,
          onPressed: () => back(context),
        ),
        trailing: TextButton(
          onPressed: () {
            setState(() {
              _price = 60000;
              _selectedBedrooms = 1;
              _activeAmenities.clear();
            });
          },
          child: const Text(
            'Effacer',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BlocBuilder<AppartementBloc, AppartementState>(
        builder: (context, state) {
          final count = state.appartements.length;
          final label = count > 0
              ? 'Voir $count logement${count > 1 ? 's' : ''}'
              : 'Aucun logement';
          return BottomBar(
            child: CustomButton(
              text: label,
              onPressed: count > 0 ? () => back(context) : null,
              size: ButtonSize.lg,
              block: true,
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Destination', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            const SearchDisplayInput(
              value: 'Abidjan, Côte d\'Ivoire',
              icon: Icons.search,
            ),
            const SizedBox(height: 24),
            const Text('Dates', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: SearchDateInput(eyebrow: 'ARRIVÉE', value: '12 nov.'),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SearchDateInput(eyebrow: 'DÉPART', value: '15 nov.'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Budget par nuit', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(
              "jusqu'à ${FcfaFormatter.compact(_price)}",
              style: AppTextStyles.mono(const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              )),
            ),
            const SizedBox(height: 4),
            BudgetSlider(
              value: _price,
              min: 10000,
              max: 150000,
              step: 5000,
              onChanged: (v) => setState(() => _price = v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('10k',
                    style: AppTextStyles.small.copyWith(fontSize: 11)),
                Text('150k',
                    style: AppTextStyles.small.copyWith(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Chambres', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Row(
              children: [
                for (var i = 0; i < _bedrooms.length; i++) ...[
                  Expanded(
                    child: AsfarChip(
                      label: _bedrooms[i],
                      active: _selectedBedrooms == i,
                      onTap: () => setState(() => _selectedBedrooms = i),
                    ),
                  ),
                  if (i < _bedrooms.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 24),
            const Text('Équipements indispensables',
                style: AppTextStyles.h3),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3.4,
              ),
              itemCount: _amenities.length,
              itemBuilder: (_, i) {
                final a = _amenities[i];
                final active = _activeAmenities.contains(a.label);
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() {
                      if (active) {
                        _activeAmenities.remove(a.label);
                      } else {
                        _activeAmenities.add(a.label);
                      }
                    }),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.accentSoft
                            : AppColors.bgElev2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: active
                              ? const Color(0x4DE8B86B)
                              : AppColors.line,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(a.icon,
                              size: 18,
                              color: active
                                  ? AppColors.accent
                                  : AppColors.text),
                          const SizedBox(width: 10),
                          Text(
                            a.label,
                            style: TextStyle(
                              fontSize: 14,
                              color: active
                                  ? AppColors.accent
                                  : AppColors.text,
                              fontWeight: active
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AmenityFilter {
  final IconData icon;
  final String label;
  const _AmenityFilter({required this.icon, required this.label});
}
