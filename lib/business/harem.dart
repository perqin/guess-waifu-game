import 'package:flutter/painting.dart';
import 'package:guess_waifu_game/business/waifu.dart';

class Harem {
  init() async {
    // Not implemented: Load a full list of waifu
    throw Error();
  }

  Future<Waifu> pickWaifu() async {
    // Not implemented: Load image into waifu
    return Waifu(
      const NetworkImage('https://perqin.github.io/img/favicon.png'),
      [],
    );
  }
}

var harem = Harem();
