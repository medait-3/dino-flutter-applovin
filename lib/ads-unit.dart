import 'dart:io';

class Ads {
  static String get sdk {
    return "C7ouRxOmimEp4rSo_8nQTJzhz092ixQ3ow9OKrdD8q7RKGdok0TuriMVT584AK8OLMLHaAM8ghSWF6ZCg16xnT";
  }

  static String get banner_id {
    if (Platform.isAndroid) {
      return "1854404de1b527db";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewarded_id {
    if (Platform.isAndroid) {
      return "43bebac45b2d186c";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get mre_id {
    if (Platform.isAndroid) {
      return "bb4169ba633e2229";
      //} //else if (Platform.isIOS) {
      //return "ca-app-pub-3940256099942544/5135589807";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitial_id {
    if (Platform.isAndroid) {
      return "bcbeeab0f23097be";
      //} //else if (Platform.isIOS) {
      //return "ca-app-pub-3940256099942544/5135589807";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
