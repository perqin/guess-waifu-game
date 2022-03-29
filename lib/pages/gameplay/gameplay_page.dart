import 'package:flutter/widgets.dart';

class GameplayPage extends StatefulWidget {
  const GameplayPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GameplayPageState();
}

class _GameplayPageState extends State<GameplayPage> {
  @override
  Widget build(BuildContext context) {
    return const Text('Gameplay');
  }
}
