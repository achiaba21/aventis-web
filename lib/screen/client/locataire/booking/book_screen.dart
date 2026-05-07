import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/receipt_cubit/receipt_cubit.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/enumeration/moyen_paiement.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/locataire/home/widget/reservation/methode_payment.dart';
import 'package:asfar/screen/client/locataire/inbox/conversation.dart';
import 'package:asfar/screen/receipt/receipt_detail_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/service/model/message/message_service.dart';
import 'package:asfar/service/proprietaire/proprietaire_service.dart';
import 'package:asfar/model/user/proprietaire.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/date/date_item.dart';
import 'package:asfar/widget/item/appart/appart_proprio_info.dart';
import 'package:asfar/widget/item/appart/appart_tile_item.dart';
import 'package:asfar/widget/receipt/receipt_card.dart';
import 'package:asfar/widget/reservation/client_reservation_actions_bar.dart';
import 'package:asfar/widget/reservation/reservation_code_section.dart';
import 'package:asfar/widget/reservation/reservation_info_card.dart';
import 'package:asfar/widget/reservation/reservation_status_badge.dart';
import 'package:asfar/widget/reservation/review_section.dart';
import 'package:asfar/widget/text/text_seed.dart';

class BookScreen extends StatefulWidget {
  const BookScreen(this.reservation, {super.key});
  final Reservation reservation;

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  late final ReceiptCubit _receiptCubit;
  Proprietaire? _proprietaire;

  Reservation get reservation => widget.reservation;

  @override
  void initState() {
    super.initState();
    _receiptCubit = ReceiptCubit();
    _loadProprietaire();

    // Charger la facture si la réservation a une référence et est payée/finalisée
    if (reservation.reference != null &&
        (reservation.statut == ReservationStatus.payee ||
            reservation.statut == ReservationStatus.finalisee)) {
      _receiptCubit.loadReservationReceipt(reservation.reference!);
    }
  }

  /// Charge le propriétaire via ProprietaireService (cache ou API)
  Future<void> _loadProprietaire() async {
    final appartId = reservation.appart?.id;
    if (appartId == null) return;

    final proprio = await ProprietaireService().getProprietaire(appartId);
    if (mounted) {
      setState(() => _proprietaire = proprio);
    }
  }

