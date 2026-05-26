import 'package:asfar/model/contact/contact.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_demarcheur.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/util/calc/reservation_actions_resolver.dart';

/// Résout un `Contact` à partir d'une source métier (réservation,
/// utilisateur, etc.) selon le rôle du viewer.
///
/// Remplace fonctionnellement `ReservationContactResolver` en produisant le
/// nouveau modèle [Contact] (plus générique que l'ancien `ContactTarget`).
class ContactTargetResolver {
  ContactTargetResolver._();

  /// Cible "principale" du bouton Contacter pour le viewer [role] sur
  /// la réservation [r].
  ///
  /// Matrice (cf. business-spec.md §3) :
  /// - Locataire → propriétaire
  /// - Propriétaire (résa plateforme/démarcheur) → locataire
  /// - Propriétaire (résa manuelle) → client externe (chat impossible)
  /// - Démarcheur → propriétaire
  static Contact? fromReservation(
    Reservation r,
    ReservationViewerRole role,
  ) {
    switch (role) {
      case ReservationViewerRole.locataire:
        return _fromProprio(r);
      case ReservationViewerRole.proprietaire:
        if (r.isManuelle) return _fromClientExterne(r);
        return _fromLocataire(r);
      case ReservationViewerRole.demarcheur:
        return _fromProprio(r);
    }
  }

  /// Cible "démarcheur source" pour la card dédiée côté proprio quand la
  /// résa provient d'un démarcheur.
  static Contact? fromReservationDemarcheur(Reservation r) {
    if (r is! ReservationDemarcheur) return null;
    final d = r.demarcheur;
    if (d == null) return null;
    return Contact(
      displayName: _fullName(d.prenom, d.nom),
      roleLabel: 'Démarcheur source',
      telephone: d.telephone,
      userId: d.id,
    );
  }

  /// Construit un [Contact] générique depuis un [User] (proprio, locataire,
  /// démarcheur…). Le [roleLabel] est calculé depuis `user.nature` si non
  /// fourni explicitement.
  static Contact fromUser(User u, {String? roleLabel}) {
    return Contact(
      displayName: _fullName(u.prenom, u.nom),
      roleLabel: roleLabel ?? u.nature,
      telephone: u.telephone,
      userId: u.id,
    );
  }

  static Contact? _fromProprio(Reservation r) {
    final p = r.proprio;
    if (p == null) return null;
    return Contact(
      displayName: _fullName(p.prenom, p.nom),
      roleLabel: 'Propriétaire',
      telephone: p.telephone,
      userId: p.id,
    );
  }

  static Contact? _fromLocataire(Reservation r) {
    final l = r.locataire;
    if (l == null) return null;
    return Contact(
      displayName: _fullName(l.prenom, l.nom),
      roleLabel: 'Locataire',
      telephone: l.telephone,
      userId: l.id,
    );
  }

  static Contact? _fromClientExterne(Reservation r) {
    final name = r.clientExterneNom?.trim();
    if (name == null || name.isEmpty) return null;
    return Contact(
      displayName: name,
      roleLabel: 'Client',
      telephone: r.clientExterneTelephone,
      userId: null, // chat impossible — client externe non rattaché à un user
    );
  }

  static String _fullName(String? prenom, String? nom) {
    final full = '${prenom ?? ''} ${nom ?? ''}'.trim();
    return full.isEmpty ? '—' : full;
  }
}
