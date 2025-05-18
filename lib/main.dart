import 'package:audius_music_player/core/di/locator.dart';
import 'package:audius_music_player/my_app.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupLocator();
  runApp(const MyApp());
}
