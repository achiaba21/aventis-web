import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';

/// Classe utilitaire pour tous les calculs comptables
///
/// Toutes les méthodes sont statiques et pures (pas d'effets de bord).
/// Les calculs sont effectués dynamiquement à partir des données brutes.
class ComptabiliteCalculator {
  ComptabiliteCalculator._(); // Empêche l'instanciation

  // ==================== FILTRAGE ====================

  /// Filtre les réservations par période et optionnellement par résidence
  ///
  /// Note: On passe la liste des appartements pour résoudre le residenceId
  /// car r.appart?.residenceId peut être null dans les données du serveur.
  static List<Reservation> filtrerReservations({
    required List<Reservation> reservations,
    required DateTime dateDebut,
    required DateTime dateFin,
    int? residenceId,
    int? appartementId,
    List<Appartement>? appartements,
  }) {
    // Note : depuis BACKEND-FLAT-APPART, le filtre `residenceId` n'a plus
    // d'effet côté client (le modèle plat ne porte plus de residenceId).
    // Le paramètre est conservé pour compatibilité (il sera transmis aux
    // appels API qui peuvent encore l'utiliser).
    // ignore: avoid_unnecessary_containers
    final _ = (residenceId, appartements); // suppress unused param warnings

    return reservations.where((r) {
      if (r.debut == null) return false;

      final finReservation = r.fin ?? r.debut!;

      // Vérifier le chevauchement de période
      final chevauche =
          !finReservation.isBefore(dateDebut) && !r.debut!.isAfter(dateFin);
      if (!chevauche) return false;

      // Filtrer par appartement si spécifié
      if (appartementId != null && r.appart?.id != appartementId) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Filtre les charges par période et optionnellement par résidence/appartement
  static List<Charge> filtrerCharges({
    required List<Charge> charges,
    required DateTime dateDebut,
    required DateTime dateFin,
    int? residenceId,
    int? appartementId,
  }) {
    return charges.where((c) {
      // Filtrer par appartement si spécifié
      if (appartementId != null && c.appartementId != appartementId) {
        return false;
      }

      // Note 2026-05-13 : `residenceId` n'a plus aucune valeur sémantique
      // (champ retiré du modèle Charge). Le paramètre est conservé pour
      // rétro-compat des callers mais ne filtre plus rien.
      final _ = residenceId;

      // Filtrer par période (basé sur dateEcheance ou createdAt)
      final dateRef = c.dateEcheance ?? c.createdAt;
      if (dateRef != null) {
        final dansLaPeriode =
            !dateRef.isBefore(dateDebut) && !dateRef.isAfter(dateFin);
        if (!dansLaPeriode) return false;
      }

      return true;
    }).toList();
  }

  // ==================== CALCULS REVENUS ====================

  /// Statuts de réservation considérés comme générant du revenu
  static const _statutsRevenus = [
    ReservationStatus.payee,
    ReservationStatus.terminee,
    ReservationStatus.finalisee,
  ];

  /// Calcule le chiffre d'affaires (somme des réservations confirmées/payées/terminées)
  static double chiffreAffaires({
    required List<Reservation> reservations,
    required DateTime dateDebut,
    required DateTime dateFin,
    int? residenceId,
    int? appartementId,
    List<Appartement>? appartements,
  }) {
    final reservationsFiltrees = filtrerReservations(
      reservations: reservations,
      dateDebut: dateDebut,
      dateFin: dateFin,
      residenceId: residenceId,
      appartementId: appartementId,
      appartements: appartements,
    );

    return reservationsFiltrees
        .where((r) => _statutsRevenus.contains(r.statut))
        .fold(0.0, (sum, r) => sum + (r.prix ?? 0));
  }

  /// Compte le nombre de réservations sur la période
  static int nombreReservations({
    required List<Reservation> reservations,
    required DateTime dateDebut,
    required DateTime dateFin,
    int? residenceId,
    int? appartementId,
    List<Appartement>? appartements,
    bool seulementRevenus = true,
  }) {
    final reservationsFiltrees = filtrerReservations(
      reservations: reservations,
      dateDebut: dateDebut,
      dateFin: dateFin,
      residenceId: residenceId,
      appartementId: appartementId,
      appartements: appartements,
    );

    if (seulementRevenus) {
      return reservationsFiltrees
          .where((r) => _statutsRevenus.contains(r.statut))
          .length;
    }
    return reservationsFiltrees.length;
  }

  // ==================== CALCULS CHARGES ====================

  /// Calcule le total des charges sur la période
  static double totalCharges({
    required List<Charge> charges,
    required DateTime dateDebut,
    required DateTime dateFin,
    int? residenceId,
    int? appartementId,
  }) {
    final chargesFiltrees = filtrerCharges(
      charges: charges,
      dateDebut: dateDebut,
      dateFin: dateFin,
      residenceId: residenceId,
      appartementId: appartementId,
    );

    return chargesFiltrees.fold(0.0, (sum, c) => sum + (c.montant ?? 0));
  }

  /// Calcule le total des charges payées
  static double chargesPayees({
    required List<Charge> charges,
    required DateTime dateDebut,
    required DateTime dateFin,
    int? residenceId,
    int? appartementId,
  }) {
    final chargesFiltrees = filtrerCharges(
      charges: charges,
      dateDebut: dateDebut,
      dateFin: dateFin,
      residenceId: residenceId,
      appartementId: appartementId,
    );

    return chargesFiltrees
        .fold(0.0, (sum, c) => sum + (c.montant ?? 0));
  }

  /// Compte le nombre de charges sur la période
  static int nombreCharges({
    required List<Charge> charges,
    required DateTime dateDebut,
    required DateTime dateFin,
    int? residenceId,
    int? appartementId,
  }) {
    return filtrerCharges(
      charges: charges,
      dateDebut: dateDebut,
      dateFin: dateFin,
      residenceId: residenceId,
      appartementId: appartementId,
    ).length;
  }

  // ==================== CALCULS BENEFICE ====================

  /// Calcule le bénéfice net (CA - charges)
  static double beneficeNet({
    required double chiffreAffaires,
    required double totalCharges,
  }) {
    return chiffreAffaires - totalCharges;
  }

  /// Calcule la marge en pourcentage
  static double margePourcent({
    required double chiffreAffaires,
    required double beneficeNet,
  }) {
    if (chiffreAffaires == 0) return 0;
    return (beneficeNet / chiffreAffaires) * 100;
  }

  /// Indique si le résultat est bénéficiaire
  static bool estBeneficiaire(double beneficeNet) => beneficeNet > 0;

  /// Indique si le résultat est déficitaire
  static bool estDeficitaire(double beneficeNet) => beneficeNet < 0;

  // ==================== CALCULS OCCUPATION ====================

  /// Calcule le nombre de jours réservés sur la période
  ///
  /// Pour un calcul précis par appartement, on compte les jours uniques
  /// pour éviter les doubles comptages si un appartement a plusieurs réservations.
  static int joursReserves({
    required List<Reservation> reservations,
    required DateTime dateDebut,
    required DateTime dateFin,
    int? residenceId,
    int? appartementId,
    List<Appartement>? appartements,
  }) {
    final reservationsFiltrees = filtrerReservations(
      reservations: reservations,
      dateDebut: dateDebut,
      dateFin: dateFin,
      residenceId: residenceId,
      appartementId: appartementId,
      appartements: appartements,
    ).where((r) => _statutsRevenus.contains(r.statut));

    int total = 0;
    for (final r in reservationsFiltrees) {
      if (r.debut != null && r.fin != null) {
        // Calculer l'intersection avec la période demandée
        final debutEffectif =
            r.debut!.isBefore(dateDebut) ? dateDebut : r.debut!;
        final finEffective = r.fin!.isAfter(dateFin) ? dateFin : r.fin!;

        if (!finEffective.isBefore(debutEffectif)) {
          total += finEffective.difference(debutEffectif).inDays + 1;
        }
      }
    }
    return total;
  }

  /// Calcule le nombre de jours dans la période
  static int joursPeriode(DateTime dateDebut, DateTime dateFin) {
    return dateFin.difference(dateDebut).inDays + 1;
  }

  /// Calcule le taux d'occupation en pourcentage
  ///
  /// Formule: (jours réservés / capacité) × 100
  ///
  /// La capacité dépend du niveau de sélection:
  /// - Global: jours_période × tous_appartements
  /// - Résidence: jours_période × appartements_résidence
  /// - Appartement: jours_période × 1
  ///
  /// Cette méthode gère automatiquement les 3 cas.
  static double tauxOccupation({
    required List<Reservation> reservations,
    required List<Appartement> appartements,
    required DateTime dateDebut,
    required DateTime dateFin,
    int? residenceId,
    int? appartementId,
  }) {
    final int nombreAppartements;

    if (appartementId != null) {
      // Cas 3: Un appartement spécifique sélectionné
      // Vérifier que l'appartement existe
      final exists = appartements.any((a) => a.id == appartementId);
      if (!exists) return 0;
      nombreAppartements = 1;
    } else if (residenceId != null) {
      // Cas 2 — déprécié post BACKEND-FLAT-APPART : on tombe sur le total
      // global (residenceId n'existe plus côté client).
      nombreAppartements = appartements.length;
    } else {
      // Cas 1: Toutes les résidences (global)
      nombreAppartements = appartements.length;
    }

    if (nombreAppartements == 0) return 0;

    // Calculer les jours réservés avec les mêmes filtres
    final jours = joursReserves(
      reservations: reservations,
      dateDebut: dateDebut,
      dateFin: dateFin,
      residenceId: residenceId,
      appartementId: appartementId,
      appartements: appartements,
    );

    // Capacité = jours dans la période × nombre d'appartements
    final capaciteTotale =
        joursPeriode(dateDebut, dateFin) * nombreAppartements;
    if (capaciteTotale == 0) return 0;

    // Limiter à 100% max (au cas où il y aurait des chevauchements)
    final taux = (jours / capaciteTotale) * 100;
    return taux > 100 ? 100 : taux;
  }

  // ==================== CALCULS PRIX ====================

  /// Calcule le prix moyen par nuit
  static double prixMoyenParNuit({
    required double chiffreAffaires,
    required int joursReserves,
  }) {
    if (joursReserves == 0) return 0;
    return chiffreAffaires / joursReserves;
  }

  /// Calcule le revenu moyen par réservation
  static double revenuMoyenParReservation({
    required double chiffreAffaires,
    required int nombreReservations,
  }) {
    if (nombreReservations == 0) return 0;
    return chiffreAffaires / nombreReservations;
  }

  /// Calcule le prix moyen des appartements
  static double prixMoyenAppartements(List<Appartement> appartements) {
    final prixList =
        appartements
            .where((a) => a.prix != null && a.prix! > 0)
            .map((a) => a.prix!)
            .toList();

    if (prixList.isEmpty) return 0;
    return prixList.reduce((a, b) => a + b) / prixList.length;
  }

  // ==================== REPARTITION ====================

  /// Calcule la répartition des charges par type
  static Map<TypeCharge, double> repartitionParType(List<Charge> charges) {
    final Map<TypeCharge, double> repartition = {};
    for (final charge in charges) {
      final type = charge.typeCharge;
      repartition[type] = (repartition[type] ?? 0) + (charge.montant ?? 0);
    }
    return repartition;
  }

  /// Retourne le top N des charges par type
  static List<MapEntry<TypeCharge, double>> topChargesParType(
    List<Charge> charges, {
    int limit = 3,
  }) {
    final repartition = repartitionParType(charges);
    final sorted =
        repartition.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  // ==================== REPARTITION CA ====================

  /// Répartition du CA par appartement.
  ///
  /// Note : depuis BACKEND-FLAT-APPART, la répartition par "résidence"
  /// n'existe plus côté client. Pour grouper visuellement par adresse,
  /// utiliser le filtre `address_filter_selector` côté UI.
  static List<RepartitionCaItem> repartitionCaParAppartement({
    required List<Reservation> reservations,
    required List<Appartement> appartements,
    required DateTime dateDebut,
    required DateTime dateFin,
  }) {
    final result = <RepartitionCaItem>[];
    final appartementsFiltre = appartements;

    for (final appart in appartementsFiltre) {
      final ca = chiffreAffaires(
        reservations: reservations,
        dateDebut: dateDebut,
        dateFin: dateFin,
        appartementId: appart.id,
        appartements: appartements,
      );

      if (ca > 0) {
        result.add(
          RepartitionCaItem(
            id: appart.id ?? 0,
            nom: appart.titre ?? appart.numero ?? 'Appart ${appart.id}',
            montant: ca,
          ),
        );
      }
    }

    // Trier par montant décroissant
    result.sort((a, b) => b.montant.compareTo(a.montant));
    return result;
  }

  // ==================== HISTORIQUE ====================

  /// Données pour un point sur le graphique d'évolution
  static List<PointEvolution> historiqueMensuel({
    required List<Reservation> reservations,
    required List<Charge> charges,
    required int nombreMois,
    int? residenceId,
    int? appartementId,
    List<Appartement>? appartements,
  }) {
    final historique = <PointEvolution>[];
    final now = DateTime.now();

    for (int i = nombreMois - 1; i >= 0; i--) {
      final mois = DateTime(now.year, now.month - i, 1);
      final finMois = DateTime(now.year, now.month - i + 1, 0);

      final ca = chiffreAffaires(
        reservations: reservations,
        dateDebut: mois,
        dateFin: finMois,
        residenceId: residenceId,
        appartementId: appartementId,
        appartements: appartements,
      );

      final chargesMois = totalCharges(
        charges: charges,
        dateDebut: mois,
        dateFin: finMois,
        residenceId: residenceId,
        appartementId: appartementId,
      );

      historique.add(
        PointEvolution(
          date: mois,
          chiffreAffaires: ca,
          charges: chargesMois,
          benefice: ca - chargesMois,
        ),
      );
    }

    return historique;
  }

  // ==================== FORMATAGE ====================

  /// Formate un montant en FCFA avec séparateurs
  static String formatMontant(double montant) {
    return montant
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  /// Génère un résumé textuel du bénéfice
  static String resumeBenefice(double beneficeNet, double margePourcent) {
    if (beneficeNet > 0) {
      return 'Bénéfice de ${formatMontant(beneficeNet)} FCFA (marge ${margePourcent.toStringAsFixed(1)}%)';
    } else if (beneficeNet < 0) {
      return 'Déficit de ${formatMontant(beneficeNet.abs())} FCFA';
    }
    return 'Équilibre (ni bénéfice ni perte)';
  }
}

/// Données pour un point sur le graphique d'évolution
class PointEvolution {
  final DateTime date;
  final double chiffreAffaires;
  final double charges;
  final double benefice;

  PointEvolution({
    required this.date,
    required this.chiffreAffaires,
    required this.charges,
    required this.benefice,
  });

  String get moisLabel {
    const mois = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return mois[date.month - 1];
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'chiffreAffaires': chiffreAffaires,
      'charges': charges,
      'benefice': benefice,
    };
  }
}

/// Données pour un segment de répartition du CA (résidence ou appartement)
class RepartitionCaItem {
  final int id;
  final String nom;
  final double montant;

  RepartitionCaItem({
    required this.id,
    required this.nom,
    required this.montant,
  });

  @override
  String toString() =>
      'RepartitionCaItem{id: $id, nom: $nom, montant: $montant}';
}
