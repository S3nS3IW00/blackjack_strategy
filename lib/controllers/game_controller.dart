import 'package:blackjack_strategy/models/game_action.dart';
import 'package:blackjack_strategy/models/game_options.dart';
import 'package:blackjack_strategy/models/hand_type.dart';
import 'package:blackjack_strategy/utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:playing_cards/playing_cards.dart';

class GameController extends ChangeNotifier {
  GameController({required this.gameOptions, required this.strategyData}) {
    _shuffle();
    _dealFirstCards();
  }

  final GameOptions gameOptions;
  final Map<String, dynamic> strategyData;

  List<PlayingCard> cards = [];

  List<PlayingCard> dealerCards = [];
  List<PlayingCard> playerCards = [];

  bool playerTurn = true;
  bool blackjack = false;

  int totalRounds = 0;
  int playerWinRounds = 0;

  _shuffle() {
    cards = List.generate(gameOptions.deckCount, (index) => Utils.createDeck())
        .expand((e) => e)
        .toList();
    cards.shuffle();

    notifyListeners();
  }

  _dealFirstCards() {
    playerCards.add(cards.removeAt(0));
    dealerCards.add(cards.removeAt(0));
    playerCards.add(cards.removeAt(0));
    dealerCards.add(cards.removeAt(0));

    if (Utils.getCardsValue(playerCards) == 21) {
      blackjack = true;
      totalRounds++;
      playerWinRounds++;
    }

    notifyListeners();
  }

  handleAction(GameAction action) {
    totalRounds++;
    if (action == getCorrectAction()) {
      playerWinRounds++;
    }

    notifyListeners();
  }

  newRound() {
    playerCards.clear();
    dealerCards.clear();

    blackjack = false;
    playerTurn = true;
    _shuffle();
    _dealFirstCards();
  }

  GameAction getCorrectAction() {
    GameAction action = GameAction.hit;

    final handType = Utils.getPlayerHandType(playerCards);

    final dealerCardValue = dealerCards.last.value;

    if (handType == HandType.pair) {
      final cardValue = playerCards.first.value;

      final Map<String, dynamic> pairStrategyData =
          strategyData["pair_splitting"];
      if (pairStrategyData.containsKey(cardValue.name)) {
        final pairCardStrategy = pairStrategyData[cardValue.name];

        GameAction? pairCardStrategyCorrectAction =
            _getCorrectActionByStrategyData(pairCardStrategy, dealerCardValue);

        if (pairCardStrategyCorrectAction != null) {
          return pairCardStrategyCorrectAction;
        }
      }
    } else if (handType == HandType.softTotal) {
      final cardValue =
          playerCards.firstWhere((card) => card.value != CardValue.ace).value;

      final Map<String, dynamic> softTotalsStrategyData =
          strategyData["soft_totals"];
      if (softTotalsStrategyData.containsKey(cardValue.name)) {
        final softTotalCardStrategy = softTotalsStrategyData[cardValue.name];

        GameAction? softTotalsCardStrategyCorrectAction =
            _getCorrectActionByStrategyData(
                softTotalCardStrategy, dealerCardValue);

        return softTotalsCardStrategyCorrectAction ?? GameAction.hit;
      }
    }

    final cardsValue = Utils.getCardsValue(playerCards).toString();

    final Map<String, dynamic> hardTotalsStrategyData =
        strategyData["hard_totals"];
    if (hardTotalsStrategyData.containsKey(cardsValue)) {
      final hardTotalCardStrategy = hardTotalsStrategyData[cardsValue];

      GameAction? hardTotalsCardStrategyCorrectAction =
          _getCorrectActionByStrategyData(
              hardTotalCardStrategy, dealerCardValue);

      if (hardTotalsCardStrategyCorrectAction != null) {
        return hardTotalsCardStrategyCorrectAction;
      }
    }

    return action;
  }

  GameAction? _getCorrectActionByStrategyData(data, CardValue dealerCardValue) {
    if (data is String) {
      return GameAction.values.byName(data);
    }

    final Map<String, dynamic> dataMap = data as Map<String, dynamic>;
    String? action = dataMap.entries.firstWhereOrNull((entry) {
      if (entry.value is List) {
        if (entry.value.contains(dealerCardValue.name)) {
          return true;
        }
      }
      return false;
    })?.key;

    if (action == null && dataMap.containsKey("else")) {
      action = dataMap["else"];
    }

    return action != null ? GameAction.values.byName(action) : null;
  }

  List<GameAction> getPossibleActions() {
    final List<GameAction> actions = [GameAction.hit, GameAction.stand];

    if (playerCards.length == 2 && gameOptions.doubleAllowed) {
      actions.add(GameAction.double);
    }

    final handType = Utils.getPlayerHandType(playerCards);
    if (handType == HandType.pair) {
      actions.add(GameAction.split);
    }

    return actions;
  }
}
