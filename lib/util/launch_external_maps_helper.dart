import 'dart:io';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper d'ouverture d'une application carte externe pour un itinéraire.
///
/// Sélectionne automatiquement la plateforme :
/// - **iOS / macOS** → Apple Maps (`https://maps.apple.com/?daddr=...&dirflg=d`)
/// - **Autres**     → Google Maps (`https://www.google.com/maps/dir/?api=1&destination=...`)
///
/// L'appel utilise `LaunchMode.externalApplication` pour basculer
/// directement dans l'app native plutôt qu'un onglet navigateur. Si aucune
/// app maps n'est installée (cas extrême), retourne `false` — l'appelant
/// affiche alors un SnackBar discret au lieu de planter.
class LaunchExternalMapsHelper {
  LaunchExternalMapsHelper._();

  /// Ouvre l'app maps avec un itinéraire vers [coords].
  /// Retourne `true` si le launch a réussi, `false` sinon.
  static Future<bool> launchDirections(LatLng coords) async {
    final Uri uri = _buildDirectionsUri(coords);
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Uri _buildDirectionsUri(LatLng coords) {
    final lat = coords.latitude;
    final lng = coords.longitude;
    if (Platform.isIOS || Platform.isMacOS) {
      return Uri.parse(
        'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d',
      );
    }
    return Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
  }
}
