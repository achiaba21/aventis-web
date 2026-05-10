import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/service/storage/storage_service.dart';

/// Cubit V8.5 qui gère la **vue active** de l'utilisateur — différente du
/// **type de compte** (`user.type`).
///
/// Modèle métier : un utilisateur a UN type de compte permanent (locataire /
/// proprietaire / demarcheur). Mais un proprio ou un démarcheur peut aussi
/// vouloir séjourner ailleurs → il bascule en mode Locataire **temporairement**
/// sans changer son type de compte.
///
/// Cet état est persisté en Hive (`StorageService`) pour être restauré au
/// redémarrage de l'app. Si `null` ou non défini, on retombe sur `user.type`.
///
/// Usage :
/// - Lecture : `context.watch<ActiveShellCubit>().state` ou `BlocBuilder`
/// - Mutation : `context.read<ActiveShellCubit>().setView('demarcheur')`
/// - Reset : `context.read<ActiveShellCubit>().clear()` (au logout)
class ActiveShellCubit extends Cubit<String?> {
  ActiveShellCubit() : super(null) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final stored = StorageService.instance.getActiveView();
    if (stored != null && stored.isNotEmpty) {
      emit(stored);
    }
  }

  Future<void> setView(String viewId) async {
    final normalized = viewId.toLowerCase();
    if (state == normalized) return;
    emit(normalized);
    await StorageService.instance.saveActiveView(normalized);
  }

  Future<void> clear() async {
    emit(null);
    await StorageService.instance.saveActiveView(null);
  }
}
