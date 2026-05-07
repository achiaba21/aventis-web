import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_event.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/locataire/home/widget/appart_item.dart';
import 'package:asfar/service/model/favorite/favorite_service.dart';
import 'package:asfar/screen/client/locataire/favorite/widget/favorite_states.dart';
import 'package:asfar/widget/guest_login_prompt.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/util/function.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  List<Appartement>? appartements;
  bool isLoadingAppartements = false;
  final favoriteService = FavoriteService();

  // Plus besoin de initState() - le préchargement s'en occupe automatiquement

  Future<void> _loadAppartements(List<int> favoriteIds) async {
    if (!mounted) return;
    if (isLoadingAppartements) return;

    setState(() {
      isLoadingAppartements = true;
    });

    try {
      deboger(['[Favorite] Chargement des appartements favoris pour ${favoriteIds.length} IDs']);
      final allAppartements = await favoriteService.getFavoriteAppartements();
      deboger(['[Favorite] ${allAppartements.length} appartements chargés']);
      if (!mounted) return;
      setState(() {
        appartements = allAppartements;
        isLoadingAppartements = false;
      });
    } catch (e) {
      deboger(['[Favorite] Erreur chargement appartements: $e']);
      if (!mounted) return;
      setState(() {
        appartements = [];
        isLoadingAppartements = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        // Si l'utilisateur n'est pas connecté, afficher un message de connexion
        if (userState is! UserLoaded) {
          return Scaffold(
            appBar: AppBar(title: TextSeed("Favoris")),
            body: GuestLoginPrompt(message: "Connectez-vous pour accéder à vos favoris"),
          );
        }

        // Utilisateur connecté : afficher les favoris normalement
        return Scaffold(
          appBar: AppBar(title: TextSeed("Favoris")),
          body: BlocListener<FavoriteBloc, FavoriteState>(
            listener: (context, state) {
              if (state is FavoriteActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.success,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (state is FavoriteLoaded) {
                // Charger les appartements complets quand on a les IDs
                deboger(['[Favorite] FavoriteLoaded détecté avec ${state.favoriteIds.length} favoris']);
                // Si pas de favoris, initialiser appartements à une liste vide
                if (state.favoriteIds.isEmpty) {
                  if (mounted) {
                    setState(() {
                      appartements = [];
                      isLoadingAppartements = false;
                    });
                  }
                } else {
                  _loadAppartements(state.favoriteIds);
                }
              }
            },
            child: BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, state) {
                // Afficher skeleton pendant le chargement initial (préchargement en cours)
                if (state is FavoriteInitial) {
                  return const ListShimmer(itemCount: 3);
                }

                // Afficher skeleton pendant le chargement manuel (pull-to-refresh)
                // pour maintenir la cohérence UX
                if (state is FavoriteLoading) {
                  return const ListShimmer(itemCount: 3);
                }

                if (state is FavoriteLoaded) {
                  // Si les appartements ne sont pas encore chargés, les charger maintenant
                  if (appartements == null && !isLoadingAppartements) {
                    deboger(['[Favorite] Builder détecte FavoriteLoaded, chargement des appartements']);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (state.favoriteIds.isEmpty) {
                        setState(() {
                          appartements = [];
                          isLoadingAppartements = false;
                        });
                      } else {
                        _loadAppartements(state.favoriteIds);
                      }
                    });
                  }

                  // Pendant le chargement des appartements, continuer à afficher le skeleton
                  if (isLoadingAppartements || appartements == null) {
                    return const ListShimmer(itemCount: 3);
                  }

                  if (appartements!.isEmpty) {
                    return FavoriteEmptyState(
                      onExplore: () => Navigator.of(context).pop(),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: TextSeed(
                              "${appartements!.length} appartement${appartements!.length > 1 ? 's' : ''} favori${appartements!.length > 1 ? 's' : ''}",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ...appartements!.map((appart) => AppartItem(appart)),
                        ],
                      ),
                    ),
                  );
                } else if (state is FavoriteError) {
                  return FavoriteErrorState(message: state.message);
                }

                // État par défaut : afficher skeleton
                return const ListShimmer(itemCount: 3);
              },
            ),
          ),
        );
      },
    );
  }
}
