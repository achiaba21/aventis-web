import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/util/url/share_url.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Bouton « Partager » d'un appartement : ouvre la feuille de partage native
/// du téléphone (WhatsApp, SMS, Copier…) avec le lien public des photos du
/// bien (`{domain}/share/{partageToken}`).
///
/// Aucune logique métier : le `partageToken` est déjà sur l'objet, on construit
/// l'URL et on délègue à `share_plus`.
///
/// Masqué (`SizedBox.shrink`) si l'appartement n'a pas de `partageToken` (très
/// vieux objets). [floating] : style flottant translucide pour superposition
/// sur le hero photo (détail locataire/démarcheur) ; sinon style plein (AppBar
/// de la fiche proprio).
class ShareAppartementButton extends StatelessWidget {
  final Appartement appartement;
  final bool floating;

  const ShareAppartementButton({
    super.key,
    required this.appartement,
    this.floating = false,
  });

  void _onShare() {
    final token = appartement.partageToken;
    if (token == null || token.isEmpty) return;
    final url = buildAppartementShareUrl(token);
    SharePlus.instance.share(ShareParams(uri: Uri.parse(url)));
  }

  @override
  Widget build(BuildContext context) {
    final token = appartement.partageToken;
    if (token == null || token.isEmpty) {
      return const SizedBox.shrink();
    }
    return IconBoutton(
      icon: Icons.ios_share,
      onPressed: _onShare,
      floating: floating,
      tooltip: 'Partager',
    );
  }
}
