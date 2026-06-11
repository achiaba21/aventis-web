import 'package:flutter/material.dart';
import 'package:asfar/screen/signup/widget/pin_keypad_key.dart';

/// Clavier numérique dédié à la saisie de code PIN.
///
/// Grille 3×4 : chiffres 1-9, 0 et effacement. Remplace le clavier système
/// sur les écrans de création/confirmation du code secret (une page = un
/// seul clavier). Réutilisable pour toute saisie numérique courte.
class PinKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                for (final digit in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: PinKeypadKey(
                        label: digit,
                        onTap: () => onDigit(digit),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Row(
          children: [
            const Expanded(child: SizedBox()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: PinKeypadKey(label: '0', onTap: () => onDigit('0')),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: PinKeypadKey(
                  icon: Icons.backspace_outlined,
                  onTap: onBackspace,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
