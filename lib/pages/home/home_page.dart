import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            child: const Text('开始游戏'),
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'gameplay');
            }),
      ),
    );
  }
}
