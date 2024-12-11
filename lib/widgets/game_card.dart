import 'package:flutter/material.dart';
import '../models/card_item.dart';

class GameCard extends StatelessWidget {
  final CardItem card;
  final VoidCallback onTap;
  final bool isVisible;

  const GameCard({
    super.key,
    required this.card,
    required this.onTap,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isVisible ? 1.0 : 0.0,
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder(
          tween: Tween<double>(
            begin: card.isFlipped ? 180 : 0,
            end: card.isFlipped ? 0 : 180,
          ),
          duration: const Duration(milliseconds: 300),
          builder: (context, double value, child) {
            final isBack = value >= 90;
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(value * 3.1415927 / 180),
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isBack ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Center(
                  child: isBack
                      ? const SizedBox()
                      : Text(
                    card.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

