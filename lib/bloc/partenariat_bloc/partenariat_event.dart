abstract class PartenariatEvent {
  const PartenariatEvent();
}

class LoadDemandesEnvoyees extends PartenariatEvent {
  const LoadDemandesEnvoyees();
}

class EnvoyerDemande extends PartenariatEvent {
  final String telephone;
  const EnvoyerDemande(this.telephone);
}

class LoadDemandesRecues extends PartenariatEvent {
  const LoadDemandesRecues();
}

class AccepterDemande extends PartenariatEvent {
  final int id;
  const AccepterDemande(this.id);
}

class RefuserDemande extends PartenariatEvent {
  final int id;
  const RefuserDemande(this.id);
}

class ResetPartenariatState extends PartenariatEvent {
  const ResetPartenariatState();
}
