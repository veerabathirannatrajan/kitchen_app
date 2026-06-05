import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/pending_order.dart';

class OrderCompletionAnimator extends StatefulWidget {
  final PendingOrder order;
  final Widget child;
  final bool isComplete;
  final VoidCallback onDismissed;

  const OrderCompletionAnimator({
    super.key,
    required this.order,
    required this.child,
    required this.isComplete,
    required this.onDismissed,
  });

  @override
  State<OrderCompletionAnimator> createState() => _OrderCompletionAnimatorState();
}

class _OrderCompletionAnimatorState extends State<OrderCompletionAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glowIn;
  late Animation<double> _wash;
  late Animation<double> _exitOpacity;
  late Animation<double> _exitSlide;
  late Animation<double> _exitHeight;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

    _glowIn = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.00, 0.42, curve: Curves.easeInOut)));
    _wash = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.36, 0.68, curve: Curves.easeInOut)));
    _exitOpacity = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.68, 0.96, curve: Curves.easeInQuart)));
    _exitSlide = Tween(begin: 0.0, end: -32.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.68, 1.00, curve: Curves.easeInCubic)));
    _exitHeight = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.82, 1.00, curve: Curves.easeInCubic)));

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDismissed();
    });
  }

  @override
  void didUpdateWidget(OrderCompletionAnimator old) {
    super.didUpdateWidget(old);
    if (widget.isComplete && !old.isComplete && !_triggered) {
      _triggered = true;
      Future.delayed(const Duration(milliseconds: 280), () {
        if (mounted) {
          HapticFeedback.mediumImpact();
          _ctrl.forward(from: 0);
        }
      });
    }
    if (!widget.isComplete && _triggered) {
      _triggered = false;
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final glow = _glowIn.value;
        final wash = _wash.value;

        return SizeTransition(
          sizeFactor: _exitHeight,
          axisAlignment: -1,
          child: Transform.translate(
            offset: Offset(0, _exitSlide.value),
            child: Opacity(
              opacity: _exitOpacity.value,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: glow > 0.01 ? [
                        BoxShadow(color: Color.fromRGBO(39, 174, 96, 0.22 * glow), blurRadius: 22 * glow, spreadRadius: 2 * glow),
                        BoxShadow(color: Color.fromRGBO(39, 174, 96, 0.10 * glow), blurRadius: 44 * glow, spreadRadius: 4 * glow),
                      ] : [],
                    ),
                    child: child,
                  ),
                  if (wash > 0.0)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CustomPaint(painter: _WashPainter(progress: wash)),
                      ),
                    ),
                  if (glow > 0.01)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(painter: _BorderSweepPainter(progress: (glow * 1.6).clamp(0.0, 1.0), color: const Color(0xFF27AE60))),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _BorderSweepPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _BorderSweepPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const r = 20.0;
    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    final roundRect = RRect.fromRectAndRadius(rect, const Radius.circular(r));
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.8..strokeCap = StrokeCap.round;
    paint.color = Color.fromRGBO(color.red, color.green, color.blue, 0.18);
    canvas.drawRRect(roundRect, paint);
    final leadOpacity = (0.7 + 0.3 * math.sin(progress * math.pi)).clamp(0.0, 1.0);
    paint.color = Color.fromRGBO(color.red, color.green, color.blue, leadOpacity);
    final path = Path()..addRRect(roundRect);
    for (final metric in path.computeMetrics()) {
      final len = metric.length * progress;
      final extracted = metric.extractPath(0, len);
      canvas.drawPath(extracted, paint);
      break;
    }
  }

  @override
  bool shouldRepaint(_BorderSweepPainter old) => old.progress != progress;
}

class _WashPainter extends CustomPainter {
  final double progress;
  const _WashPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final frontY = size.height * progress;
    final washRect = Rect.fromLTWH(0, 0, size.width, frontY);
    final washPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color.fromRGBO(39, 174, 96, 0.10), Color.fromRGBO(39, 174, 96, 0.06)],
      ).createShader(washRect);
    canvas.drawRect(washRect, washPaint);
    if (progress > 0.01 && progress < 0.99) {
      final linePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft, end: Alignment.centerRight,
          colors: [Colors.transparent, Color.fromRGBO(46, 204, 113, 0.55), Color.fromRGBO(46, 204, 113, 0.55), Colors.transparent],
          stops: const [0.0, 0.15, 0.85, 1.0],
        ).createShader(Rect.fromLTWH(0, frontY - 1.5, size.width, 3))
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, frontY - 1.5, size.width, 3), linePaint);
    }
  }

  @override
  bool shouldRepaint(_WashPainter old) => old.progress != progress;
}