import 'package:asfar/model/compte/compte_proprietaire.dart';
import 'package:asfar/model/compte/demande_retrait.dart';
import 'package:asfar/model/compte/transaction.dart';

abstract class CompteState {}

/// État initial (pas encore chargé)
class CompteInitial extends CompteState {}

/// État de chargement
class CompteLoading extends CompteState {}

/// État chargé avec toutes les données
class CompteLoaded extends CompteState {
  final CompteProprietaire compte;
  final List<Transaction> transactions;
  final List<DemandeRetrait> demandesRetrait;

  CompteLoaded({
    required this.compte,
    this.transactions = const [],
    this.demandesRetrait = const [],
  });

  /// Crée une copie avec des valeurs modifiées
  CompteLoaded copyWith({
    CompteProprietaire? compte,
    List<Transaction>? transactions,
    List<DemandeRetrait>? demandesRetrait,
  }) {
    return CompteLoaded(
      compte: compte ?? this.compte,
      transactions: transactions ?? this.transactions,
      demandesRetrait: demandesRetrait ?? this.demandesRetrait,
    );
  }
}

/// État d'erreur
class CompteError extends CompteState {
  final String message;

  CompteError({required this.message});
}

/// État après une demande de retrait réussie
class RetraitSuccess extends CompteState {
  final DemandeRetrait demande;
  final CompteLoaded previousState;

  RetraitSuccess({
    required this.demande,
    required this.previousState,
  });
}
