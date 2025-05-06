// lib/presentation/pages/main_scaffold.dart
import 'package:audius_music_player/presentation/bloc/player/player_bloc.dart';
import 'package:audius_music_player/presentation/pages/player/view/mini_player.dart';
import 'package:audius_music_player/router/router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AutoTabsScaffold(
          routes: const [
            SearchRoute(),
            FavoritesRoute(),
          ],
          bottomNavigationBuilder: (_, tabsRouter) {
            return BottomNavigationBar(
              currentIndex: tabsRouter.activeIndex,
              onTap: tabsRouter.setActiveIndex,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search), label: 'Search'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite), label: 'Favorites'),
              ],
            );
          },
        ),
        BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, state) {
            final currentRoute = AutoRouter.of(context).current.name;
            final isPlayerPage = currentRoute == PlayerRoute.name;

            if (isPlayerPage || state is PlayerInitial) {
              return const SizedBox.shrink();
            }

            return Positioned(
              left: 0,
              right: 0,
              bottom: kBottomNavigationBarHeight,
              child: MiniPlayer(
                onClose: () => {},
              ),
            );
          },
        ),
      ],
    );
  }
}
