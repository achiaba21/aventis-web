import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Adapter HTTP de test qui COMPTE les requêtes et les fait échouer (PRA-05).
///
/// Branché via `DioRequest.instance.httpClientAdapterForTesting`, il permet
/// de prouver qu'un chemin de code (ex : cache frais) ne déclenche AUCUNE
/// requête réseau : toute requête incrémente [callCount] et lève.
class CountingHttpClientAdapter implements HttpClientAdapter {
  /// Nombre de requêtes reçues par l'adapter depuis sa création.
  int callCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    throw StateError(
      'Appel HTTP inattendu en test: ${options.method} ${options.uri}',
    );
  }

  @override
  void close({bool force = false}) {}
}
