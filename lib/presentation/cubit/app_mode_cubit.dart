import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppModeCubit extends Cubit<AppModeState> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  AppModeCubit() : super(const AppModeState(isOnline: true)) {
    _checkInitialConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.isNotEmpty &&
          results.any((r) => r != ConnectivityResult.none);
      emit(state.copyWith(isOnline: online));
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final online =
        results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);
    emit(state.copyWith(isOnline: online));
  }

  void setOnline() => emit(state.copyWith(isOnline: true));
  void setOffline() => emit(state.copyWith(isOnline: false));

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class AppModeState extends Equatable {
  final bool isOnline;

  const AppModeState({required this.isOnline});

  @override
  List<Object> get props => [isOnline];

  AppModeState copyWith({bool? isOnline}) {
    return AppModeState(isOnline: isOnline ?? this.isOnline);
  }
}
