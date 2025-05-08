// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [AccountPage]
class AccountRoute extends PageRouteInfo<void> {
  const AccountRoute({List<PageRouteInfo>? children})
      : super(
          AccountRoute.name,
          initialChildren: children,
        );

  static const String name = 'AccountRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AccountPage();
    },
  );
}

/// generated route for
/// [DownloadPage]
class DownloadRoute extends PageRouteInfo<void> {
  const DownloadRoute({List<PageRouteInfo>? children})
      : super(
          DownloadRoute.name,
          initialChildren: children,
        );

  static const String name = 'DownloadRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return DownloadPage();
    },
  );
}

/// generated route for
/// [FavoritesPage]
class FavoritesRoute extends PageRouteInfo<void> {
  const FavoritesRoute({List<PageRouteInfo>? children})
      : super(
          FavoritesRoute.name,
          initialChildren: children,
        );

  static const String name = 'FavoritesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FavoritesPage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [PlayerPage]
class PlayerRoute extends PageRouteInfo<PlayerRouteArgs> {
  PlayerRoute({
    Key? key,
    required TrackModel track,
    required List<TrackModel> tracks,
    List<PageRouteInfo>? children,
  }) : super(
          PlayerRoute.name,
          args: PlayerRouteArgs(
            key: key,
            track: track,
            tracks: tracks,
          ),
          initialChildren: children,
        );

  static const String name = 'PlayerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PlayerRouteArgs>();
      return PlayerPage(
        key: args.key,
        track: args.track,
        tracks: args.tracks,
      );
    },
  );
}

class PlayerRouteArgs {
  const PlayerRouteArgs({
    this.key,
    required this.track,
    required this.tracks,
  });

  final Key? key;

  final TrackModel track;

  final List<TrackModel> tracks;

  @override
  String toString() {
    return 'PlayerRouteArgs{key: $key, track: $track, tracks: $tracks}';
  }
}

/// generated route for
/// [SearchPage]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SearchPage();
    },
  );
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashPage();
    },
  );
}
