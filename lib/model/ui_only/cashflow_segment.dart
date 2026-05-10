import 'package:flutter/material.dart';

/// Un segment du `CashflowSplitCard` — barre stack horizontale du Dashboard.
///
/// Reproduit le mock du proto `proprietaire.jsx::ProprietaireDashboard`
/// (lignes 99-117) : 4 segments (Locations / Charges / Commissions / Frais)
/// avec ratio implicite (somme des `amount` détermine la largeur de chaque
/// segment dans la barre stack).
class CashflowSegment {
  final String label;
  final int amount;
  final Color color;

  const CashflowSegment({
    required this.label,
    required this.amount,
    required this.color,
  });
}
