import 'dart:ui';
import 'package:applovin_max/applovin_max.dart';

import 'package:flutter/material.dart';
import 'dart:math' as m;

import 'package:provider/provider.dart';
import '../ads-unit.dart';
import '../main.dart';
import '../manager/audio_manager.dart';
import '../manager/game_manager.dart';

import '../models/setting_model.dart';
import 'main_menu.dart';

class SettingsMenu extends StatefulWidget {
  static const id = 'SettingsMenu';

  final GameManager gameRef;

  const SettingsMenu(this.gameRef, {Key? key}) : super(key: key);

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

const String _sdkKey =
    "C7ouRxOmimEp4rSo_8nQTJzhz092ixQ3ow9OKrdD8q7RKGdok0TuriMVT584AK8OLMLHaAM8ghSWF6ZCg16xnT";

var _isInitialized = false;
var _interstitialLoadState = AdLoadState.notLoaded;
var _interstitialRetryAttempt = 0;
var _rewardedAdLoadState = AdLoadState.notLoaded;
var _rewardedAdRetryAttempt = 0;

class _SettingsMenuState extends State<SettingsMenu> {
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
      value: widget.gameRef.setting,
      child: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.black.withAlpha(100),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 35,
                        color: Colors.white,
                      ),
                    ),
                    Selector<SettingModel, bool>(
                      selector: (_, settings) => settings.bgm,
                      builder: (context, bgm, __) {
                        return SwitchListTile(
                          title: const Text(
                            'Sounds',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                          value: bgm,
                          onChanged: (bool value) {
                            Provider.of<SettingModel>(context, listen: false)
                                .bgm = value;
                            if (value) {
                              AudioManager.instance.startBgm();
                            } else {
                              AudioManager.instance.stopBgm();
                            }
                          },
                        );
                      },
                    ),
                    Selector<SettingModel, bool>(
                      selector: (_, settings) => settings.sfx,
                      builder: (context, sfx, __) {
                        return SwitchListTile(
                          title: const Text(
                            'Effects',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                          value: sfx,
                          onChanged: (bool value) {
                            Provider.of<SettingModel>(context, listen: false)
                                .sfx = value;
                          },
                        );
                      },
                    ),
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
                        widget.gameRef.overlays.remove(SettingsMenu.id);
                        widget.gameRef.overlays.add(MainMenu.id);
                      },
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
