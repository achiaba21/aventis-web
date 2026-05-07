import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_state.dart';
import 'package:asfar/bloc/receipt_cubit/receipt_cubit.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/locataire/inbox/conversation.dart';
import 'package:asfar/screen/receipt/receipt_detail_screen.dart';
import 'package:asfar/service/model/message/message_service.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/screen/client/proprio/reservations/qr_scanner_screen.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/date/date_item.dart';
import 'package:asfar/widget/item/appart/appart_tile_item.dart';
import 'package:asfar/widget/receipt/receipt_card.dart';
import 'package:asfar/widget/reservation/reservation_actions_bar.dart';
import 'package:asfar/widget/reservation/reservation_info_card.dart';
import 'package:asfar/widget/reservation/reservation_status_badge.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/widget/user/client_info_card.dart';

/// Page de détail d'une réservation pour le propriétaire
class ProprioReservationDetailScreen extends StatefulWidget {
  const ProprioReservationDetailScreen(this.reservation, {super.key});
  final Reservation reservation;

  @override
  State<ProprioReservationDetailScreen> createState() =>
      _ProprioReservationDetailScreenState();
}

class _ProprioReservationDetailScreenState
    extends State<ProprioReservationDetailScreen> {
  late final ReceiptCubit _receiptCubit;

  Reservation get reservation => widget.reservation;

  @override
  void initState() {
    super.initState();
    _receiptCubit = ReceiptCubit();

    // Charger la facture si la réservation a une référence et est payée/finalisée
    if (reservation.reference != null &&
        (reservation.statut == ReservationStatus.payee ||
            reservation.statut == ReservationStatus.finalisee)) {
      _receiptCubit.loadReservationReceipt(reservation.reference!);
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
        if (state is ReservationConfirmed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Réservation confirmée avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        }

        if (state is ReservationRefused) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Réservation refusée'),
              backgroundColor: AppColors.warning,
            ),
          );
          Navigator.pop(context);
        }

        if (state is ReservationCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Réservation annulée'),
              backgroundColor: AppColors.warning,
            ),
          );
          Navigator.pop(context);
        }

        if (state is ReservationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextSeed("Réservation #${reservation.id ?? ''}"),
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

                    // Informations du client
                    ReservationInfoCard(
                      title: "Client",
                      icon: Icons.person,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (reservation.locataire != null)
                            ClientInfoCard(client: reservation.locataire!),
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
                              value: "Contacter le client",
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

                                        if (reservation.locataire?.id != null) {
                                          // 1. Tentative de récupération locale (Optimisation)
                                          final conversationState =
                                              context
                                                  .read<ConversationBloc>()
                                                  .state;
                                          int? existingConversationId;

                                          if (conversationState
                                              is ConversationLoaded) {
                                            try {
                                              final existingSeance =
                                                  conversationState
                                                      .conversations
                                                      .firstWhere((c) {
                                                        // On cherche une conversation où le locataire de la réservation est impliqué
                                                        return c
                                                                    .proprietaire
                                                                    ?.id ==
                                                                reservation
                                                                    .locataire!
                                                                    .id ||
                                                            c.locataire?.id ==
                                                                reservation
                                                                    .locataire!
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
                                                '🔄 Recherche API pour participant ${reservation.locataire!.id}',
                                              ]);
                                              final apiSeance =
                                                  await MessageService()
                                                      .findSeanceByParticipants(
                                                        reservation
                                                            .locataire!
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
                                                    existingConversationId, // ID trouvé ou null
                                                contactName:
                                                    "${reservation.locataire?.prenom ?? ''} ${reservation.locataire?.nom ?? ''}"
                                                        .trim(),
                                                currentUserId: currentUserId,
                                                contactId:
                                                    reservation.locataire?.id,
                                                // Paramètres pour la création (si conversationId est null)
                                                proprietaireId: currentUserId,
                                                locataireId:
                                                    reservation.locataire?.id,
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
                                                "Informations du client non disponibles",
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
                              "Vous pourrez contacter le client après le paiement",
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
                                    color: AppColors.background,
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

                    Gap(Espacement.gapSection),
                  ],
                ),
              ),
            ),
            // Actions de réservation (Accepter/Refuser/Scanner)
            ReservationActionsBar(
              reservation: reservation,
              onAccept: () {
                if (reservation.reference != null) {
                  context.read<ReservationBloc>().add(
                    ConfirmReservation(reservation.reference!),
                  );
                }
              },
              onRefuse: () {
                if (reservation.reference != null) {
                  context.read<ReservationBloc>().add(
                    RefuseReservation(reservation.reference!),
                  );
                }
              },
              onScanQR: () {
                pushScreen(context, QRScannerScreen());
              },
            ),
          ],
        ),
      ),
      ),
    );
  }
}
