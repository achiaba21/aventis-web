import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/pays_bloc/pays_event.dart';
import 'package:asfar/bloc/pays_bloc/pays_state.dart';
import 'package:asfar/service/model/localite/pays_service.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

/// BLoC pour gérer l'état des pays
class PaysBloc extends Bloc<PaysEvent, PaysState> {
  final PaysService _paysService;

  PaysBloc({PaysService? paysService})
      : _paysService = paysService ?? PaysService(),
        super(PaysInitial()) {

    // Charger tous les pays
    on<LoadAllPays>((event, emit) async {
      emit(PaysLoading());
      try {
        deboger(["PaysBloc - Loading all pays..."]);
        final paysList = await _paysService.getAllPays();
        deboger(["PaysBloc - Loaded ${paysList.length} pays"]);
        emit(AllPaysLoaded(paysList));
      } catch (e) {
        ErrorHandler.logError("LOAD_ALL_PAYS", e);
        final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
        emit(PaysError(errorMessage));
      }
    });

    // Charger un pays par ID
    on<LoadPaysById>((event, emit) async {
      emit(PaysLoading());
      try {
        deboger(["PaysBloc - Loading pays with id: ${event.id}"]);
        final pays = await _paysService.getPaysById(event.id);
        if (pays != null) {
          deboger(["PaysBloc - Loaded pays: ${pays.nom}"]);
          emit(SinglePaysLoaded(pays));
        } else {
          emit(PaysError("Pays non trouvé"));
        }
      } catch (e) {
        ErrorHandler.logError("LOAD_PAYS_BY_ID", e);
        final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
        emit(PaysError(errorMessage));
      }
    });

    // Charger un pays par code
    on<LoadPaysByCode>((event, emit) async {
      emit(PaysLoading());
      try {
        deboger(["PaysBloc - Loading pays with code: ${event.code}"]);
        final pays = await _paysService.getPaysByCode(event.code);
        if (pays != null) {
          deboger(["PaysBloc - Loaded pays: ${pays.nom}"]);
          emit(SinglePaysLoaded(pays));
        } else {
          emit(PaysError("Pays non trouvé"));
        }
      } catch (e) {
        ErrorHandler.logError("LOAD_PAYS_BY_CODE", e);
        final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
        emit(PaysError(errorMessage));
      }
    });

    // Réinitialiser l'état
    on<ResetPays>((event, emit) {
      emit(PaysInitial());
    });
  }
}
