/// Formatter de montants en franc CFA (FCFA) — devise officielle de la
/// Côte d'Ivoire et de la zone UEMOA.
///
/// Deux formats :
/// - [full] : "1 900 000 FCFA" (utiliser pour totaux, factures, P&L)
/// - [compact] : "1.9 M FCFA" / "45 k FCFA" (utiliser pour cards, listes,
///   tooltips, hero numbers où l'espace est limité)
///
/// Le séparateur de milliers est l'**espace insécable** (style français).
class FcfaFormatter {
  FcfaFormatter._();

  /// Formate un montant en format complet : "1 900 000 FCFA".
  ///
  /// - 0 → "0 FCFA"
  /// - négatifs → "-1 200 FCFA" (préfixe minus)
  /// - décimales arrondies à l'entier
  ///
  /// Ne préserve pas le signe pour les valeurs nulles.
  static String full(num amount) {
    final rounded = amount.round();
    if (rounded == 0) return '0 FCFA';
    final isNegative = rounded < 0;
    final absValue = rounded.abs();
    final grouped = _groupThousands(absValue);
    return '${isNegative ? '-' : ''}$grouped FCFA';
  }

  /// Formate un montant en format compact :
  /// - "1.9 M FCFA" pour les millions
  /// - "45 k FCFA" pour les milliers
  /// - "850 FCFA" sinon
  ///
  /// Affiche 0 ou 1 décimale selon que la valeur est ronde.
  static String compact(num amount) {
    final rounded = amount.round();
    if (rounded == 0) return '0 FCFA';
    final isNegative = rounded < 0;
    final absValue = rounded.abs();
    final prefix = isNegative ? '-' : '';

    if (absValue >= 1000000) {
      final millions = absValue / 1000000;
      final formatted = absValue % 1000000 == 0
          ? millions.toStringAsFixed(0)
          : millions.toStringAsFixed(1);
      return '$prefix$formatted M FCFA';
    }
    if (absValue >= 1000) {
      final thousands = (absValue / 1000).round();
      return '$prefix$thousands k FCFA';
    }
    return '$prefix$absValue FCFA';
  }

  /// Groupe les milliers avec un espace insécable (U+00A0).
  ///
  /// Ex. : 1900000 → "1 900 000".
  static String _groupThousands(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}
