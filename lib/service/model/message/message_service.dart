import 'package:asfar/model/message/message.dart';
import 'package:asfar/model/message/seance.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/function.dart';

/// Service pour gérer les messages et les séances de discussion
/// Conforme à l'API backend documentée
class MessageService {
  static const String baseUrl = "api/user/messages";

  /// 1. Créer une séance de discussion
  /// POST /user/messages/seances
  Future<Seance> createSeance({
    required int proprietaireId,
    required int locataireId,
    String? reservationReference,
  }) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.post(
        "$baseUrl/seances",
        data: {
          'proprietaireId': proprietaireId,
          'locataireId': locataireId,
          if (reservationReference != null)
            'reservationReference': reservationReference,
        },
      );

      // Parser la réponse
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        // L'API renvoie 'body' au lieu de 'data' pour cette route
        final data = responseData['body'] ?? responseData['data'];

        if (data != null && data['seance'] != null) {
          return Seance.fromJson(data['seance']);
        }
      }

      throw Exception('Format de réponse invalide');
    } catch (e) {
      deboger(['Erreur création séance:', e]);
      rethrow;
    }
  }

  /// 2. Lister mes séances
  /// GET /user/messages/seances
  Future<List<Seance>> getSeances() async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.get("$baseUrl/seances");

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['body'] ?? responseData['data'];

        // Cas 1: data est directement une liste
        if (data is List) {
          return data.map((item) => Seance.fromJson(item)).toList();
        }

        // Cas 2: data est une Map contenant la liste (ex: { "seances": [...] })
        if (data is Map<String, dynamic>) {
          final list = data['seances'] ?? data['data'] ?? data['list'];
          if (list is List) {
            return list.map((item) => Seance.fromJson(item)).toList();
          }
        }
      }

      // Fallback: si data est directement une liste
      if (response.data is List) {
        return (response.data as List)
            .map((item) => Seance.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      deboger(['Erreur récupération séances:', e]);
      rethrow;
    }
  }

  /// 3. Récupérer une séance spécifique
  /// GET /user/messages/seances/{id}
  Future<Seance> getSeance(int seanceId) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.get("$baseUrl/seances/$seanceId");

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['body'] ?? responseData['data'];
        if (data != null) {
          return Seance.fromJson(data);
        }
      }

      throw Exception('Format de réponse invalide');
    } catch (e) {
      deboger(['Erreur récupération séance:', e]);
      rethrow;
    }
  }

  /// 4. Envoyer un message
  /// POST /user/messages
  Future<Message> sendMessage({
    required int seanceId,
    required String contenu,
  }) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.post(
        baseUrl,
        data: {'seanceId': seanceId, 'contenu': contenu},
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['body'] ?? responseData['data'];
        final messageData = data != null ? (data['message'] ?? data) : null;

        if (messageData != null) {
          return Message.fromJson(messageData);
        }
      }

      throw Exception('Format de réponse invalide');
    } catch (e) {
      deboger(['Erreur envoi message:', e]);
      rethrow;
    }
  }

  /// 5. Récupérer l'historique des messages
  /// GET /user/messages/seances/{seanceId}/messages
  Future<List<Message>> getMessages(int seanceId) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.get("$baseUrl/seances/$seanceId/messages");

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['body'] ?? responseData['data'];

        // Cas 1: data est directement une liste
        if (data is List) {
          return data.map((item) => Message.fromJson(item)).toList();
        }

        // Cas 2: data est une Map contenant la liste (ex: { "messages": [...] })
        if (data is Map<String, dynamic>) {
          final list = data['messages'] ?? data['data'] ?? data['list'];
          if (list is List) {
            return list.map((item) => Message.fromJson(item)).toList();
          }
        }
      }

      // Fallback: si data est directement une liste
      if (response.data is List) {
        return (response.data as List)
            .map((item) => Message.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      deboger(['Erreur récupération messages:', e]);
      rethrow;
    }
  }

  /// 6. Marquer les messages comme lus
  /// POST /user/messages/seances/{seanceId}/mark-read
  Future<void> markAsRead(int seanceId) async {
    try {
      final dio = DioRequest.instance;
      await dio.post("$baseUrl/seances/$seanceId/mark-read");
      deboger(['Messages marqués comme lus pour séance:', seanceId]);
    } catch (e) {
      deboger(['Erreur marquage messages lus:', e]);
      rethrow;
    }
  }

  /// 7. Compter les messages non lus
  /// GET /user/messages/unread-count
  Future<int> getUnreadCount() async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.get("$baseUrl/unread-count");

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['body'] ?? responseData['data'];
        if (data != null && data['count'] != null) {
          return data['count'] as int;
        }
      }

      return 0;
    } catch (e) {
      deboger(['Erreur comptage messages non lus:', e]);
      rethrow;
    }
  }

  /// 8. Trouver une séance existante par participants (Local Filter)
  Future<Seance?> findSeanceByParticipants(int otherUserId) async {
    try {
      // Récupérer toutes les séances
      final seances = await getSeances();

      // Chercher une séance où l'autre participant correspond
      try {
        return seances.firstWhere((s) {
          return s.proprietaireId == otherUserId ||
              s.locataireId == otherUserId;
        });
      } catch (e) {
        // Pas trouvé (firstWhere lance une erreur si aucun élément ne correspond)
        return null;
      }
    } catch (e) {
      deboger(['Erreur recherche séance par participants:', e]);
      return null;
    }
  }
}
