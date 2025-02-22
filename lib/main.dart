import 'dart:convert';

import 'package:blackjack_strategy/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controllers/game_controller.dart';
import 'models/game_options.dart';

const String STRATEGY = "basic";

void main() {
  runApp(const AppMain());
}

class AppMain extends StatelessWidget {
  const AppMain({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String>(
          future: rootBundle.loadString("assets/${STRATEGY}_strategy.json"),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            return MainScreen(
              gameController: GameController(
                gameOptions: GameOptions(
                  deckCount: 6,
                ),
                strategyData: jsonDecode(snapshot.data!),
              ),
            );
          }),
    );
  }
}
