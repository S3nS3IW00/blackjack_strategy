import 'package:blackjack_strategy/controllers/game_controller.dart';
import 'package:blackjack_strategy/models/game_action.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.gameController,
  });

  final GameController gameController;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  GameAction? selectedAction;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.gameController,
        builder: (context, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Blackjack strategy test"),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${widget.gameController.playerWinRounds}/${widget.gameController.totalRounds}",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        "Win/Total",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                )
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dealer's cards",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: SizedBox(
                          width: widget.gameController.dealerCards.length * 100,
                          child: FlatCardFan(
                            children: widget.gameController.dealerCards
                                .mapIndexed(
                                  (index, card) => PlayingCardView(
                                    card: card,
                                    elevation: 3.0,
                                    showBack:
                                        widget.gameController.playerTurn &&
                                            index == 0,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Builder(builder: (context) {
                          if (widget.gameController.blackjack ||
                              selectedAction != null) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Builder(
                                  builder: (context) {
                                    String text;

                                    if (widget.gameController.blackjack) {
                                      text = "Blackjack";
                                    } else {
                                      GameAction correctAction = widget
                                          .gameController
                                          .getCorrectAction();
                                      if (selectedAction! == correctAction) {
                                        text = "Correct";
                                      } else {
                                        text =
                                            "Not correct, you should ${correctAction.name}";
                                      }
                                    }

                                    return Text(
                                      text,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    );
                                  },
                                ),
                                const SizedBox(height: 10.0),
                                ElevatedButton(
                                  child: Text("Next round"),
                                  onPressed: () {
                                    setState(() {
                                      selectedAction = null;
                                      widget.gameController.newRound();
                                    });
                                  },
                                ),
                              ],
                            );
                          }

                          return Wrap(
                            spacing: 10.0,
                            children: widget.gameController
                                .getPossibleActions()
                                .map((action) => ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        widget.gameController.handleAction(action);
                                        selectedAction = action;
                                      });
                                    },
                                    child: Text(action.name)))
                                .toList(),
                          );
                        }),
                      ),
                    ),
                    Text(
                      "Your cards",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: SizedBox(
                          width: widget.gameController.playerCards.length * 100,
                          child: FlatCardFan(
                            children: widget.gameController.playerCards
                                .map(
                                  (card) => PlayingCardView(
                                    card: card,
                                    elevation: 3.0,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
