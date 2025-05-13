import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppModeCubit extends Cubit<AppModeState> {
  AppModeCubit() : super(const AppModeState(isOnline: true)) {
    _checkConnectivity();
  }

  // Метод для проверки состояния подключения
  Future<void> _checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      emit(state.copyWith(isOnline: false)); // Оффлайн
    } else {
      emit(state.copyWith(isOnline: true)); // Онлайн
    }
  }

  // Изменить режим на онлайн
  void setOnline() => emit(state.copyWith(isOnline: true));

  // Изменить режим на оффлайн
  void setOffline() => emit(state.copyWith(isOnline: false));
}

// Состояние кубита
class AppModeState extends Equatable {
  final bool isOnline;

  const AppModeState({required this.isOnline});

  @override
  List<Object> get props => [isOnline];

  // Копирование с изменением значения
  AppModeState copyWith({bool? isOnline}) {
    return AppModeState(isOnline: isOnline ?? this.isOnline);
  }
}
