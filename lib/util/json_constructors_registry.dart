import 'package:asfar/model/document/document.dart';
import 'package:asfar/model/document/photo_appart.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/model/remise/condition.dart';
import 'package:asfar/model/remise/remise.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/response/favorite_appartements_response.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/service/dio/dio_request.dart';

/// Initialise tous les constructeurs JSON pour les modèles de l'application
/// Cette fonction doit être appelée au démarrage de l'application
void initializeJsonConstructors() {
  // Enregistrer le constructeur pour Appartement
  DioRequest.registerJsonConstructors<Appartement>(
    (json) => Appartement.fromJson(json),
    Appartement.fromJsonAll,
  );

  // Enregistrer le constructeur pour User avec support d'héritage
  DioRequest.registerJsonConstructors<User>(
    (json) => User.fromJson(json),
    User.fromJsonAll,
  );

  // Enregistrer le constructeur pour Remise
  DioRequest.registerJsonConstructors<Remise>(
    (json) => Remise.fromJson(json),
    Remise.fromJsonAll,
  );

  // Enregistrer le constructeur pour Condition
  DioRequest.registerJsonConstructors<Condition>(
    (json) => Condition.fromJson(json),
    Condition.fromJsonAll,
  );

  // Enregistrer le constructeur pour Document
  DioRequest.registerJsonConstructors<Document>(
    (json) => Document.fromJson(json),
    Document.fromJsonAll,
  );

  // Enregistrer le constructeur pour PhotoAppart
  DioRequest.registerJsonConstructors<PhotoAppart>(
    (json) => PhotoAppart.fromJson(json),
    PhotoAppart.fromJsonAll,
  );

  // Enregistrer le constructeur pour FavoriteAppartementsResponse
  DioRequest.registerJsonConstructors<FavoriteAppartementsResponse>(
    (json) => FavoriteAppartementsResponse.fromJson(json),
  );

  // Enregistrer le constructeur pour NotificationModel
  DioRequest.registerJsonConstructors<NotificationModel>(
    (json) => NotificationModel.fromJson(json),
  );

  // Ajouter d'autres modèles ici au fur et à mesure
  // DioRequest.registerJsonConstructors<Residence>(
  //   (json) => Residence.fromJson(json),
  //   // Residence.fromJsonAll si elle a des sous-classes
  // );
}