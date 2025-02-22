class GameOptions {
  GameOptions({
    this.deckCount = 6,
    this.surrenderAllowed = false,
    this.doubleAllowed = true,
    this.doubleAfterSplitAllowed = true,
  });

  final int deckCount;

  final bool surrenderAllowed;

  final bool doubleAllowed;
  final bool doubleAfterSplitAllowed;
}
