import 'package:flutter/material.dart';

/// Source unique de toutes les couleurs de l'application.
///
/// Identité visuelle : **Asfar Dark Premium** (fond quasi-noir, accent or chaud,
/// hospitalité + luxe africain). Aucune couleur ne doit être définie hors de
/// ce fichier (et des palettes dédiées).
///
/// **Rétro-compatibilité :** les noms publics existants (`background`, `accent`,
/// `textPrimary`, etc.) sont conservés et leurs valeurs swappées vers la
/// palette dark. Les 1 600+ callsites du projet basculent automatiquement.
class AppColors {
  AppColors._();

  // ============ FONDS ============
  /// Canvas principal de l'app (Scaffold, écrans).
  static const Color background = Color(0xFF0A0A0B);

  /// Surface neutre (= background, pas d'élévation).
  static const Color surface = Color(0xFF0A0A0B);

  /// Surface élévation 2 — chips, inputs, badges.
  static const Color surfaceVariant = Color(0xFF1C1C20);

  /// Surface élévation 1 — cards, panels.
  static const Color surfaceElevated = Color(0xFF131316);

  /// Élévation 1 (alias sémantique de `surfaceElevated`, utilisable en nouveau code).
  static const Color bgElev1 = Color(0xFF131316);

  /// Élévation 2 (alias sémantique de `surfaceVariant`).
  static const Color bgElev2 = Color(0xFF1C1C20);

  /// Élévation 3 — pour skeleton, séparateurs forts, états désactivés.
  static const Color bgElev3 = Color(0xFF25252B);

  // ============ TEXTES ============
  /// Texte principal (blanc cassé Apple).
  static const Color textPrimary = Color(0xFFF5F5F7);

  /// Texte secondaire — sous-titres, descriptions.
  static const Color textSecondary = Color(0xFFB8B8BE);

  /// Texte muted — eyebrows, métadonnées discrètes.
  static const Color textMuted = Color(0xFF76767E);

  /// Texte désactivé / placeholder.
  static const Color textDisabled = Color(0xFF4A4A52);

  /// Texte sur fond accent (or) — sombre pour contraster avec l'or.
  static const Color textOnAccent = Color(0xFF1A1206);

  // Aliases sémantiques (préférer pour nouveau code) :
  /// Niveau 1 (= textPrimary).
  static const Color text = Color(0xFFF5F5F7);

  /// Niveau 2 (= textSecondary).
  static const Color text2 = Color(0xFFB8B8BE);

  /// Niveau 3 (= textMuted).
  static const Color text3 = Color(0xFF76767E);

  /// Niveau dim (= textDisabled).
  static const Color textDim = Color(0xFF4A4A52);

  /// Texte sur accent (= textOnAccent).
  static const Color onAccent = Color(0xFF1A1206);

  // ============ ACCENT (OR CHAUD — IDENTITÉ ASFAR) ============
  /// Accent principal — or chaud, signature de l'identité.
  static const Color accent = Color(0xFFE8B86B);

  /// Accent foncé — hover, états pressés.
  static const Color accentDark = Color(0xFFC99650);

  /// Accent 2 (alias sémantique de `accentDark`).
  static const Color accent2 = Color(0xFFC99650);

  /// Accent translucide (or à 14% — pour fonds de chip-active, banners, etc.).
  static const Color accentLight = Color(0x24E8B86B);

  /// Accent soft (alias sémantique de `accentLight`).
  static const Color accentSoft = Color(0x24E8B86B);

  // ============ SÉMANTIQUE ============
  static const Color success = Color(0xFF4ADE80);
  static const Color successLight = Color(0x244ADE80);
  static const Color warning = Color(0xFFF4B740);
  static const Color warningLight = Color(0x24F4B740);
  static const Color error = Color(0xFFF87171);
  static const Color errorLight = Color(0x24F87171);
  static const Color info = Color(0xFF60A5FA);
  static const Color infoLight = Color(0x2460A5FA);

  // Aliases sémantiques courts (préférer pour nouveau code) :
  static const Color warn = Color(0xFFF4B740);
  static const Color danger = Color(0xFFF87171);

  // ============ BORDURES & SÉPARATEURS ============
  /// Bordure standard — blanc translucide à 8%.
  static const Color border = Color(0x14FFFFFF);

  /// Séparateur de listes (= border).
  static const Color divider = Color(0x14FFFFFF);

  /// Ligne (alias sémantique).
  static const Color line = Color(0x14FFFFFF);

  /// Ligne forte — bordures actives, focus.
  static const Color lineStrong = Color(0x24FFFFFF);

  // ============ ÉTATS ============
  static const Color inactive = Color(0xFF4A4A52);
  static const Color disabled = Color(0xFF25252B);

