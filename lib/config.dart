import 'dart:io';

var countdownSeconds = 30;

Future<void> loadConfig() async {
  final f = File('config.txt');
  if (await f.exists()) {
    final lines = await f.readAsLines();
    for (var line in lines) {
      line = line.trim();
      if (line.startsWith('#')) {
        continue;
      }
      final p = line.split('=');
      if (p.length != 2) {
        continue;
      }
      final k = p[0].trim();
      final v = p[1].trim();
      switch (k) {
        case 'countdownSeconds':
          countdownSeconds = int.parse(v);
          break;
      }
    }
  }
  assert(countdownSeconds > 0);
}
