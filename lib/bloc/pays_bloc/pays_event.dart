/// Classe abstraite représentant tous les événements du PaysBloc
abstract class PaysEvent {}

/// Événement pour charger tous les pays
class LoadAllPays extends PaysEvent {}

/// Événement pour charger un pays par son ID
class LoadPaysById extends PaysEvent {
  final int id;
  LoadPaysById(this.id);
}

/// Événement pour charger un pays par son code
class LoadPaysByCode extends PaysEvent {
  final String code;
  LoadPaysByCode(this.code);
}

/// Événement pour réinitialiser l'état
class ResetPays extends PaysEvent {}
