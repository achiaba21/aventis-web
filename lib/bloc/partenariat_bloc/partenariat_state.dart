import 'package:asfar/model/partenariat/demande_partenariat.dart';

abstract class PartenariatState {
  const PartenariatState();
}

class PartenariatInitial extends PartenariatState {
  const PartenariatInitial();
}

class PartenariatLoading extends PartenariatState {
  const PartenariatLoading();
}

class DemandesEnvoyeesLoaded extends PartenariatState {
  final List<DemandePartenariat> demandes;
  const DemandesEnvoyeesLoaded(this.demandes);
}

class DemandesRecuesLoaded extends PartenariatState {
  final List<DemandePartenariat> demandes;
  const DemandesRecuesLoaded(this.demandes);
}

class DemandeEnvoyeeSuccess extends PartenariatState {
  const DemandeEnvoyeeSuccess();
}

class DemandeTraiteeSuccess extends PartenariatState {
  const DemandeTraiteeSuccess();
}

class PartenariatError extends PartenariatState {
  final String message;
  const PartenariatError(this.message);
}
