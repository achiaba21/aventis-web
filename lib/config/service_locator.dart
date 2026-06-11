import 'package:get_it/get_it.dart';
import 'package:asfar/service/model/appartement/appartement_service.dart';
import 'package:asfar/service/model/booking/reservation_service.dart';
import 'package:asfar/service/model/favorite/favorite_service.dart';
import 'package:asfar/service/model/message/message_service.dart';
import 'package:asfar/service/repository/appartement_repository.dart';
import 'package:asfar/service/repository/charge_data_manager.dart';
import 'package:asfar/service/repository/charge_repository.dart';
import 'package:asfar/service/repository/compte_repository.dart';
import 'package:asfar/service/repository/reservation_repository.dart';

/// Service locator du projet (GetIt)
///
/// Migration progressive (PRA-04) : seuls les services/repositories des blocs
/// touchés par le chantier praticité/fluidité sont enregistrés ici. Tout
/// nouveau bloc reçoit ses dépendances via constructeur optionnel avec défaut
/// `getIt<X>()` — les mocks s'injectent en test sans GetIt.
final getIt = GetIt.instance;

void setupServiceLocator() {
  // Idempotent : utilisable dans les setUpAll de tests sans double
  // enregistrement.
  if (getIt.isRegistered<AppartementService>()) return;
  getIt.registerLazySingleton<AppartementService>(() => AppartementService());
  getIt.registerLazySingleton<ReservationService>(() => ReservationService());
  getIt.registerLazySingleton<FavoriteService>(() => FavoriteService());
  getIt.registerLazySingleton<MessageService>(() => MessageService());
  getIt.registerLazySingleton<AppartementRepository>(
      () => AppartementRepository());
  getIt.registerLazySingleton<ReservationRepository>(
      () => ReservationRepository());
  getIt.registerLazySingleton<ChargeRepository>(() => ChargeRepository());
  getIt.registerLazySingleton<CompteRepository>(() => CompteRepository());
  getIt.registerLazySingleton<ChargeDataManager>(() => ChargeDataManager());
}
