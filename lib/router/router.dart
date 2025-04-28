import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/presentation/pages/favorites_page.dart';
import 'package:audius_music_player/presentation/pages/player_page.dart';
import 'package:audius_music_player/presentation/pages/search_page.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// Нужно подключить `part`, чтобы сгенерировались маршруты
part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey}); // можно передавать navigatorKey, если нужно

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SearchRoute.page, initial: true),
        AutoRoute(page: PlayerRoute.page),
        AutoRoute(page: FavoritesRoute.page)
      ];
}
