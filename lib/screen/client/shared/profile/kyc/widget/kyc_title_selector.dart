import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/input/input_field.dart';

/// Sélecteur du titre d'une pièce KYC : liste prédéfinie sous forme de chips +
/// option « Autre » qui révèle un champ libre. Expose la valeur via [onChanged].
class KycTitleSelector extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const KycTitleSelector({super.key, required this.onChanged});

  @override
  State<KycTitleSelector> createState() => _KycTitleSelectorState();
}

class _KycTitleSelectorState extends State<KycTitleSelector> {
  static const _predefined = [
    'CNI',
    'Passeport',
    'Permis de conduire',
    'Carte consulaire',
  ];
  static const _autreLabel = 'Autre';

  String? _selected;
  final TextEditingController _customCtrl = TextEditingController();

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _onSelect(String value) {
    setState(() => _selected = value);
    if (value == _autreLabel) {
      widget.onChanged(_customCtrl.text.trim());
    } else {
      widget.onChanged(value);
    }
  }

  void _onCustomChanged(String value) {
    widget.onChanged(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final options = [..._predefined, _autreLabel];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map((o) => _TitleChip(
                    label: o,
                    selected: _selected == o,
                    onTap: () => _onSelect(o),
                  ))
              .toList(),
        ),
        if (_selected == _autreLabel) ...[
          const SizedBox(height: 12),
          InputField(
            controller: _customCtrl,
            hintText: 'Précisez le type de pièce',
            onChanged: _onCustomChanged,
          ),
        ],
      ],
    );
  }
}

/// Chip de sélection d'un titre. Privée au sélecteur.
class _TitleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TitleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : AppColors.bgElev2,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.line,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.accent : AppColors.text2,
          ),
        ),
      ),
    );
  }
}
