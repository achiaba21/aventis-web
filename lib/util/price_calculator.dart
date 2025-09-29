import 'package:web_flutter/model/remise/remise.dart';
import 'package:web_flutter/model/remise/condition.dart';

class PriceCalculator {
  /// Calcule le prix par nuit avec remise appliquée
  static double getDiscountedNightPrice(double basePrice, Remise? remise, int days) {
    if (remise == null || days <= 0) return basePrice;

    final condition = remise.matchCondition(days);
    return condition?.montant ?? basePrice;
  }

  /// Calcule le prix total d'un séjour avec remises
  static double calculateTotalPrice(double basePrice, Remise? remise, int days) {
    if (days <= 0) return 0.0;

    final discountedPrice = getDiscountedNightPrice(basePrice, remise, days);
    return discountedPrice * days;
  }

  /// Obtient la condition de remise applicable
  static Condition? getApplicableDiscount(Remise? remise, int days) {
    if (remise == null || days <= 0) return null;
    return remise.matchCondition(days);
  }

  /// Calcule le montant économisé
  static double calculateSavings(double basePrice, Remise? remise, int days) {
    if (remise == null || days <= 0) return 0.0;

    final originalTotal = basePrice * days;
    final discountedTotal = calculateTotalPrice(basePrice, remise, days);
    return originalTotal - discountedTotal;
  }

  /// Calcule le pourcentage de réduction
  static double calculateDiscountPercentage(double basePrice, Remise? remise, int days) {
    if (remise == null || days <= 0 || basePrice <= 0) return 0.0;

    final discountedPrice = getDiscountedNightPrice(basePrice, remise, days);
    return ((basePrice - discountedPrice) / basePrice) * 100;
  }

  /// Vérifie si une remise est applicable
  static bool hasDiscount(Remise? remise, int days) {
    return getApplicableDiscount(remise, days) != null;
  }

  /// Obtient toutes les conditions disponibles triées par jours
  static List<Condition> getAvailableDiscounts(Remise? remise) {
    if (remise?.conditions == null) return [];

    final conditions = List<Condition>.from(remise!.conditions!);
    conditions.sort((a, b) => (a.days ?? 0).compareTo(b.days ?? 0));
    return conditions;
  }
}

/// Classe helper pour retourner les détails de remise
class DiscountDetails {
  final Condition? condition;
  final double originalPrice;
  final double discountedPrice;
  final double savings;
  final double percentage;
  final bool hasDiscount;

  DiscountDetails({
    required this.condition,
    required this.originalPrice,
    required this.discountedPrice,
    required this.savings,
    required this.percentage,
    required this.hasDiscount,
  });

  factory DiscountDetails.calculate(double basePrice, Remise? remise, int days) {
    final condition = PriceCalculator.getApplicableDiscount(remise, days);
    final discountedPrice = PriceCalculator.getDiscountedNightPrice(basePrice, remise, days);
    final savings = basePrice - discountedPrice;
    final percentage = PriceCalculator.calculateDiscountPercentage(basePrice, remise, days);

    return DiscountDetails(
      condition: condition,
      originalPrice: basePrice,
      discountedPrice: discountedPrice,
      savings: savings,
      percentage: percentage,
      hasDiscount: condition != null,
    );
  }
}