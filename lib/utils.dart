import 'package:blackjack_strategy/models/hand_type.dart';
import 'package:playing_cards/playing_cards.dart';

class Utils {
  static List<PlayingCard> createDeck() {
    List<PlayingCard> deck = [];

    Suit.values.where((suit) => suit != Suit.joker).forEach((suit) {
      CardValue.values
          .where((value) =>
              ![CardValue.joker_1, CardValue.joker_2].contains(value))
          .forEach((value) {
        deck.add(PlayingCard(suit, value));
      });
    });

    return deck;
  }

  static HandType getPlayerHandType(List<PlayingCard> cards) {
    if (cards.length == 2) {
      if (Set.of(cards.map((card) => [
                CardValue.jack,
                CardValue.queen,
                CardValue.king
              ].contains(card.value)
                  ? CardValue.king
                  : card.value)).length ==
          1) {
        return HandType.pair;
      } else if (cards.any((card) => card.value == CardValue.ace)) {
        return HandType.softTotal;
      }
    }

    return HandType.hardTotal;
  }

  static int getCardsValue(List<PlayingCard> cards) {
    return cards.map((card) => card.value).fold(0, (value, card) {
      if (card == CardValue.ace) {
        return value + 11;
      } else if ([
        CardValue.ten,
        CardValue.jack,
        CardValue.queen,
        CardValue.king
      ].contains(card)) {
        return value + 10;
      }

      return value +
          {
            "two": 2,
            "three": 3,
            "four": 4,
            "five": 5,
            "six": 6,
            "seven": 7,
            "eight": 8,
            "nine": 9,
          }[card.name]!;
    });
  }
}
