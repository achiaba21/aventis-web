import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/code_reservation.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/service/model/booking/reservation_service.dart';
import 'package:asfar/widget/loader/circular_progress.dart';
import 'package:asfar/widget/reservation/reservation_code_card.dart';
import 'package:asfar/widget/reservation/reservation_info_card.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget qui charge et affiche le code de réservation dynamiquement
/// Le code est récupéré via un endpoint séparé après le paiement
class ReservationCodeSection extends StatefulWidget {
  const ReservationCodeSection({super.key, required this.reservation});

  final Reservation reservation;

  @override
  State<ReservationCodeSection> createState() => _ReservationCodeSectionState();
}

class _ReservationCodeSectionState extends State<ReservationCodeSection> {
  CodeReservation? _codeReservation;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Charger automatiquement le code si la réservation est payée/confirmée
    if (_shouldLoadCode()) {
      _loadCode();
    }
  }

  /// Vérifie si on doit charger le code
  bool _shouldLoadCode() {
    // Charger le code uniquement si la réservation est PAYÉE ou FINALISÉE
    // Le client a accès au code QR après le paiement
    if (false) {
      return (widget.reservation.statut == ReservationStatus.payee ||
              widget.reservation.statut == ReservationStatus.finalisee) &&
          widget.reservation.reference != null;
    }
    return false;
  }

  /// Charge le code de réservation directement via le service
  /// (sans passer par le BLoC pour éviter de perturber l'état des réservations)
  Future<void> _loadCode() async {
    if (widget.reservation.reference == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Utiliser directement le service au lieu du BLoC
      final reservationService = ReservationService();
      final code = await reservationService.getReservationCode(
        widget.reservation.reference!,
      );

      if (mounted) {
        setState(() {
          _codeReservation = code;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Erreur de chargement du code";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ne rien afficher si on ne doit pas charger le code
    // (réservation non confirmée OU non payée)
    if (!_shouldLoadCode()) {
      return SizedBox.shrink();
    }

    // Si confirmée et payée, charger le code (sans BlocListener)
    return Column(
      children: [
        Gap(Espacement.gapSection),
        ReservationInfoCard(
          title: "Code de réservation",
          icon: Icons.qr_code_2,
          child: _buildContent(),
        ),
      ],
    );
  }

  /// Construit le contenu selon l'état (loading, error, ou code)
  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Espacement.paddingBloc * 2),
          child: Column(
            children: [
              CircularProgress(),
              Gap(Espacement.paddingBloc),
              TextSeed(
                "Chargement du code...",
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_codeReservation != null) {
      return ReservationCodeCard(codeReservation: _codeReservation!);
    }

    // Cas par défaut : bouton pour charger le code
    return _buildLoadButton();
  }

  /// Affiche l'erreur avec bouton de réessai
  Widget _buildErrorState() {
    return Padding(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 48),
          Gap(Espacement.paddingBloc),
          TextSeed(
            _errorMessage ?? "Erreur de chargement",
            fontSize: 14,
            color: AppColors.error,
            textAlign: TextAlign.center,
          ),
          Gap(Espacement.paddingBloc),
          ElevatedButton.icon(
            onPressed: _loadCode,
            icon: Icon(Icons.refresh, size: 18),
            label: Text("Réessayer"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton pour charger le code manuellement
  Widget _buildLoadButton() {
    return Padding(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      child: Column(
        children: [
          Icon(Icons.qr_code_2, color: AppColors.accent, size: 48),
          Gap(Espacement.paddingBloc),
          TextSeed(
            "Votre code de réservation est prêt",
            fontSize: 14,
            color: AppColors.border,
            textAlign: TextAlign.center,
          ),
          Gap(Espacement.paddingBloc),
          ElevatedButton.icon(
            onPressed: _loadCode,
            icon: Icon(Icons.download, size: 18),
            label: Text("Afficher le code"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
