import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/commentaire/commentaire.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/locataire/booking/add_comment.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/item/commentaire_item.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class ReviewSection extends StatelessWidget {
  const ReviewSection({
    super.key,
    required this.reservation,
    this.commentaires,
  });

  final Reservation reservation;
  final List<Commentaire>? commentaires;

  @override
  Widget build(BuildContext context) {
    final hasComments = commentaires != null && commentaires!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(Espacement.paddingBloc),
        boxShadow: [
          BoxShadow(
            color: AppColors.white.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Espacement.paddingInput),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Espacement.radius),
                ),
                child: Icon(Icons.star, color: AppColors.warning, size: 20),
              ),
              SizedBox(width: Espacement.paddingInput),
              Expanded(
                child: TextSeed(
                  "Avis et commentaires",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: Espacement.paddingBloc),

          // Liste des commentaires
          if (hasComments) ...[
            ...commentaires!.map(
              (comment) => Padding(
                padding: EdgeInsets.only(bottom: Espacement.paddingBloc),
                child: CommentaireItem(comment),
              ),
            ),
          ] else
            // Message si aucun commentaire
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Espacement.paddingBloc * 2,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: Espacement.paddingInput),
                    TextSeed(
                      "Aucun avis pour le moment",
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ],
                ),
              ),
            ),

          // Bouton pour ajouter un avis (uniquement si finalisée et date passée)
          SizedBox(height: Espacement.paddingInput),
          if (_canAddReview())
            Center(
              child: PlainButton(
                value:
                    hasComments ? "Ajouter un avis" : "Laisser le premier avis",
                plain: false,
                onPress: () {
                  pushScreen(context, AddComment(reservation: reservation));
                },
              ),
            )
          else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Espacement.paddingInput,
                ),
                child: TextSeed(
                  _getReviewRestrictionMessage(),
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Vérifie si l'utilisateur peut ajouter un avis
  /// Conditions : réservation finalisée ET date de fin passée
  bool _canAddReview() {
    if (reservation.statut != ReservationStatus.finalisee) {
      return false;
    }

    // Vérifier si la date de fin de séjour est passée
    final endDate = reservation.fin;
    if (endDate == null) {
      return false;
    }

    return DateTime.now().isAfter(endDate);
  }

  /// Message expliquant pourquoi l'utilisateur ne peut pas encore laisser d'avis
  String _getReviewRestrictionMessage() {
    final status = reservation.statut;

    if (status == ReservationStatus.enAttente ||
        status == ReservationStatus.confirmee) {
      return "Vous pourrez laisser un avis après votre séjour";
    }

    if (status == ReservationStatus.payee) {
      return "Vous pourrez laisser un avis une fois votre séjour terminé";
    }

    if (status == ReservationStatus.finalisee) {
      final endDate = reservation.fin;
      if (endDate != null && DateTime.now().isBefore(endDate)) {
        return "Vous pourrez laisser un avis après la fin de votre séjour";
      }
    }

    return "Vous ne pouvez pas laisser d'avis pour cette réservation";
  }
}
