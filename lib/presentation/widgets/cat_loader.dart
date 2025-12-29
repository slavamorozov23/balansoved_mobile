import 'package:flutter/material.dart';

const List<String> commentCatFrames = [
  'assets/promo/cat-2-0.png',
  'assets/promo/cat-2-0.png',
  'assets/promo/cat-2-1.png',
  'assets/promo/cat-2-2.png',
  'assets/promo/cat-2-3.png',
  'assets/promo/cat-2-2.png',
  'assets/promo/cat-2-1.png',
  'assets/promo/cat-2-0.png',
  'assets/promo/cat-2-0.png',
];

class CatLoader extends StatefulWidget {
  const CatLoader({
    super.key,
    required this.size,
    this.frames,
    this.frameDuration = const Duration(milliseconds: 180),
  });

  final double size;
  final List<String>? frames;
  final Duration frameDuration;

  @override
  State<CatLoader> createState() => _CatLoaderState();
}

class _CatLoaderState extends State<CatLoader>
    with SingleTickerProviderStateMixin {
  static const List<String> _defaultFrames = [
    'assets/promo/cat-0.png',
    'assets/promo/cat-1.png',
    'assets/promo/cat-2.png',
    'assets/promo/cat-1.png',
  ];

  late final AnimationController _controller;
  late Animation<String> _frame;
  late List<String> _frames;

  @override
  void initState() {
    super.initState();
    _frames = widget.frames ?? _defaultFrames;
    _controller = AnimationController(
      vsync: this,
      duration: widget.frameDuration * _frames.length,
    );
    _buildSequence();
    _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheFrames(_frames);
  }

  @override
  void didUpdateWidget(CatLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextFrames = widget.frames ?? _defaultFrames;
    final framesChanged = !_sameFrames(_frames, nextFrames);
    final durationChanged = oldWidget.frameDuration != widget.frameDuration;
    if (framesChanged || durationChanged) {
      _frames = nextFrames;
      _controller.duration = widget.frameDuration * _frames.length;
      _buildSequence();
      _controller
        ..reset()
        ..repeat();
      if (framesChanged) {
        _precacheFrames(_frames);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _buildSequence() {
    _frame = TweenSequence<String>([
      for (final frame in _frames)
        TweenSequenceItem(tween: ConstantTween<String>(frame), weight: 1),
    ]).animate(_controller);
  }

  void _precacheFrames(List<String> frames) {
    for (final frame in frames.toSet()) {
      precacheImage(AssetImage(frame), context);
    }
  }

  bool _sameFrames(List<String> current, List<String> next) {
    if (current.length != next.length) {
      return false;
    }
    for (var i = 0; i < current.length; i += 1) {
      if (current[i] != next[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _frame,
      builder: (context, child) {
        return Image.asset(
          _frame.value,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          gaplessPlayback: true,
        );
      },
    );
  }
}

class CatLoadingView extends StatelessWidget {
  const CatLoadingView({
    super.key,
    this.sizeFactor = 0.45,
    this.minSize = 160,
    this.maxSize = 260,
    this.frames,
    this.frameDuration,
  });

  final double sizeFactor;
  final double minSize;
  final double maxSize;
  final List<String>? frames;
  final Duration? frameDuration;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shortestSide = _resolveShortestSide(context, constraints);
        final size =
            (shortestSide * sizeFactor).clamp(minSize, maxSize).toDouble();
        return Center(
          child: CatLoader(
            size: size,
            frames: frames,
            frameDuration: frameDuration ?? const Duration(milliseconds: 180),
          ),
        );
      },
    );
  }

  double _resolveShortestSide(BuildContext context, BoxConstraints constraints) {
    final candidate = constraints.biggest.shortestSide;
    if (candidate.isFinite && candidate > 0) {
      return candidate;
    }
    return MediaQuery.sizeOf(context).shortestSide;
  }
}
