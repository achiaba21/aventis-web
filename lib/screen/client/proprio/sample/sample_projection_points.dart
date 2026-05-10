import 'package:asfar/model/ui_only/projection_point.dart';

/// Données mock du line chart « Projection 3 mois » du
/// `ProprioFinancesScreen` — 7 mois Sept → Mars.
///
/// Source : proto `proprietaire.jsx::ProprietaireFinances` (lignes 317-345).
/// Sept-Nov = passé (trait solid), Nov = mois courant (marker accent + ligne
/// verticale séparateur), Déc-Mars = futur (trait dashed).
class SampleProjectionPoints {
  SampleProjectionPoints._();

  static const List<ProjectionPoint> all = [
    ProjectionPoint(
        monthShort: 'Sept', amount: 1340000, isProjection: false),
    ProjectionPoint(monthShort: 'Oct', amount: 1580000, isProjection: false),
    ProjectionPoint(
        monthShort: 'Nov',
        amount: 1900000,
        isProjection: false,
        isCurrent: true),
    ProjectionPoint(monthShort: 'Déc', amount: 2100000, isProjection: true),
    ProjectionPoint(monthShort: 'Jan', amount: 2350000, isProjection: true),
    ProjectionPoint(monthShort: 'Fév', amount: 2500000, isProjection: true),
    ProjectionPoint(monthShort: 'Mars', amount: 2700000, isProjection: true),
  ];

  /// Estimation totale Q1 2026 (Déc + Jan + Fév + Mars du futur).
  static int get q1Estimation => all
      .where((p) => p.isProjection)
      .fold(0, (sum, p) => sum + p.amount);
}
