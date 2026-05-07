import 'package:asfar/model/request/demarcheur_reservation_req.dart';

abstract class DemarcheurEvent {}

class LoadDemarcheurAppartements extends DemarcheurEvent {}

class LoadDemarcheurReservations extends DemarcheurEvent {}

class CreateDemarcheurReservation extends DemarcheurEvent {
  final DemarcheurReservationReq req;

  CreateDemarcheurReservation(this.req);
}
