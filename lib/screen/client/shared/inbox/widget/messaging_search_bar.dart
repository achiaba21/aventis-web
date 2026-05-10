import 'package:flutter/material.dart';
import 'package:asfar/widget/input/input_field.dart';

/// Barre de recherche du `MessagingListScreen` — `InputField` V1 avec icon
/// search et hintText « Rechercher ».
///
/// Reproduit le visuel proto `extras.jsx::MessagingList` (lignes 104-107)
/// mais avec un vrai `TextField` fonctionnel (le proto montre un span statique
/// non-fonctionnel — décision BA = filtre local case-insensitive).
class MessagingSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const MessagingSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: InputField(
        hintText: 'Rechercher',
        leadingIcon: Icons.search,
        onChanged: onChanged,
      ),
    );
  }
}
