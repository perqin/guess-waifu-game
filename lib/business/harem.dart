import 'dart:io';
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:guess_waifu_game/business/waifu.dart';
import 'package:path/path.dart';

var validImageExtensions = ['.png', '.jpg', '.jpeg', '.bmp'];

class Harem {
  final List<File> _unpickedList = [];
  final List<File> _pickedList = [];
  final _random = Random();

  init() async {
    var list = await Directory('./waifu')
        .list()
        .takeWhile((entity) => entity is File)
        .map((entity) => entity as File)
        .takeWhile((f) => validImageExtensions.contains(extension(f.path)))
        .toList();
    _unpickedList.addAll(list);
  }

  Future<Waifu> pickWaifu() async {
    var index = _random.nextInt(_unpickedList.length);
    var picked = _unpickedList[index];
    _unpickedList.removeAt(index);
    _pickedList.add(picked);
    var original = FileImage(picked);
    // Not implemented: generate blur image
    return Waifu(original, []);
  }
}

var harem = Harem();
