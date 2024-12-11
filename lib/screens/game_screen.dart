import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<AnimationController> _cardControllers = [];
  final List<Animation<double>> _rotationAnimations = [];
  final List<Animation<double>> _scaleAnimations = [];
  final List<Animation<double>> _elevationAnimations = [];
  bool hasDealtCards = false;
  bool isShuffling = false;
  bool isAnimating = false;
  List<int> _cardOrder = List.generate(12, (index) => index);
  final Random _random = Random();
  final List<double> _zIndexes = List.generate(12, (index) => 0.0);


  List<Animation<Offset>>? _shufflePositions;
  List<Animation<double>>? _shuffleRotations;
  late AnimationController _shuffleController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _shuffleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeShuffleAnimations();
  }

  void _initializeAnimations() {
    _cardControllers = List.generate(
      12,
          (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    for (var controller in _cardControllers) {
      _rotationAnimations.add(
        Tween<double>(begin: 0.2, end: 0.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutBack,
          ),
        ),
      );

      _scaleAnimations.add(
        Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutCirc,
          ),
        ),
      );

      _elevationAnimations.add(
        Tween<double>(begin: 20.0, end: 2.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutQuad,
          ),
        ),
      );
    }
  }

  void _initializeShuffleAnimations() {
    if (!mounted) return;

    _shufflePositions = [];
    _shuffleRotations = [];


    for (int i = 0; i < 12; i++) {
      _zIndexes[i] = 0.0;
    }

    for (int i = 0; i < 12; i++) {
      _shufflePositions!.add(
        TweenSequence<Offset>([
          TweenSequenceItem(
            tween: Tween<Offset>(
              begin: Offset.zero,
              end: _generateRandomOffset(concentrationFactor: 0.8),
            ).chain(CurveTween(curve: Curves.easeOutBack)),
            weight: 20.0,
          ),
          TweenSequenceItem(
            tween: Tween<Offset>(
              begin: _generateRandomOffset(concentrationFactor: 0.8),
              end: _generateRandomOffset(concentrationFactor: 0.6),
            ).chain(CurveTween(curve: Curves.easeInOutSine)),
            weight: 20.0,
          ),
          TweenSequenceItem(
            tween: Tween<Offset>(
              begin: _generateRandomOffset(concentrationFactor: 0.6),
              end: _generateRandomOffset(concentrationFactor: 0.7),
            ).chain(CurveTween(curve: Curves.easeInOutCirc)),
            weight: 20.0,
          ),
          TweenSequenceItem(
            tween: Tween<Offset>(
              begin: _generateRandomOffset(concentrationFactor: 0.7),
              end: _generateRandomOffset(concentrationFactor: 0.5),
            ).chain(CurveTween(curve: Curves.easeInOutSine)),
            weight: 20.0,
          ),
          TweenSequenceItem(
            tween: Tween<Offset>(
              begin: _generateRandomOffset(concentrationFactor: 0.5),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.elasticOut)),
            weight: 20.0,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _shuffleController,
            curve: const Interval(0.0, 1.0),
          ),
        ),
      );

      _shuffleRotations!.add(
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 0,
              end: (_random.nextBool() ? 1 : -1) * pi / 3,
            ).chain(CurveTween(curve: Curves.easeOutCirc)),
            weight: 20.0,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: (_random.nextBool() ? 1 : -1) * pi / 3,
              end: (_random.nextBool() ? 1 : -1) * pi / 4,
            ).chain(CurveTween(curve: Curves.easeInOutSine)),
            weight: 60.0,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: (_random.nextBool() ? 1 : -1) * pi / 4,
              end: 0,
            ).chain(CurveTween(curve: Curves.elasticOut)),
            weight: 20.0,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _shuffleController,
            curve: const Interval(0.0, 1.0),
          ),
        ),
      );
    }
  }

  Offset _generateRandomOffset({double concentrationFactor = 0.6}) {
    if (!mounted) return Offset.zero;

    final size = MediaQuery.of(context).size;
    final cardWidth = (size.width - 32) / 3;

    final centerX = (cardWidth * 3) / 2;
    final centerY = (cardWidth * 4) / 2;

    final maxRadius = min(cardWidth, min(centerX, centerY)) * concentrationFactor;

    final angle = _random.nextDouble() * 2 * pi;
    final radius = sqrt(_random.nextDouble()) * maxRadius;

    final rawOffset = Offset(
      cos(angle) * radius,
      sin(angle) * radius,
    );

    return _constrainOffset(rawOffset, centerX, centerY, cardWidth);
  }

  Offset _constrainOffset(Offset offset, double centerX, double centerY, double cardWidth) {
    final maxX = centerX - (cardWidth / 2);
    final maxY = centerY - (cardWidth / 2);

    return Offset(
      offset.dx.clamp(-maxX, maxX),
      offset.dy.clamp(-maxY, maxY),
    );
  }


  void _shuffleCards() async {
    if (isShuffling || !mounted || isAnimating) return;

    setState(() {
      isShuffling = true;
      isAnimating = true;
    });

    _initializeShuffleAnimations();
    final newOrder = List<int>.from(_cardOrder)..shuffle(_random);

    await _shuffleController.forward();

    setState(() {
      _cardOrder = newOrder;
      isShuffling = false;
    });

    await _shuffleController.reverse();

    if (mounted) {
      setState(() {
        isAnimating = false;
      });
    }
  }

  void _reverseAnimation() {
    if (isAnimating) return;

    setState(() {
      hasDealtCards = false;
      _cardOrder = List.generate(12, (index) => index);
      isAnimating = true;
    });

    for (int i = _cardControllers.length - 1; i >= 0; i--) {
      Future.delayed(Duration(milliseconds: (_cardControllers.length - 1 - i) * 100), () {
        if (mounted) {
          _cardControllers[i].reverse().then((_) {
            if (i == 0 && mounted) {
              setState(() {
                isAnimating = false;
              });
            }
          });
        }
      });
    }
  }

  void _startDealAnimation() {
    if (hasDealtCards || isAnimating) return;

    setState(() {
      isAnimating = true;
    });

    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _cardControllers[i].forward().then((_) {
            if (mounted && i == _cardControllers.length - 1) {
              setState(() {
                hasDealtCards = true;
                isAnimating = false;
              });
            }
          });
        }
      });
    }
  }


  Widget _buildCard(int index, BuildContext context) {
    final cardIndex = _cardOrder[index];

    return AnimatedBuilder(
      animation: Listenable.merge([_cardControllers[cardIndex], _shuffleController]),
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        final double width = (size.width - 32) / 3;
        final int row = index ~/ 3;
        final int col = index % 3;

        final gridPosition = Offset(
          col * width + 16,
          row * width + 16,
        );

        final startPosition = Offset(24, MediaQuery.of(context).size.height - 96);

        final positionAnimation = CurvedAnimation(
          parent: _cardControllers[cardIndex],
          curve: Curves.easeOutQuint,
        );

        double x = lerpDouble(
          startPosition.dx,
          gridPosition.dx,
          positionAnimation.value,
        )!;
        double y = lerpDouble(
          startPosition.dy,
          gridPosition.dy,
          positionAnimation.value,
        )!;

        if (isShuffling) {
          final progress = _shuffleController.value;
          if ((progress * 100).floor() % 20 == 0) {
            _zIndexes[cardIndex] = _random.nextDouble() * 12;
          }
        }

        if (isShuffling && _shufflePositions != null) {
          final shuffleOffset = _shufflePositions![cardIndex].value;
          x += shuffleOffset.dx;
          y += shuffleOffset.dy;
        }

        double rotation = _rotationAnimations[cardIndex].value;
        if (isShuffling && _shuffleRotations != null) {
          rotation += _shuffleRotations![cardIndex].value;
        }

        double scale = _scaleAnimations[cardIndex].value;
        if (isShuffling) {
          scale *= 1.0 + (sin(_shuffleController.value * pi * 2) * 0.05);
        }

        double elevation = _elevationAnimations[cardIndex].value;
        if (isShuffling) {
          elevation = lerpDouble(
            elevation,
            elevation * 1.5,
            _shuffleController.value,
          )!;
        }

        return Transform(
          transform: Matrix4.translationValues(x, y, _zIndexes[cardIndex]),
          child: Opacity(
            opacity: _cardControllers[cardIndex].value,
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  width: width - 8,
                  height: width - 8,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: elevation,
                        offset: Offset(0, elevation / 2),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 0.5,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                            stops: const [0.0, 0.8],
                          ),
                        ),
                        child: Stack(
                          children: [
                            if (isShuffling)
                              Positioned.fill(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: (sin(_shuffleController.value * pi * 2) * 0.1).clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        center: Alignment.center,
                                        radius: 0.8,
                                        colors: [
                                          Colors.white.withOpacity(0.2),
                                          Colors.white.withOpacity(0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox.expand(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ...List.generate(12, (index) => _buildCard(index, context)),
                  Positioned(
                    left: 16,
                    bottom: 24,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: isAnimating
                            ? null
                            : (hasDealtCards ? _reverseAnimation : _startDealAnimation),
                        child: Icon(
                          hasDealtCards ? Icons.restart_alt : Icons.play_arrow,
                          color: isAnimating ? Colors.grey : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (hasDealtCards)
                    Positioned(
                      right: 16,
                      bottom: 24,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: isAnimating ? null : _shuffleCards,
                          child:  Icon(
                            Icons.shuffle,
                            color: isAnimating ? Colors.grey : Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shuffleController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}