  // ============ OMBRES & OVERLAYS ============
  /// Ombre standard (sur fond dark, plus subtile que sur fond clair).
  static final Color shadow = const Color(0xFF000000).withValues(alpha: 0.4);
  static final Color shadowStrong =
      const Color(0xFF000000).withValues(alpha: 0.6);
  static final Color overlay = const Color(0xFF000000).withValues(alpha: 0.7);
  static final Color overlayLight =
      const Color(0xFF000000).withValues(alpha: 0.4);

  // ============ CALENDRIER ============
  /// Cellule bloquée — bgElev3 dark.
  static const Color calendarBlocked = Color(0xFF25252B);
  static const Color calendarReserved = accent;
  static const Color calendarAvailable = success;

  // ============ MOBILE MONEY (CÔTE D'IVOIRE) ============
  /// Couleur signature Orange Money.
  static const Color orangeMoney = Color(0xFFFF6B00);

  /// Couleur signature Wave.
  static const Color wave = Color(0xFF1DC4D5);

  /// Couleur signature MTN MoMo.
  static const Color mtnMomo = Color(0xFFFFCC00);

  /// Couleur générique pour cartes bancaires.
  static const Color cardPay = Color(0xFF5E6CFF);

  /// Brun chaud — segment « Charges » du cashflow split (Dashboard proprio V7).
  static const Color cashflowCharges = Color(0xFFA06B30);

  // ============ GRADIENTS TONAL (placeholders d'images) ============
  /// Gradient or — tone 1 (Loft Plateau, etc.).
  static const List<Color> tonalGradient1 = [
    Color(0xFF2A2118),
    Color(0xFF181410),
    Color(0xFF0F0C08),
  ];

  /// Gradient vert — tone 2 (Studio Cocody, etc.).
  static const List<Color> tonalGradient2 = [
    Color(0xFF1F2A24),
    Color(0xFF131A18),
    Color(0xFF0A100E),
  ];

  /// Gradient violet — tone 3 (Vue lagune, etc.).
  static const List<Color> tonalGradient3 = [
    Color(0xFF2A1F2A),
    Color(0xFF1A131A),
    Color(0xFF100A10),
  ];

  /// Gradient bleu — tone 4 (Penthouse Almadies, etc.).
  static const List<Color> tonalGradient4 = [
    Color(0xFF1F2530),
    Color(0xFF131820),
    Color(0xFF0A0E14),
  ];

  /// Halo radial subtil pour les `tonalGradient*` (or, vert, violet, bleu).
  static const Color tonalHalo1 = Color(0x2EE8B86B);
  static const Color tonalHalo2 = Color(0x214ADE80);
  static const Color tonalHalo3 = Color(0x21C084FC);
  static const Color tonalHalo4 = Color(0x2160A5FA);

  // ============ HERO GRADIENTS (cards de dashboard) ============
  /// Hero or chaud — proprio dashboard "Revenus du mois".
  static const List<Color> heroGradientGold = [
    Color(0xFF2A1F0E),
    Color(0xFF1A1206),
    Color(0xFF0F0A04),
  ];

  /// Hero bleu nuit — démarcheur dashboard "Mes commissions".
  static const List<Color> heroGradientBlue = [
    Color(0xFF1A2A4A),
    Color(0xFF0E1626),
    Color(0xFF060A14),
  ];

  /// Variante 2 stops du `heroGradientBlue` — démarcheur Wallet "Solde".
  static const List<Color> heroGradientBlueShort = [
    Color(0xFF1A2A4A),
    Color(0xFF0E1626),
  ];

  /// Accent bleu nuit — eyebrow et icons sur les cards `heroGradientBlue`.
  static const Color walletBlueAccent = Color(0xFF8B9AFF);

  /// Bordure des cards `heroGradientBlue` (bleu translucide à 25%).
  static const Color walletBlueBorder = Color(0x405E6CFF);

  /// Halo radial bleu pour l'angle haut-droit du `WalletHeroCard`.
  static const Color walletBlueHalo = Color(0x2E5E6CFF);

  // ============ AVATAR GRADIENT ============
  /// Couleur claire (haut) du gradient avatar — = `accentDark`.
  static const Color avatarGradientStart = Color(0xFFC99650);

  /// Couleur foncée (bas) du gradient avatar.
  static const Color avatarGradientEnd = Color(0xFF5A3A1A);

  // ============ MAP PLACEHOLDER ============
  /// Fond top du `MapPlaceholder` (légèrement plus clair que bg principal).
  static const Color mapBaseStart = Color(0xFF0F1416);

  /// Fond bottom du `MapPlaceholder`.
  static const Color mapBaseEnd = Color(0xFF0A0E10);

  // ============ PRIMITIVES (usage restreint) ============
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
