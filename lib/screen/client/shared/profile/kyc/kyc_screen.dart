import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/document_cubit/document_cubit.dart';
import 'package:asfar/bloc/document_cubit/document_state.dart';
import 'package:asfar/model/document/document_status.dart';
import 'package:asfar/model/document/identity_document.dart';
import 'package:asfar/screen/client/shared/profile/kyc/widget/identity_document_card.dart';
import 'package:asfar/screen/client/shared/profile/kyc/widget/kyc_status_header.dart';
import 'package:asfar/screen/client/shared/profile/kyc/widget/kyc_upload_sheet.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/util/calc/kyc_status_resolver.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/loader/loader_circular.dart';

/// Écran de vérification d'identité (KYC) — propriétaire / démarcheur.
///
/// Affiche le statut global, l'historique des documents (tous statuts + motif
/// de refus) et permet d'envoyer une nouvelle pièce. Se rafraîchit au verdict
/// admin via le `DocumentCubit` (rechargé depuis le profil sur notification).
class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DocumentCubit>().load();
    });
  }

  bool _hasRefusedPending(List<IdentityDocument> docs) {
    return !KycStatusResolver.isVerified(docs) &&
        docs.any((d) => d.status == DocumentStatus.refuser);
  }

  void _openUploadSheet() {
    final cubit = context.read<DocumentCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => KycUploadSheet(
        onSubmit: (File file, String titre) async {
          final ok = await cubit.upload(file, titre);
          if (ok && sheetContext.mounted) {
            Navigator.of(sheetContext).pop();
          }
          return ok;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Vérification d\'identité',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: BlocConsumer<DocumentCubit, DocumentState>(
          listenWhen: (prev, curr) => curr is DocumentError,
          listener: (context, state) {
            if (state is DocumentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is DocumentLoading && state.documents.isEmpty) {
              return const Center(child: LoaderCircular());
            }
            if (state is DocumentError && state.documents.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: EmptyState.error(
                  message: state.message,
                  onRetry: () => context.read<DocumentCubit>().load(),
                ),
              );
            }

            final docs = state.documents;
            final label = _hasRefusedPending(docs)
                ? 'Renvoyer une pièce'
                : 'Envoyer une pièce';

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                    children: [
                      KycStatusHeader(status: state.globalStatus),
                      const SizedBox(height: 22),
                      if (docs.isEmpty)
                        EmptyState.inline(
                          icon: Icons.verified_user_outlined,
                          title: 'Aucune pièce envoyée',
                          body:
                              'Envoyez une pièce d\'identité pour vérifier votre compte.',
                        )
                      else ...[
                        const Text('MES DOCUMENTS',
                            style: AppTextStyles.eyebrow),
                        const SizedBox(height: 10),
                        ...docs.map(
                          (d) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: IdentityDocumentCard(document: d),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                  child: CustomButton(
                    text: label,
                    leadingIcon: Icons.upload_file_outlined,
                    size: ButtonSize.lg,
                    block: true,
                    loading: state is DocumentUploading,
                    onPressed: _openUploadSheet,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
