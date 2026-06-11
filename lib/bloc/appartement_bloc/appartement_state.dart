import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appartement_list_source.dart';

/// État de base pour les appartements.
///
/// Pattern « keep last known data » : conserve les appartements connus
/// même pendant les transitions d'état pour éviter les flashs UI.
abstract class AppartementState {
  /// Liste des derniers appartements connus (persistée entre les états).
  final List<Appartement> appartements;

  AppartementState({this.appartements = const []});
}

class AppartementInitial extends AppartementState {
  AppartementInitial({super.appartements});
}

class AppartementLoading extends AppartementState {
  AppartementLoading({super.appartements});
}

/// État unifié de chargement réussi.
///
/// `source` indique l'origine de la liste pour les consommateurs (preload
/// executor, UI conditionnelle). `ownerId` est requis quand
/// `source == byOwner`. `transientMessage` porte un message de succès
/// one-shot après une opération CRUD — consommé par BlocListener puis
/// effacé via `copyWith(clearTransientMessage: true)`.
class AppartementLoaded extends AppartementState {
  final AppartementListSource source;
  final int? ownerId;
  final String? transientMessage;

  /// Pagination du feed (PERF-02) — neutres tant que LoadMore n'est pas émis.
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final int currentPage;

  AppartementLoaded(
    List<Appartement> appartements, {
    this.source = AppartementListSource.all,
    this.ownerId,
    this.transientMessage,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.currentPage = 0,
  }) : super(appartements: appartements);

  AppartementLoaded copyWith({
    List<Appartement>? appartements,
    AppartementListSource? source,
    int? ownerId,
    String? transientMessage,
    bool clearTransientMessage = false,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    int? currentPage,
  }) {
    return AppartementLoaded(
      appartements ?? this.appartements,
      source: source ?? this.source,
      ownerId: ownerId ?? this.ownerId,
      transientMessage: clearTransientMessage
          ? null
          : (transientMessage ?? this.transientMessage),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// @deprecated Alias rétro-compat. Préférer
/// `state is AppartementLoaded && state.source == AppartementListSource.proprietaire`.
@Deprecated(
  'Utiliser AppartementLoaded(source: AppartementListSource.proprietaire). '
  'Alias retiré après migration des consommateurs.',
)
class ProprietaireAppartementsLoaded extends AppartementLoaded {
  ProprietaireAppartementsLoaded(List<Appartement> appartements)
      : super(appartements, source: AppartementListSource.proprietaire);
}

/// @deprecated Alias rétro-compat. Préférer
/// `AppartementLoaded(source: byOwner, ownerId: ...)`.
@Deprecated(
  'Utiliser AppartementLoaded(source: byOwner, ownerId: ...). '
  'Alias retiré après migration des consommateurs.',
)
class AppartementsByOwnerLoaded extends AppartementLoaded {
  final int proprietaireId;

  AppartementsByOwnerLoaded(
    List<Appartement> appartements,
    this.proprietaireId,
  ) : super(
          appartements,
          source: AppartementListSource.byOwner,
          ownerId: proprietaireId,
        );
}

class AppartementError extends AppartementState {
  final String message;
  AppartementError(this.message, {super.appartements});
}
