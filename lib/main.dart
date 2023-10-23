import 'package:applovin_max/applovin_max.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'ads-unit.dart';
import 'manager/game_manager.dart';
import 'models/models.dart';
import 'widgets/menu.dart';

GameManager _game = GameManager();

enum AdLoadState { notLoaded, loading, loaded }

bool isInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map? sdkConfiguration = await AppLovinMAX.initialize(Ads.sdk);
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  await initHive();

  runApp(const App());
}

Future<void> initHive() async {
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.registerAdapter<PlayerModel>(PlayerModelAdapter());
  Hive.registerAdapter<SettingModel>(SettingModelAdapter());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'T-rex',
      theme: ThemeData(
        fontFamily: 'AudioWide',
        primaryColor: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: GameWidget(
          loadingBuilder: (_) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          },
          overlayBuilderMap: {
            MainMenu.id: (_, GameManager gameRef) => MainMenu(gameRef),
            Hud.id: (_, GameManager gameRef) => Hud(gameRef),
            SettingsMenu.id: (_, GameManager gameRef) => SettingsMenu(gameRef),
            GameOverMenu.id: (_, GameManager gameRef) => GameOverMenu(gameRef),
            PauseMenu.id: (_, GameManager gameRef) => PauseMenu(gameRef),
          },
          initialActiveOverlays: const [MainMenu.id],
          game: _game,
        ),
      ),
    );
  }
}
