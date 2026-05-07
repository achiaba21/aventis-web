import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/receipt.dart';
import 'package:asfar/service/pdf/receipt_pdf_service.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Écran de détail d'un reçu
class ReceiptDetailScreen extends StatefulWidget {
  const ReceiptDetailScreen({
    super.key,
    required this.receipt,
  });

  final Receipt receipt;

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  final ReceiptPdfService _pdfService = ReceiptPdfService();
  bool _isLoading = false;

  Receipt get receipt => widget.receipt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: TextSeed("Reçu ${receipt.typeRecu.label}"),
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(value, context),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 20),
                    SizedBox(width: 12),
                    Text('Partager'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 12),
                    Text('Télécharger'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print, size: 20),
                    SizedBox(width: 12),
                    Text('Imprimer'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(Espacement.paddingBloc),
            child: Column(
              children: [
                // Reçu stylisé
                _ReceiptDocument(receipt: receipt),

                const SizedBox(height: 24),

                // Actions
                _ActionButtons(
                  onShare: () => _sharePdf(context),
                  onSave: () => _savePdf(context),
                  onPrint: () => _printPdf(context),
                  onCopy: () => _copyReceiptNumber(context),
                ),
              ],
            ),
          ),
          // Loader
          if (_isLoading)
            Container(
              color: AppColors.textSecondary,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.white),
                    SizedBox(height: 16),
                    Text(
                      'Génération du PDF...',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'share':
        _sharePdf(context);
        break;
      case 'save':
        _savePdf(context);
        break;
      case 'print':
        _printPdf(context);
        break;
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      await _pdfService.sharePdf(receipt);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors du partage: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePdf(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final path = await _pdfService.savePdf(receipt);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("PDF sauvegardé: $path"),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la sauvegarde: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _printPdf(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      await _pdfService.printPdf(receipt);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de l'impression: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyReceiptNumber(BuildContext context) {
    if (receipt.numeroRecu != null) {
      Clipboard.setData(ClipboardData(text: receipt.numeroRecu!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Numéro de reçu copié: ${receipt.numeroRecu}"),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

/// Document de reçu stylisé - Thème sombre Asfar
class _ReceiptDocument extends StatelessWidget {
  const _ReceiptDocument({required this.receipt});

  final Receipt receipt;

  // Couleur de fond Asfar (identique au PDF - reste sombre pour correspondre au PDF)
  static const Color _backgroundColor = Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(Espacement.radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec logo Asfar
          _ReceiptHeader(receipt: receipt),

          const SizedBox(height: 32),

          // Titre principal
          _ReceiptTitle(receipt: receipt),

          const SizedBox(height: 16),

          // Message d'introduction
          _IntroMessage(),

          const SizedBox(height: 24),

          // Section client
          _ClientSection(receipt: receipt),

          const SizedBox(height: 20),

          // Section dates
          _DatesSection(receipt: receipt),

          const SizedBox(height: 20),

          // Section localisation
          _LocationSection(receipt: receipt),

          const SizedBox(height: 20),

          // Section financière
          _FinancialSection(receipt: receipt),

          const SizedBox(height: 32),

          // Pied de page
          _ReceiptFooter(receipt: receipt),
        ],
      ),
    );
  }
}

/// En-tête du reçu - Style Asfar avec logo
class _ReceiptHeader extends StatelessWidget {
  const _ReceiptHeader({required this.receipt});

  final Receipt receipt;

  static const Color _primaryColor = Color(0xFFFF6B35);
  static const Color _greyColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Icône A stylisée
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: TextSeed(
                  'A',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const TextSeed(
              'Asfar',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextSeed(
          "Explorez l'authenticité, comme chez vous.",
          fontSize: 12,
          color: _greyColor,
        ),
      ],
    );
  }
}

/// Titre principal du reçu
class _ReceiptTitle extends StatelessWidget {
  const _ReceiptTitle({required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context) {
    final isDefinitif = receipt.typeRecu == ReceiptType.definitif;
    final typeLabel = isDefinitif ? 'Paiement complet' : 'Acompte payé';
    final dateStr = formateDateSlash(receipt.dateEmission);

    return Center(
      child: TextSeed(
        '$typeLabel - $dateStr',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Message d'introduction
class _IntroMessage extends StatelessWidget {
  static const Color _greyColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextSeed(
        'Cher client Asfar, merci de trouver ci-dessous le détail de la\nréservation de votre séjour :',
        fontSize: 14,
        color: _greyColor,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Section client - Style Asfar avec icône
class _ClientSection extends StatelessWidget {
  const _ClientSection({required this.receipt});

  final Receipt receipt;

  static const Color _greyColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return _IconRow(
      icon: Icon(Icons.person_outline, color: _greyColor, size: 24),
      child: TextSeed(
        receipt.locataireFullName.isNotEmpty
            ? receipt.locataireFullName
            : 'Client',
        fontSize: 16,
        color: Colors.white,
      ),
    );
  }
}

/// Section dates - Style Asfar avec check-in/check-out
class _DatesSection extends StatelessWidget {
  const _DatesSection({required this.receipt});

  final Receipt receipt;

  static const Color _greyColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    final nombreJours = receipt.nombreJours ?? 0;
    final dureeLabel = nombreJours > 1 ? '$nombreJours jours' : '$nombreJours jour';

    return _IconRow(
      icon: Icon(Icons.calendar_today_outlined, color: _greyColor, size: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSeed(
            dureeLabel,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          if (receipt.dateDebut != null)
            _LabelValueRow(
              label: 'Check-in',
              value: formateDateWithDay(receipt.dateDebut, heure: '12h'),
            ),
          const SizedBox(height: 4),
          if (receipt.dateFin != null)
            _LabelValueRow(
              label: 'Check-out',
              value: formateDateWithDay(receipt.dateFin, heure: '12h'),
            ),
        ],
      ),
    );
  }
}

/// Section localisation - Style Asfar
class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.receipt});

  final Receipt receipt;

  static const Color _greyColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    final location = receipt.residenceNom ?? receipt.appartementTitre ?? '';
    if (location.isEmpty) return const SizedBox.shrink();

    return _IconRow(
      icon: Icon(Icons.location_on_outlined, color: _greyColor, size: 24),
      child: TextSeed(
        location,
        fontSize: 14,
        color: Colors.white,
      ),
    );
  }
}

/// Section financière - Style Asfar
class _FinancialSection extends StatelessWidget {
  const _FinancialSection({required this.receipt});

  final Receipt receipt;

  static const Color _primaryColor = Color(0xFFFF6B35);
  static const Color _greyColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    final devise = receipt.devise ?? 'FCFA';
    final montantTotal = receipt.montantTotal ?? 0;
    final montantVerse = receipt.montantVerse ?? 0;
    final montantRestant = receipt.montantRestant ?? 0;
    final nombreJours = receipt.nombreJours ?? 1;

    // Calcul du prix par jour si possible
    final prixParJour = nombreJours > 0 ? (montantTotal / nombreJours).round() : 0;

    // Calcul du pourcentage d'acompte
    final pourcentageVerse = montantTotal > 0
        ? ((montantVerse / montantTotal) * 100).round()
        : 0;

    return _IconRow(
      icon: Icon(Icons.receipt_long_outlined, color: _greyColor, size: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Montant initial (prix x jours)
          if (prixParJour > 0)
            _LabelValueRow(
              label: 'Montant initial',
              value: '${helpAmountFormate(prixParJour, decim: false)} x $nombreJours = ${helpAmountFormate(montantTotal.toInt(), decim: false)} $devise',
            ),
          const SizedBox(height: 6),

          // Montant du séjour
          _LabelValueRow(
            label: 'Montant du séjour',
            value: '${helpAmountFormate(montantTotal.toInt(), decim: false)} $devise',
            isBold: true,
          ),
          const SizedBox(height: 6),

          // Acompte réglé
          _LabelValueRow(
            label: 'Acompte réglé',
            value: '$pourcentageVerse% soit ${helpAmountFormate(montantVerse.toInt(), decim: false)} $devise',
            valueColor: _primaryColor,
          ),
          const SizedBox(height: 6),

          // Réliquat (si > 0)
          if (montantRestant > 0)
            _LabelValueRow(
              label: 'Réliquat',
              value: '${helpAmountFormate(montantRestant.toInt(), decim: false)} $devise',
              isBold: true,
            ),

          // Moyen de paiement
          if (receipt.moyenPaiement != null) ...[
            const SizedBox(height: 6),
            _LabelValueRow(
              label: 'Moyen de paiement',
              value: receipt.moyenPaiement!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget helper pour les lignes avec icône
class _IconRow extends StatelessWidget {
  const _IconRow({required this.icon, required this.child});

  final Widget icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: 16),
        Expanded(child: child),
      ],
    );
  }
}

/// Widget pour afficher une ligne label: valeur
class _LabelValueRow extends StatelessWidget {
  const _LabelValueRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  static const Color _greyColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextSeed(
          '$label : ',
          fontSize: 13,
          color: _greyColor,
        ),
        Expanded(
          child: TextSeed(
            value,
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Pied de page du reçu - Style Asfar
class _ReceiptFooter extends StatelessWidget {
  const _ReceiptFooter({required this.receipt});

  final Receipt receipt;

  static const Color _greyColor = Color(0xFF9E9E9E);
  static const Color _lightGreyColor = Color(0xFFBDBDBD);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(
          child: TextSeed(
            'Merci pour ta confiance et à très bientôt...',
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextSeed(
            "En cas de besoin, n'hésitez pas à nous contacter au +225 07 029 254 50",
            fontSize: 12,
            color: _greyColor,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: TextSeed(
            'Team Asfar,',
            fontSize: 12,
            color: _lightGreyColor,
          ),
        ),
      ],
    );
  }
}

/// Boutons d'action
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onShare,
    required this.onSave,
    required this.onPrint,
    required this.onCopy,
  });

  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onPrint;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Boutons principaux
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.share,
                label: "Partager",
                onPressed: onShare,
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.download,
                label: "Télécharger",
                onPressed: onSave,
                isPrimary: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Boutons secondaires
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.print,
                label: "Imprimer",
                onPressed: onPrint,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.copy,
                label: "Copier le n°",
                onPressed: onCopy,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Bouton d'action individuel
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textOnAccent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: BorderSide(color: AppColors.textSecondary),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
