import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:guess_waifu_game/business/waifu.dart';
import 'package:image/image.dart' as image;
import 'package:path/path.dart';

var validImageExtensions = ['.png', '.jpg', '.jpeg', '.bmp', '.PNG', '.JPG', '.JPEG', '.BMP'];

const blurredBlockCount = 5;
const _blockPatterns = [
  // Top-left revealed
  [2, 5, 6, 7, 8, 0, 1, 3, 4],
  // Top-right revealed
  [0, 3, 6, 7, 8, 1, 2, 4, 5],
  // Bottom-left revealed
  [0, 1, 2, 5, 8, 3, 4, 6, 7],
  // Bottom-right revealed
  [0, 1, 2, 3, 6, 4, 5, 7, 8],
];

// This stores the processed and encoded image buffer.
class _LoadWaifuResult {
  final Uint8List original;
  final Uint8List blurred;

  _LoadWaifuResult(this.original, this.blurred);
}

_LoadWaifuResult _loadWaifu(File file) {
  print('Working on file: ' + file.toString());
  final encoder = image.PngEncoder();
  final random = Random();
  var bytes = file.readAsBytesSync();
  var original = image.decodeImage(bytes)!;
  if (original.height > 1080) {
    original = image.copyResize(original, height: 1080);
  }
  var blurred = image.Image(original.width, original.height);
  // Decide blocks
  var blocks = _blockPatterns[random.nextInt(_blockPatterns.length)];
  var w = original.width ~/ 3;
  var h = original.height ~/ 3;
  final blurRadius = min(original.width, original.height) ~/ 12;
  var blurBuffer = image.Image(w, h);
  for (var i = 0; i < blocks.length; ++i) {
    var col = blocks[i] % 3;
    var row = blocks[i] ~/ 3;
    var x = col * w;
    var y = row * h;
    w = w >= original.width ? original.width - 1 : w;
    h = h >= original.height ? original.height - 1 : h;
    if (i < blurredBlockCount) {
      // This block need blurring
      image.copyInto(blurBuffer, original,
          dstX: 0, dstY: 0, srcX: x, srcY: y, srcW: w, srcH: h, blend: false);
      // Perform blurring
      image.pixelate(blurBuffer, blurRadius, mode: image.PixelateMode.average);
      // Copy blurred result to blurred image
      image.copyInto(blurred, blurBuffer,
          dstX: x, dstY: y, srcX: 0, srcY: 0, srcW: w, srcH: h, blend: false);
    } else {
      // Copy untouched
      image.copyInto(blurred, original,
          dstX: x, dstY: y, srcX: x, srcY: y, srcW: w, srcH: h, blend: false);
    }
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
  late Future<Waifu> _pickWaifuFastTask;

  init() async {
    var list = await Directory('./waifu')
        .list()
        .takeWhile((entity) => entity is File)
        .map((entity) => entity as File)
        .takeWhile((f) => validImageExtensions.contains(extension(f.path)))
        .toList();
    _unpickedList.addAll(list);
    // Pre-pick for better user experience
    _pickWaifuFastTask = _pickWaifu(null);
  }

  Future<Waifu> pickWaifu(BuildContext context) async {
    // _pickWaifuFastTask ??= _pickWaifu(context);
    final task = _pickWaifuFastTask;
    final ret = await task;
    if (task != _pickWaifuFastTask) {
      throw Exception('call pickWaifu in parallel is not allowed');
    }
    _pickWaifuFastTask = _pickWaifu(context);
    return ret;
  }

  Future<Waifu> _pickWaifu(BuildContext? context) async {
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
      ImageProvider image, BuildContext? context) async {
    if (context != null) {
      await precacheImage(image, context);
    }
    return image;
  }
}

var harem = Harem();
