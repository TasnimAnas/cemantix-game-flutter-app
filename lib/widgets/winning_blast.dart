import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class WinningBlast extends StatelessWidget {
  final ConfettiController _confettiController;
  final BlastDirectionality blastDirectionality;
  final Alignment alignment;
  final double blastDirection;

  const WinningBlast({
    super.key,
    required ConfettiController confettiController,
    this.blastDirectionality = BlastDirectionality.directional,
    this.alignment = Alignment.center,
    this.blastDirection = pi,
  }) : _confettiController = confettiController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: blastDirectionality,
        blastDirection: blastDirection,
        emissionFrequency: 0.05,
        numberOfParticles: 20,
        gravity: 0.1,
        shouldLoop: false,
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple,
          Colors.yellow,
          Colors.red,
          Colors.cyan,
        ],
      ),
    );
  }
}
