import 'package:audius_music_player/data/repositories/audius_repositor.dart';
import 'package:audius_music_player/data/repositories/dummy_audius_repository.dart';
import 'package:audius_music_player/data/repositories/hybrid_track_repository.dart';
import 'package:audius_music_player/data/repositories/i_track_repository.dart';
import 'package:audius_music_player/data/repositories/offline_repository.dart';
import 'package:audius_music_player/data/services/storage_service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);

  // 1. Sync-сервисы
  locator.registerLazySingleton<StorageService>(
      () => StorageService(sharedPreferences));

  locator.registerLazySingleton<OfflineRepository>(
    () => OfflineRepository(locator<StorageService>()),
  );

  // 2. Async: создаём AudiusRepository с обработкой ошибок
  try {
    final audiusRepo = await AudiusRepository.create();
    locator.registerSingleton<AudiusRepository>(audiusRepo);
  } catch (e) {
    locator.registerSingleton<AudiusRepository>(DummyAudiusRepository());
  }

  // 3. Регистрируем общий репозиторий после создания зависимостей
  locator.registerLazySingleton<ITrackRepository>(
    () => HybridTrackRepository(
      online: locator<AudiusRepository>(),
      offline: locator<OfflineRepository>(),
    ),
  );
}
