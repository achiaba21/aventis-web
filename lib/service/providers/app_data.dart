
import 'package:flutter/material.dart';
import 'package:web_flutter/model/filter/filter_criteria.dart';
import 'package:web_flutter/model/filter/filter_options.dart';
import 'package:web_flutter/model/message/seance.dart';
import 'package:web_flutter/model/notification.dart';
import 'package:web_flutter/model/request/reservation_req.dart';
import 'package:web_flutter/model/reservation/reservation.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/model/user/client.dart';
import 'package:web_flutter/model/conversation/conversation.dart';
import 'package:web_flutter/util/extensions/conversation_extensions.dart';

class AppData extends ChangeNotifier {
  Client? client;
  ReservationReq? req;
  String get curency => "FCFA";
  Reservation? selectedReservation;
  List<int> favorites = [];
  List<Notification2> notifs =[];
  List<Seance> seance =[];
  FilterCriteria? currentFilterCriteria;
  FilterOptions? availableFilterOptions;

  @Deprecated('Use FavoriteBloc instead')
  void toggleFavorites(Appartement appart){
    final id =appart.id;
    if( id == null){
      return;
    }
    final inner = favorites.contains(id);
    if(inner){
      favorites.remove(id);
    }else{
      favorites.add(id);
    }
    notifyListeners();
  }

  /// Synchronise les favoris avec le FavoriteBloc
  void syncFavoritesFromBloc(List<int> newFavorites) {
    favorites = newFavorites;
    notifyListeners();
  }

  void setReservationReq(ReservationReq? reqs) {
    reqs?.cur ??= curency;
    req = reqs;

    notifyListeners();
  }

  void setClient(Client client) {
    this.client = client;
    notifyListeners();
  }

  void setSelectedReservation(Reservation? reservation) {
    selectedReservation = reservation;
    notifyListeners();
  }

  void setFilterCriteria(FilterCriteria? criteria) {
    currentFilterCriteria = criteria;
    notifyListeners();
  }

  void setFilterOptions(FilterOptions? options) {
    availableFilterOptions = options;
    notifyListeners();
  }

  /// Vérifie si les options de filtrage sont disponibles
  bool get hasFilterOptions => availableFilterOptions != null;

  /// Récupère les options par défaut en cas d'échec de chargement
  FilterOptions get defaultFilterOptions => FilterOptions(
    commodites: ["Air conditioning", "Wifi", "Kitchen", "TV", "Water heater", "Gym", "Pool"],
    preferences: ["Entire place", "Shared space", "Private room"],
    regles: ["Pets", "Smoking"],
    prixMin: 0.0,
    prixMax: 10000000.0,
  );

  void clearFilters() {
    currentFilterCriteria = null;
    notifyListeners();
  }

  bool get hasActiveFilters => currentFilterCriteria?.hasFilters ?? false;

  int get activeFiltersCount => currentFilterCriteria?.activeFiltersCount ?? 0;

  // === INTEGRATION CONVERSATIONBLOC ===

  /// Synchronise les conversations depuis ConversationBloc
  void syncConversationsFromBloc(List<Conversation> conversations) {
    seance = conversations.map((conv) => conv.toSeance()).toList();
    notifyListeners();
  }

  /// Met à jour une conversation spécifique
  void updateConversationFromBloc(Conversation conversation) {
    final index = seance.indexWhere((s) => s.proprietaire?.id == conversation.proprietaire?.id &&
                                          s.locataire?.id == conversation.locataire?.id);

    if (index != -1) {
      seance[index] = conversation.toSeance();
    } else {
      seance.add(conversation.toSeance());
    }
    notifyListeners();
  }

  /// Ajoute un nouveau message à une conversation
  void addMessageToConversation(int? conversationId, dynamic message) {
    // Logic pour ajouter un message à la conversation correspondante
    // Cette méthode sera appelée depuis les widgets pour maintenir la cohérence
    notifyListeners();
  }

  /// Récupère une conversation par ses participants
  Seance? getConversationByParticipants({required dynamic proprietaire, required dynamic locataire}) {
    return seance.firstWhere(
      (s) => (s.proprietaire?.id == proprietaire?.id && s.locataire?.id == locataire?.id) ||
             (s.proprietaire?.id == locataire?.id && s.locataire?.id == proprietaire?.id),
      orElse: () => Seance(), // Retourne une seance vide si pas trouvée
    );
  }
}
