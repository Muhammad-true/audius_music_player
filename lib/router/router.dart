import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/presentation/pages/account_page.dart';
import 'package:audius_music_player/presentation/pages/app/view/home_page.dart';
import 'package:audius_music_player/presentation/pages/app/view/splash_page.dart';
import 'package:audius_music_player/presentation/pages/favorites/view/favorites_page.dart';
import 'package:audius_music_player/presentation/pages/player/view/player_page.dart';
import 'package:audius_music_player/presentation/pages/search/view/search_page.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../presentation/pages/download/view/download_page.dart';

// Нужно подключить `part`, чтобы сгенерировались маршруты
part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey}); // можно передавать navigatorKey, если нужно

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: HomeRoute.page,
          path: '/',
          children: [
            AutoRoute(page: SearchRoute.page, path: 'search'),
            AutoRoute(page: FavoritesRoute.page, path: 'favorites'),
            AutoRoute(page: DownloadRoute.page, path: 'download'),
            AutoRoute(page: AccountRoute.page, path: 'account'),
          ],
        ),
        AutoRoute(page: PlayerRoute.page, path: '/player'),
      ];
}
