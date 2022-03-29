import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:guess_waifu_game/business/waifu.dart';
import 'package:guess_waifu_game/config.dart';
import 'package:image/image.dart' as image;
import 'package:path/path.dart';

var validImageExtensions = ['.png', '.jpg', '.jpeg', '.bmp'];

const _blockIndices = [0, 1, 2, 3, 4, 5, 6, 7, 8];

// This stores the processed and encoded image buffer.
class _LoadWaifuResult {
  final Uint8List original;
  final Uint8List blurred;

  _LoadWaifuResult(this.original, this.blurred);
}

_LoadWaifuResult _loadWaifu(File file) {
  final encoder = image.PngEncoder();
  final random = Random();
  var bytes = file.readAsBytesSync();
  var original = image.decodeImage(bytes)!;
  var blurred = image.Image.from(original);
  image.gaussianBlur(blurred, min(original.width, original.height) ~/ 12);
  var blurredBlocks = List.from(_blockIndices);
  List<int> originalBlocks = [];
  for (var i = 0; i < revealedBlockCount; ++i) {
    var bi = random.nextInt(blurredBlocks.length);
    originalBlocks.add(blurredBlocks[bi]);
    blurredBlocks.removeAt(bi);
  }
  for (var i = 0; i < originalBlocks.length; ++i) {
    // Copy block from original image into blurred image
    var col = originalBlocks[i] % 3;
    var row = originalBlocks[i] ~/ 3;
    var w = original.width ~/ 3;
    var h = original.height ~/ 3;
    var x = col * w;
    var y = row * h;
    w = w >= original.width ? original.width - 1 : w;
    h = h >= original.height ? original.height - 1 : h;
    image.copyInto(blurred, original,
        dstX: x, dstY: y, srcX: x, srcY: y, srcW: w, srcH: h, blend: false);
  }
  return _LoadWaifuResult(
    Uint8List.fromList(encoder.encodeImage(original)),
    Uint8List.fromList(encoder.encodeImage(blurred)),
  );
}

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

  Future<Waifu> pickWaifu(BuildContext context) async {
    var index = _random.nextInt(_unpickedList.length);
    var picked = _unpickedList[index];
    _unpickedList.removeAt(index);
    _pickedList.add(picked);
    var result = await compute(_loadWaifu, picked);

    return Waifu(
      await _precached(MemoryImage(result.original), context),
      await _precached(MemoryImage(result.blurred), context),
    );
  }

  Future<ImageProvider> _precached(
      ImageProvider image, BuildContext context) async {
    await precacheImage(image, context);
    return image;
  }
}

var harem = Harem();
