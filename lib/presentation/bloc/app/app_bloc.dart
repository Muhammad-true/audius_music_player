import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AppState> emit,
  ) async {
    emit(AppLoading());
    try {
      // Проверка авторизации
      emit(AppAuthenticated());
    } catch (e) {
      emit(AppUnauthenticated());
    }
  }
}
