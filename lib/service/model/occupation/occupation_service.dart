import 'package:asfar/model/occupation/occupation_period.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

/// Service pour récupérer les plages d'occupation des appartements
///
/// Ce service communique avec l'API backend pour récupérer les périodes
/// pendant lesquelles les appartements sont occupés (réservations confirmées).
///
/// RÈGLES:
/// - Retourne uniquement les réservations avec statut CONFIRMER
/// - Filtre par mois et année
/// - Gère les erreurs réseau gracieusement
class OccupationService {
  final DioRequest _dioRequest = DioRequest.instance;

  /// Récupère les périodes d'occupation pour un appartement donné
  ///
  /// Paramètres:
  /// - [appartementId] : ID de l'appartement
  /// - [month] : Mois (1-12)
  /// - [year] : Année (ex: 2026)
  ///
  /// Retourne une liste de [OccupationPeriod] pour le mois demandé.
  /// Retourne une liste vide en cas d'erreur ou si aucune occupation.
  Future<List<OccupationPeriod>> getOccupationPeriods({
    required int appartementId,
    required int month,
    required int year,
  }) async {
    try {
      deboger([
        '[OccupationService] Récupération occupation appart=$appartementId, mois=$month, année=$year'
      ]);

      // Validation des paramètres
      if (month < 1 || month > 12) {
        throw ArgumentError('Le mois doit être entre 1 et 12');
      }
      if (year < 2020) {
        throw ArgumentError('L\'année doit être >= 2020');
      }

      // Appel API
      final response = await _dioRequest.get(
        'occupation/$appartementId',
        queryParameters: {
          'month': month,
          'year': year,
        },
      );

      // Parsing de la réponse
      if (response.data == null) {
        deboger(['[OccupationService] Réponse vide']);
        return [];
      }

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final List<dynamic> periodsJson = data['periods'] ?? [];

      final periods = periodsJson
          .map((json) => OccupationPeriod.fromJson(json as Map<String, dynamic>))
          .toList();

      deboger([
        '[OccupationService] ${periods.length} période(s) d\'occupation récupérée(s)'
      ]);

      return periods;
    } catch (e) {
      ErrorHandler.logError("GET_OCCUPATION_PERIODS", e);
      deboger([
        '[OccupationService] Erreur: ${ErrorHandler.extractGenericErrorMessage(e)}'
      ]);

      // En cas d'erreur, retourner liste vide (fail gracefully)
      // L'UI affichera un calendrier vide
      return [];
    }
  }

  /// Récupère les périodes d'occupation pour plusieurs appartements
  ///
  /// Utile pour le mode résidence (affichage multi-appartements).
  /// Appelle [getOccupationPeriods] pour chaque appartement et agrège les résultats.
  ///
  /// Paramètres:
  /// - [appartementIds] : Liste des IDs d'appartements
  /// - [month] : Mois (1-12)
  /// - [year] : Année (ex: 2026)
  Future<List<OccupationPeriod>> getOccupationPeriodsForMultipleApartments({
    required List<int> appartementIds,
    required int month,
    required int year,
  }) async {
    try {
      deboger([
        '[OccupationService] Récupération occupation pour ${appartementIds.length} appartement(s)'
      ]);

      // Récupérer les périodes pour tous les appartements en parallèle
      final futures = appartementIds.map(
        (id) => getOccupationPeriods(
          appartementId: id,
          month: month,
          year: year,
        ),
      );
      final results = await Future.wait(futures);
      final allPeriods = results.expand((periods) => periods).toList();

      deboger([
        '[OccupationService] Total: ${allPeriods.length} période(s) pour tous les appartements'
      ]);

      return allPeriods;
    } catch (e) {
      ErrorHandler.logError("GET_OCCUPATION_MULTIPLE_APARTMENTS", e);
      return [];
    }
  }
}
