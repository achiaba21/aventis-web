abstract class ProprietaireDemarcheurEvent {}

class LoadDemarcheurs extends ProprietaireDemarcheurEvent {}

class LinkDemarcheur extends ProprietaireDemarcheurEvent {
  final String telephone;

  LinkDemarcheur(this.telephone);
}

class UnlinkDemarcheur extends ProprietaireDemarcheurEvent {
  final int id;

  UnlinkDemarcheur(this.id);
}
