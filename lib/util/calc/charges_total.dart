import 'package:asfar/model/comptabilite/charge.dart';

/// Total monétaire d'une liste de charges (helper pur).
class ChargesTotal {
  ChargesTotal._();

  /// Somme des montants (FCFA, arrondie) des charges fournies. Les montants
  /// nuls comptent pour 0.
  static int sum(Iterable<Charge> charges) {
    var total = 0.0;
    for (final c in charges) {
      total += c.montant ?? 0;
    }
    return total.round();
  }
}
