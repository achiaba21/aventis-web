import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_demarcheur.dart';
import 'package:asfar/util/calc/reservation_actions_resolver.dart';

/// Cible de contact pour le bouton "Contacter" de la page détail.
///
/// Construite par `ReservationContactResolver.targetFor(role, reservation)`
/// selon la matrice :
/// - Locataire → propriétaire
/// - Proprio (résa plateforme/démarcheur) → locataire
/// - Proprio (résa manuelle) → client externe
/// - Démarcheur → propriétaire
class ContactTarget {
  /// Libellé du rôle de la cible (ex. "Propriétaire", "Client", "Démarcheur").
  final String roleLabel;

  /// Nom affichable de la cible.
  final String displayName;

  /// Téléphone (pour `tel:`), null si non disponible.
  final String? telephone;

  /// Identifiant user (pour ouvrir un chat in-app), null si non chattable
  /// (ex. client externe d'une résa manuelle).
  final int? userId;

  const ContactTarget({
    required this.roleLabel,
    required this.displayName,
    this.telephone,
    this.userId,
  });

  bool get hasPhone => (telephone ?? '').trim().isNotEmpty;
  bool get canChat => userId != null;
}

/// Résout qui contacter selon le rôle du viewer et le type de réservation.
class ReservationContactResolver {
  ReservationContactResolver._();

  static ContactTarget? targetFor(
    ReservationViewerRole role,
    Reservation r,
  ) {
    switch (role) {
      case ReservationViewerRole.locataire:
        final p = r.proprio;
        if (p == null) return null;
        return ContactTarget(
          roleLabel: 'Propriétaire',
          displayName: _fullName(p.prenom, p.nom),
          telephone: p.telephone,
          userId: p.id,
        );

      case ReservationViewerRole.proprietaire:
        if (r.isManuelle) {
          final name = r.clientExterneNom?.trim();
          if (name == null || name.isEmpty) return null;
          return ContactTarget(
            roleLabel: 'Client',
            displayName: name,
            telephone: r.clientExterneTelephone,
            userId: null,
          );
        }
        final l = r.locataire;
        if (l == null) return null;
        return ContactTarget(
          roleLabel: 'Locataire',
          displayName: _fullName(l.prenom, l.nom),
          telephone: l.telephone,
          userId: l.id,
        );

      case ReservationViewerRole.demarcheur:
        final p = r.proprio;
        if (p == null) return null;
        return ContactTarget(
          roleLabel: 'Propriétaire',
          displayName: _fullName(p.prenom, p.nom),
          telephone: p.telephone,
          userId: p.id,
        );
    }
  }

  /// Cible démarcheur pour la card dédiée côté proprio (résa démarcheur).
  static ContactTarget? demarcheurTargetFor(Reservation r) {
    if (r is! ReservationDemarcheur) return null;
    final d = r.demarcheur;
    if (d == null) return null;
    return ContactTarget(
      roleLabel: 'Démarcheur source',
      displayName: _fullName(d.prenom, d.nom),
      telephone: d.telephone,
      userId: d.id,
    );
  }

  static String _fullName(String? prenom, String? nom) {
    final full = '${prenom ?? ''} ${nom ?? ''}'.trim();
    return full.isEmpty ? '—' : full;
  }
}
