import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/proprio_demarcheur_bloc/proprio_demarcheur_bloc.dart';
import 'package:asfar/bloc/proprio_demarcheur_bloc/proprio_demarcheur_event.dart';
import 'package:asfar/bloc/proprio_demarcheur_bloc/proprio_demarcheur_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/screen/client/proprio/demarcheurs/widget/demarcheur_item.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Écran de gestion des démarcheurs partenaires (vue propriétaire)
class MesDemarcheursScreen extends StatefulWidget {
  const MesDemarcheursScreen({super.key});

  @override
  State<MesDemarcheursScreen> createState() => _MesDemarcheursScreenState();
}

class _MesDemarcheursScreenState extends State<MesDemarcheursScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProprietaireDemarcheurBloc>().add(LoadDemarcheurs());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProprietaireDemarcheurBloc,
        ProprietaireDemarcheurState>(
      listener: (context, state) {
        if (state is DemarcheurLinkSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is DemarcheurUnlinkSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Démarcheur délié avec succès"),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is ProprietaireDemarcheurError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: TextSeed(
            "Mes démarcheurs",
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textPrimary,
          ),
          actions: [
            IconButton(
              onPressed: () => _showLinkDialog(context),
              icon: const Icon(Icons.person_add_outlined),
              color: AppColors.accent,
              tooltip: "Ajouter un démarcheur",
            ),
          ],
        ),
        body: BlocBuilder<ProprietaireDemarcheurBloc,
            ProprietaireDemarcheurState>(
          builder: (context, state) {
            if (state is ProprietaireDemarcheurLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProprietaireDemarcheurError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      TextSeed(
                        state.message,
                        color: AppColors.textMuted,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context
                            .read<ProprietaireDemarcheurBloc>()
                            .add(LoadDemarcheurs()),
                        child: const Text("Réessayer"),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is DemarchemursLoaded) {
              if (state.demarcheurs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: AppColors.inactive),
                        const SizedBox(height: 16),
                        TextSeed(
                          "Aucun démarcheur associé",
                          fontSize: 16,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        TextSeed(
                          "Ajoutez un démarcheur via son numéro de téléphone.",
                          fontSize: 13,
                          color: AppColors.textMuted,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showLinkDialog(context),
                          icon: const Icon(Icons.person_add_outlined),
                          label: const Text("Ajouter un démarcheur"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.all(Espacement.paddingBloc),
                itemCount: state.demarcheurs.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: Espacement.gapSection),
                itemBuilder: (context, index) {
                  final demarcheur = state.demarcheurs[index];
                  return DemarcheurItem(
                    demarcheur: demarcheur,
                    onUnlink: demarcheur.id != null
                        ? () => _confirmUnlink(context, demarcheur.id!)
                        : null,
                  );
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _showLinkDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: TextSeed(
          "Ajouter un démarcheur",
          fontWeight: FontWeight.bold,
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: "Numéro de téléphone",
            hintStyle: TextStyle(color: AppColors.textMuted),
            prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: TextSeed("Annuler", color: AppColors.textMuted),
          ),
          ElevatedButton(
            onPressed: () {
              final tel = controller.text.trim();
              if (tel.isNotEmpty) {
                context
                    .read<ProprietaireDemarcheurBloc>()
                    .add(LinkDemarcheur(tel));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent),
            child: TextSeed("Ajouter", color: AppColors.textOnAccent),
          ),
        ],
      ),
    );
  }

  void _confirmUnlink(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: TextSeed("Délier ce démarcheur ?",
            fontWeight: FontWeight.bold),
        content: TextSeed(
          "Cette action retirera ce démarcheur de vos partenaires.",
          color: AppColors.textMuted,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: TextSeed("Annuler", color: AppColors.textMuted),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<ProprietaireDemarcheurBloc>()
                  .add(UnlinkDemarcheur(id));
              Navigator.pop(ctx);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: TextSeed("Délier", color: AppColors.textOnAccent),
          ),
        ],
      ),
    );
  }
}
