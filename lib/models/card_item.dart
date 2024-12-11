class CardItem {
  final String emoji;
  final bool isFlipped;
  final bool isMatched;

  CardItem({
    required this.emoji,
    this.isFlipped = false,
    this.isMatched = false,
  });

  CardItem copyWith({
    String? emoji,
    bool? isFlipped,
    bool? isMatched,
  }) {
    return CardItem(
      emoji: emoji ?? this.emoji,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
