// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:audius_music_player/data/repositories/jamendoRepositor.dart';
import 'package:audius_music_player/data/services/storage_service.dart';
import 'package:audius_music_player/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await dotenv.load();
  String clientId = dotenv.env['CLIENT_ID'] ?? '';
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final storageService = StorageService(sharedPreferences);
    final repository = JamendoRepository();
    final audioPlayer = AudioPlayer();

    await repository.initialize(clientId);

    await tester.pumpWidget(MyApp(
      storageService: storageService,
      repository: repository,
      audioPlayer: audioPlayer,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
