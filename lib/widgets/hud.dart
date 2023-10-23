import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ads-unit.dart';
import '../main.dart';
import 'dart:math' as m;

import '../manager/audio_manager.dart';
import '../manager/game_manager.dart';
import '../models/player_model.dart';
import 'pause_menu.dart';

class Hud extends StatefulWidget {
  static const id = 'Hud';

  final GameManager gameRef;

  const Hud(this.gameRef, {Key? key}) : super(key: key);

  @override
  State<Hud> createState() => _HudState();
}

const String _sdkKey =
    "C7ouRxOmimEp4rSo_8nQTJzhz092ixQ3ow9OKrdD8q7RKGdok0TuriMVT584AK8OLMLHaAM8ghSWF6ZCg16xnT";

var _isInitialized = false;
var _interstitialLoadState = AdLoadState.notLoaded;
var _interstitialRetryAttempt = 0;
var _rewardedAdLoadState = AdLoadState.notLoaded;
var _rewardedAdRetryAttempt = 0;

class _HudState extends State<Hud> {
  //   // start ads----------------/
  @override
  void initState() {
    super.initState();
    initializePlugin();
  }

  Future<void> initializePlugin() async {
    Map? configuration = await AppLovinMAX.initialize(Ads.sdk);
    if (configuration != null) {
      _isInitialized = true;
      attachAdListeners();
    }
  }

  void attachAdListeners() {
    /// Interstitial Ad Listeners
    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        _interstitialLoadState = AdLoadState.loaded;
        _interstitialRetryAttempt = 0;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        _interstitialLoadState = AdLoadState.notLoaded;
        _interstitialRetryAttempt = _interstitialRetryAttempt + 1;
        int retryDelay = m.pow(1, m.min(6, _interstitialRetryAttempt)).toInt();
        Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
          AppLovinMAX.loadInterstitial(Ads.interstitial_id);
        });
      },
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) {
        _interstitialLoadState = AdLoadState.notLoaded;
      },
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) {
        _interstitialLoadState = AdLoadState.notLoaded;
      },
      onAdRevenuePaidCallback: (ad) {},
    ));

    /// Rewarded Ad Listeners
    AppLovinMAX.setRewardedAdListener(RewardedAdListener(
        onAdLoadedCallback: (ad) {
          _rewardedAdLoadState = AdLoadState.loaded;
          _rewardedAdRetryAttempt = 0;
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          _rewardedAdLoadState = AdLoadState.notLoaded;

          // Rewarded ad failed to load
          // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
          _rewardedAdRetryAttempt = _rewardedAdRetryAttempt + 1;
          int retryDelay = m.pow(2, m.min(6, _rewardedAdRetryAttempt)).toInt();
          Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
            AppLovinMAX.loadRewardedAd(Ads.rewarded_id);
          });
        },
        onAdDisplayedCallback: (ad) {},
        onAdDisplayFailedCallback: (ad, error) {
          _rewardedAdLoadState = AdLoadState.notLoaded;
        },
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {
          _rewardedAdLoadState = AdLoadState.notLoaded;
        },
        onAdReceivedRewardCallback: (ad, reward) {},
        onAdRevenuePaidCallback: (ad) {}));
  }

  String getInterstitialButtonTitle() {
    if (_interstitialLoadState == AdLoadState.notLoaded) {
      return "Load Interstitial";
    } else if (_interstitialLoadState == AdLoadState.loading) {
      return "Loading...";
    } else {
      return "Show Interstitial"; // adLoadState.loaded
    }
  }

  String getRewardedButtonTitle() {
    if (_rewardedAdLoadState == AdLoadState.notLoaded) {
      return "Load Rewarded Ad";
    } else if (_rewardedAdLoadState == AdLoadState.loading) {
      return "Loading...";
    } else {
      return "Show Rewarded Ad"; // adLoadState.loaded
    }
  }
// // end ads -------------------/

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.gameRef.player,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () async {
                bool isReady = (await AppLovinMAX.isInterstitialReady(
                    Ads.interstitial_id))!;
                if (isReady) {
                  AppLovinMAX.showInterstitial(Ads.interstitial_id);
                } else {
                  _interstitialLoadState = AdLoadState.loading;
                  AppLovinMAX.loadInterstitial(Ads.interstitial_id);
                }
                widget.gameRef.overlays.remove(Hud.id);
                widget.gameRef.overlays.add(PauseMenu.id);
                widget.gameRef.pauseEngine();
                AudioManager.instance.pauseBgm();
              },
              child: const Icon(Icons.pause, color: Colors.white),
            ),
            Column(
              children: [
                Selector<PlayerModel, int>(
                  selector: (_, playerData) => playerData.currentScore,
                  builder: (_, score, __) {
                    return Text(
                      'Score: $score',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    );
                  },
                ),
                Selector<PlayerModel, int>(
                  selector: (_, playerData) => playerData.highScore,
                  builder: (_, highScore, __) {
                    return Text(
                      'High: $highScore',
                      style: const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ],
            ),
            Selector<PlayerModel, int>(
              selector: (_, playerData) => playerData.lives,
              builder: (_, lives, __) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: List.generate(
                      5,
                      (index) {
                        if (index < lives) {
                          return const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          );
                        } else {
                          return const Icon(
                            Icons.favorite_border,
                            color: Colors.red,
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