  @override
  void dispose() {
    _receiptCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appart = reservation.appart!;

    return BlocProvider.value(
      value: _receiptCubit,
      child: BlocListener<ReservationBloc, ReservationState>(
      listener: (context, state) {
        if (state is ReservationPaid) {
          back(context); // Fermer le dialog
          back(context); // Retourner à la liste des réservations
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Paiement effectué avec succès"),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is ReservationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextSeed("Détails de la réservation"),
          centerTitle: true,
          foregroundColor: AppColors.textPrimary,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Espacement.paddingBloc),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge de statut
                    Center(
                      child: ReservationStatusBadge(status: reservation.statut),
                    ),

                    Gap(Espacement.gapSection),

                    // Carte de l'appartement
                    AppartTileItem(appart),

                    Gap(Espacement.gapSection),

                    // Informations du propriétaire
                    ReservationInfoCard(
                      title: "Propriétaire",
                      icon: Icons.person,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppartProprioInfo(appart),
                          Gap(Espacement.paddingBloc),
                          // Bouton actif uniquement si payée ou finalisée
                          Opacity(
                            opacity:
                                (reservation.statut ==
                                            ReservationStatus.payee ||
                                        reservation.statut ==
                                            ReservationStatus.finalisee)
                                    ? 1.0
                                    : 0.5,
                            child: PlainButton(
                              value: "Contacter le propriétaire",
                              plain: false,
                              onPress:
                                  (reservation.statut ==
                                              ReservationStatus.payee ||
                                          reservation.statut ==
                                              ReservationStatus.finalisee)
                                      ? () async {
                                        // Récupérer currentUserId
                                        final userState =
                                            context.read<UserBloc>().state;
                                        final currentUserId =
                                            (userState is UserLoaded)
                                                ? userState.loadedUser.id ?? 0
                                                : 0;

                                        if (_proprietaire?.id != null) {
                                          // 1. Tentative de récupération locale (Optimisation)
                                          final conversationState =
                                              context
                                                  .read<ConversationBloc>()
                                                  .state;
                                          int? existingConversationId;

                                          if (conversationState
                                              is ConversationLoaded) {
                                            try {
                                              final existingSeance = conversationState
                                                  .conversations
                                                  .firstWhere((c) {
                                                    // On cherche une conversation où le propriétaire de la réservation est impliqué
                                                    // (soit en tant que propriétaire, soit en tant que locataire - cas rare mais possible)
                                                    return c.proprietaire?.id ==
                                                            _proprietaire!
                                                                .id ||
                                                        c.locataire?.id ==
                                                            _proprietaire!
                                                                .id;
                                                  });
                                              existingConversationId =
                                                  existingSeance.id;
                                              deboger([
                                                '✅ Conversation trouvée localement: $existingConversationId',
                                              ]);
                                            } catch (_) {
                                              deboger([
                                                '⚠️ Pas de conversation trouvée localement dans ${conversationState.conversations.length} éléments',
                                              ]);
                                            }
                                          } else {
                                            deboger([
                                              '⚠️ ConversationBloc non chargé (${conversationState.runtimeType}), passage à l\'API',
                                            ]);
                                          }

                                          // 2. Fallback API si non trouvé localement
                                          if (existingConversationId == null) {
                                            try {
                                              deboger([
                                                '🔄 Recherche API pour participant ${_proprietaire!.id}',
                                              ]);
                                              final apiSeance =
                                                  await MessageService()
                                                      .findSeanceByParticipants(
                                                        _proprietaire!
                                                            .id!,
                                                      );
                                              existingConversationId =
                                                  apiSeance?.id;
                                              deboger([
                                                '${existingConversationId != null ? "✅" : "❌"} Résultat API: $existingConversationId',
                                              ]);
                                            } catch (e) {
                                              deboger([
                                                '❌ Erreur recherche API: $e',
                                              ]);
                                            }
                                          }

                                          if (context.mounted) {
                                            // Naviguer vers ConversationScreen
                                            pushScreen(
                                              context,
                                              ConversationScreen(
                                                conversationId:
                                                    existingConversationId, // ID local ou null
                                                contactName:
                                                    "${_proprietaire?.prenom ?? ''} ${_proprietaire?.nom ?? ''}"
                                                        .trim(),
                                                currentUserId: currentUserId,
                                                contactId:
                                                    _proprietaire?.id,
                                                // Paramètres pour la création (si conversationId est null)
                                                proprietaireId:
                                                    _proprietaire?.id,
                                                locataireId: currentUserId,
                                                reservationReference:
                                                    reservation.reference,
                                              ),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Informations du propriétaire non disponibles",
                                              ),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                        }
                                      }
                                      : null, // Désactivé si non payé/finalisé
                            ),
                          ),
                          // Message explicatif si bouton désactivé
                          if (reservation.statut != ReservationStatus.payee &&
                              reservation.statut !=
                                  ReservationStatus.finalisee) ...[
                            Gap(Espacement.paddingInput),
                            TextSeed(
                              "Vous pourrez contacter le propriétaire après le paiement",
                              fontSize: 12,
                              color: AppColors.textMuted,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),

                    Gap(Espacement.gapSection),

                    // Dates de réservation
                    DateItem(selectedRange: reservation.plage, readOnly: true),

                    // Informations de paiement (si disponibles)
                    if (reservation.prix != null ||
                        reservation.reference != null) ...[
                      Gap(Espacement.gapSection),
                      ReservationInfoCard(
                        title: "Paiement",
                        icon: Icons.payment,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (reservation.prix != null)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextSeed(
                                    "Montant total",
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                  TextSeed(
                                    "${helpAmountFormate(reservation.prix!.toInt(), decim: false)} FCFA",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent,
                                  ),
                                ],
                              ),
                            if (reservation.reference != null) ...[
                              Gap(Espacement.paddingInput),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextSeed(
                                    "Référence",
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                  TextSeed(
                                    reservation.reference!,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Section des reçus (si réservation payée/finalisée)
                    if (reservation.statut == ReservationStatus.payee ||
                        reservation.statut == ReservationStatus.finalisee) ...[
                      Gap(Espacement.gapSection),
                      ReservationInfoCard(
                        title: "Reçus",
                        icon: Icons.receipt_long,
                        child: BlocBuilder<ReceiptCubit, ReceiptState>(
                          builder: (context, state) {
                            if (state is ReceiptLoading) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (state is ReceiptError) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: AppColors.textMuted,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      TextSeed(
                                        state.message,
                                        fontSize: 13,
                                        color: AppColors.textMuted,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () {
                                          if (reservation.reference != null) {
                                            context
                                                .read<ReceiptCubit>()
                                                .loadReservationReceipt(
                                                  reservation.reference!,
                                                );
                                          }
                                        },
                                        child: const Text("Réessayer"),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (state is SingleReceiptLoaded) {
                              return SingleReceiptSection(
                                receipt: state.receipt,
                                onReceiptTap: (receipt) {
                                  pushScreen(
                                    context,
                                    ReceiptDetailScreen(receipt: receipt),
                                  );
                                },
                              );
                            }

                            // État initial - pas de facture chargée
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextSeed(
                                  "Chargement de la facture...",
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    // Code de réservation (QR Code) - Chargé dynamiquement après paiement
                    ReservationCodeSection(reservation: reservation),

                    Gap(Espacement.gapSection),

                    // Section des avis
                    ReviewSection(
                      reservation: reservation,
                      commentaires: appart.commentaires,
                    ),

                    Gap(Espacement.gapSection),
                  ],
                ),
              ),
            ),
            // Actions conditionnelles basées sur le statut
            ClientReservationActionsBar(
              reservation: reservation,
              onPay: () => _showPaymentDialog(context),
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// Dialog de paiement pour une réservation confirmée
  void _showPaymentDialog(BuildContext context) {
    final moyenPaiement = reservation.moyenPaiement;
    final hasPaymentMethod = moyenPaiement != null;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.background,
            title: TextSeed(
              "Payer la réservation",
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSeed(
                  "Montant à payer : ${helpAmountFormate(reservation.prix?.toInt() ?? 0, decim: false)} FCFA",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
                Gap(Espacement.paddingBloc),
                TextSeed(
                  "Référence : ${reservation.reference ?? 'N/A'}",
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
                Gap(Espacement.gapSection),

                // Si le moyen de paiement existe déjà, l'afficher
                if (hasPaymentMethod) ...[
                  TextSeed(
                    "Moyen de paiement",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  Gap(Espacement.paddingInput),
                  Container(
                    padding: EdgeInsets.all(Espacement.paddingBloc),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(Espacement.radius),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: AppColors.accent,
                          size: 24,
                        ),
                        Gap(Espacement.paddingInput),
                        Expanded(
                          child: TextSeed(
                            _getPaymentMethodLabel(moyenPaiement),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  if (reservation.numeroCompte != null) ...[
                    Gap(Espacement.paddingInput),
                    TextSeed(
                      "Numéro : ${reservation.numeroCompte}",
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ],
                ] else ...[
                  // Sinon, permettre la sélection
                  MethodePayment(),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => back(context),
                child: TextSeed("Annuler", color: AppColors.textMuted),
              ),
              ElevatedButton(
                onPressed: () {
                  // Déclencher l'événement de paiement via le BLoC
                  if (reservation.reference != null) {
                    context.read<ReservationBloc>().add(
                      PayReservation(reservation.reference!),
                    );
                  } else {
                    back(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Erreur: référence de réservation manquante",
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                child: TextSeed("Confirmer le paiement", color: AppColors.white),
              ),
            ],
          ),
    );
  }

  /// Retourne le label du moyen de paiement
  String _getPaymentMethodLabel(MoyenPaiement? moyenPaiement) {
    switch (moyenPaiement) {
      case MoyenPaiement.OM:
        return 'Orange Money';
      case MoyenPaiement.MOOV_MONNEY:
        return 'Moov Money';
      case MoyenPaiement.MOMO:
        return 'MTN Mobile Money';
      case MoyenPaiement.WAVE:
        return 'Wave';
      case null:
        return 'Non spécifié';
    }
  }
}
