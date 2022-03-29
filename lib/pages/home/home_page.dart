import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
          child: const Text('Start'),
          onPressed: () {
            Navigator.pushReplacementNamed(context, 'gameplay');
          }),
    );
  }
}