import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_event.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_state.dart';
import 'package:web_flutter/widget/button/plain_button.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class FavoriteErrorWidget extends StatelessWidget {
  final FavoriteError errorState;
  final String? customMessage;
  final VoidCallback? onRetry;

  const FavoriteErrorWidget({
    super.key,
    required this.errorState,
    this.customMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.red[300],
            ),
            SizedBox(height: 24),
            TextSeed(
              "Erreur avec les favoris",
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 8),
            TextSeed(
              customMessage ?? errorState.message,
              textAlign: TextAlign.center,
              color: Colors.grey[600],
            ),
            SizedBox(height: 32),
            if (errorState.canRetry) ...[
              PlainButton(
                value: "Réessayer",
                onPress: onRetry ??
                    () {
                      if (errorState.originalEvent != null) {
                        context.read<FavoriteBloc>().add(
                              RetryFailedAction(errorState.originalEvent),
                            );
                      } else {
                        context.read<FavoriteBloc>().add(LoadFavorites());
                      }
                    },
              ),
              SizedBox(height: 16),
            ],
            PlainButton(
              value: "Mode offline",
              plain: false,
              onPress: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Fonctionnement en mode offline"),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher les SnackBar de succès/erreur des favoris
class FavoriteSnackBarHandler extends StatelessWidget {
  final Widget child;

  const FavoriteSnackBarHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoriteBloc, FavoriteState>(
      listener: (context, state) {
        if (state is FavoriteActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              action: SnackBarAction(
                label: "OK",
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        } else if (state is FavoriteError && state.canRetry) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
              action: SnackBarAction(
                label: "Réessayer",
                textColor: Colors.white,
                onPressed: () {
                  if (state.originalEvent != null) {
                    context.read<FavoriteBloc>().add(
                          RetryFailedAction(state.originalEvent),
                        );
                  }
                },
              ),
            ),
          );
        } else if (state is FavoriteSynced && state.hasChanges) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Favoris synchronisés"),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: child,
    );
  }
}