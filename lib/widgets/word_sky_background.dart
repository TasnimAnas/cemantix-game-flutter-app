import 'dart:math';

import 'package:cemantix/const.dart';
import 'package:flutter/material.dart';

class WordSkyBackground extends StatefulWidget {
  final List<String> words;
  final Color baseColor;
  final int count;

  const WordSkyBackground({
    Key? key,
    this.words = SKY_BG_WORDS,
    this.baseColor = const Color(0xFF9AE6E6),
    this.count = 30,
  }) : super(key: key);

  @override
  State<WordSkyBackground> createState() => _WordSkyBackgroundState();
}

class _WordSkyBackgroundState extends State<WordSkyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_GlideItem> _items = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _createItems();
  }

  void _createItems() {
    // Stratified sampling: split the area into a grid and place one
    // item per cell (with some jitter). This ensures an even distribution
    _items.clear();

    final int cols = max(1, sqrt(widget.count).ceil());
    final int rows = max(1, (widget.count / cols).ceil());

    for (var i = 0; i < widget.count; i++) {
      final word = widget.words.isEmpty
          ? ''
          : widget.words[_rnd.nextInt(widget.words.length)];

      final r = i ~/ cols;
      final c = i % cols;

      // cell center
      final double baseX = (c + 0.5) / cols;
      final double baseY = (r + 0.5) / rows;

      // jitter inside cell (scaled so we don't overlap neighboring cells too much)
      final double jitterX = (_rnd.nextDouble() - 0.5) * (0.9 / cols);
      final double jitterY = (_rnd.nextDouble() - 0.5) * (0.9 / rows);

      // small margin outside 0..1 so words can drift in/out smoothly
      final double offX = (_rnd.nextDouble() - 0.5) * 0.15;
      final double offY = (_rnd.nextDouble() - 0.5) * 0.15;

      final double x = baseX + jitterX + offX;
      final double y = baseY + jitterY + offY;

      _items.add(
        _GlideItem(
          word: word,
          x: x,
          y: y,
          // keep livelier baseline speed (1.5x)
          speed: (_rnd.nextDouble() * 0.6 + 0.05) * 1.5,
          // varied small text sizes for depth
          size: (_rnd.nextDouble() * 10) + 8,
          opacity: _rnd.nextDouble() * 0.15 + 0.15,
          // slight vertical/horizontal drift
          drift: (_rnd.nextDouble() * 2 - 1) * 0.22,
          rotation: (_rnd.nextDouble() * 2 - 1) * 0.18,
          hueShift: _rnd.nextDouble(),
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant WordSkyBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the word list changed, refresh the words in the existing items
    if (oldWidget.words.toString() != widget.words.toString()) {
      for (var i = 0; i < _items.length; i++) {
        if (widget.words.isNotEmpty) {
          _items[i].word = widget.words[_rnd.nextInt(widget.words.length)];
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return IgnorePointer(
          child: SizedBox.expand(
            child: CustomPaint(
              painter: _WordSkyPainter(
                items: _items,
                progress: _controller.value,
                baseColor: widget.baseColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlideItem {
  String word;
  double x;
  double y;
  double speed;
  double size;
  double opacity;
  double drift;
  double rotation;
  double hueShift;

  _GlideItem({
    required this.word,
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.drift,
    required this.rotation,
    required this.hueShift,
  });
}

class _WordSkyPainter extends CustomPainter {
  final List<_GlideItem> items;
  final double progress;
  final Color baseColor;

  _WordSkyPainter({
    required this.items,
    required this.progress,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final rect = Offset.zero & size;
    canvas.drawRect(rect, paint);

    // Reset paint shader for items
    paint.shader = null;

    for (var i = 0; i < items.length; i++) {
      final it = items[i];

      // Compute position with wrap-around
      final double px =
          ((it.x + progress * it.speed * 0.05) % 1.0) * size.width;
      final double py =
          ((it.y + sin((progress + it.hueShift) * it.speed * 6) * it.drift) %
              1.0) *
          size.height;

      // Map hueShift to color variation
      final hsv = HSVColor.fromColor(baseColor);
      final color = hsv.withHue((hsv.hue + it.hueShift * 40) % 360).toColor();

      // soft halo behind the word to emulate glow
      final halo = Paint()
        ..color = color.withOpacity(it.opacity * 0.05)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, it.size * 0.12);
      canvas.drawCircle(Offset(px, py), it.size * 1.6, halo);

      final textSpan = TextSpan(
        text: it.word,
        style: TextStyle(
          color: color.withOpacity(it.opacity * 0.5),
          fontSize: it.size,
          fontWeight: FontWeight.w500,
        ),
      );

      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      tp.layout();

      canvas.save();

      // subtle rotation
      canvas.translate(px, py);
      canvas.rotate(it.rotation * sin(progress * pi * 2 + i));
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // Extra layered vignette overlay to darken corners subtly
    final overlay = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, Colors.black.withOpacity(0.25)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect)
      ..blendMode = BlendMode.darken;
    canvas.drawRect(rect, overlay);
  }

  @override
  bool shouldRepaint(covariant _WordSkyPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.items != items;
  }
}
