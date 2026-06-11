import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/config/service_locator.dart';
import 'package:asfar/bloc/compte_bloc/compte_event.dart';
import 'package:asfar/bloc/compte_bloc/compte_state.dart';
import 'package:asfar/service/repository/compte_repository.dart';
import 'package:asfar/util/function.dart';

/// BLoC pour la gestion du compte propriétaire
class CompteBloc extends Bloc<CompteEvent, CompteState> {
  final CompteRepository _repository;

  CompteBloc({CompteRepository? repository})
      : _repository = repository ?? getIt<CompteRepository>(),
        super(CompteInitial()) {
    on<LoadCompte>(_onLoadCompte);
    on<RefreshCompte>(_onRefreshCompte);
    on<LoadTransactions>(_onLoadTransactions);
    on<DemanderRetrait>(_onDemanderRetrait);
    on<LoadDemandesRetrait>(_onLoadDemandesRetrait);
    on<ResetCompteState>(_onResetCompteState);
  }

  /// Charge le compte et les transactions récentes
  Future<void> _onLoadCompte(
    LoadCompte event,
    Emitter<CompteState> emit,
  ) async {
    emit(CompteLoading());

    try {
      // Charger le compte
      final compte = await _repository.getCompte();

      // Charger les 5 dernières transactions
      final transactions = await _repository.getTransactions(limit: 5);

      // Charger les demandes de retrait
      final demandesRetrait = await _repository.getDemandesRetrait();

      emit(CompteLoaded(
        compte: compte,
        transactions: transactions,
        demandesRetrait: demandesRetrait,
      ));

      deboger(['[CompteBloc] Compte chargé: ${compte.numero}']);
    } catch (e) {
      deboger(['[CompteBloc] Erreur LoadCompte: $e']);
      emit(CompteError(message: 'Erreur lors du chargement du compte: $e'));
    }
  }

  /// Rafraîchit les données du compte
  Future<void> _onRefreshCompte(
    RefreshCompte event,
    Emitter<CompteState> emit,
  ) async {
    add(LoadCompte());
  }

  /// Charge les transactions avec filtres
  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<CompteState> emit,
  ) async {
    if (state is! CompteLoaded) return;

    final currentState = state as CompteLoaded;

    try {
      final transactions = await _repository.getTransactions(
        dateDebut: event.dateDebut,
        dateFin: event.dateFin,
        limit: event.limit,
        offset: event.offset,
      );

      emit(currentState.copyWith(transactions: transactions));

      deboger(['[CompteBloc] Transactions chargées: ${transactions.length}']);
    } catch (e) {
      deboger(['[CompteBloc] Erreur LoadTransactions: $e']);
      emit(CompteError(message: 'Erreur lors du chargement des transactions: $e'));
    }
  }

  /// Demande un retrait
  Future<void> _onDemanderRetrait(
    DemanderRetrait event,
    Emitter<CompteState> emit,
  ) async {
    if (state is! CompteLoaded) return;

    final currentState = state as CompteLoaded;

    // Validation du solde
    final soldeDisponible = currentState.compte.solde ?? 0;
    if (event.montant > soldeDisponible) {
      emit(CompteError(message: 'Solde insuffisant'));
      emit(currentState); // Restaurer l'état précédent
      return;
    }

    // Validation du montant positif
    if (event.montant <= 0) {
      emit(CompteError(message: 'Le montant doit être supérieur à 0'));
      emit(currentState);
      return;
    }

    // Vérification compte actif
    if (currentState.compte.actif == false) {
      emit(CompteError(message: 'Votre compte est suspendu'));
      emit(currentState);
      return;
    }

    emit(CompteLoading());

    try {
      final demande = await _repository.createDemandeRetrait(event.montant);

      deboger(['[CompteBloc] Demande de retrait créée: ${demande.id}']);

      emit(RetraitSuccess(
        demande: demande,
        previousState: currentState,
      ));

      // Rafraîchir le compte pour avoir le nouveau solde
      add(RefreshCompte());
    } catch (e) {
      deboger(['[CompteBloc] Erreur DemanderRetrait: $e']);
      emit(CompteError(message: 'Erreur lors de la demande de retrait: $e'));
      emit(currentState);
    }
  }

  /// Charge les demandes de retrait
  Future<void> _onLoadDemandesRetrait(
    LoadDemandesRetrait event,
    Emitter<CompteState> emit,
  ) async {
    if (state is! CompteLoaded) return;

    final currentState = state as CompteLoaded;

    try {
      final demandesRetrait = await _repository.getDemandesRetrait();

      emit(currentState.copyWith(demandesRetrait: demandesRetrait));

      deboger(['[CompteBloc] Demandes retrait chargées: ${demandesRetrait.length}']);
    } catch (e) {
      deboger(['[CompteBloc] Erreur LoadDemandesRetrait: $e']);
    }
  }

  /// Réinitialise l'état (déconnexion)
  void _onResetCompteState(
    ResetCompteState event,
    Emitter<CompteState> emit,
  ) {
    deboger(['[CompteBloc] Réinitialisation à l\'état Initial']);
    emit(CompteInitial());
  }
}
