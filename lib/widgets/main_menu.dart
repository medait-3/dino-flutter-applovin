import 'dart:ui';

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'dart:math' as m;

import '../ads-unit.dart';
import '../main.dart';
import '../manager/game_manager.dart';
import 'hud.dart';
import 'settings_menu.dart';

class MainMenu extends StatefulWidget {
  static const id = 'MainMenu';

  final GameManager gameRef;

  const MainMenu(this.gameRef, {Key? key}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

const String _sdkKey =
    "C7ouRxOmimEp4rSo_8nQTJzhz092ixQ3ow9OKrdD8q7RKGdok0TuriMVT584AK8OLMLHaAM8ghSWF6ZCg16xnT";

var _isInitialized = false;
var _interstitialLoadState = AdLoadState.notLoaded;
var _interstitialRetryAttempt = 0;
var _rewardedAdLoadState = AdLoadState.notLoaded;
var _rewardedAdRetryAttempt = 0;

class _MainMenuState extends State<MainMenu> {
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
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.black.withAlpha(100),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
              child: Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  const Text(
                    'T-rex',
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      widget.gameRef.startGamePlay();
                      widget.gameRef.overlays.remove(MainMenu.id);
                      widget.gameRef.overlays.add(Hud.id);
                    },
                    child: const Text(
                      'Play',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      bool isReady = (await AppLovinMAX.isInterstitialReady(
                          Ads.interstitial_id))!;
                      if (isReady) {
                        AppLovinMAX.showInterstitial(Ads.interstitial_id);
                      } else {
                        _interstitialLoadState = AdLoadState.loading;
                        AppLovinMAX.loadInterstitial(Ads.interstitial_id);
                      }
                      widget.gameRef.overlays.remove(MainMenu.id);
                      widget.gameRef.overlays.add(SettingsMenu.id);
                    },
                    child: const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
