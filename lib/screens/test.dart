import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../data/mock_orders.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 3D BUTTON WIDGET (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
class Button3D extends StatefulWidget {
  final Widget child;
  final Color color;
  final VoidCallback onTap;
  final double borderRadius;
  final EdgeInsets padding;
  final double? width;

  const Button3D({
    super.key,
    required this.child,
    required this.color,
    required this.onTap,
    this.borderRadius = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.width,
  });

  @override
  State<Button3D> createState() => _Button3DState();
}

class _Button3DState extends State<Button3D>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  static const double _sinkDepth = 5.0;

  Color get _wallColor {
    final hsl = HSLColor.fromColor(widget.color);
    return hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();
  }

  Color get _topColor {
    final hsl = HSLColor.fromColor(widget.color);
    return hsl.withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0)).toColor();
  }

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.lightImpact();
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    widget.onTap();
  }

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: SizedBox(
        width: widget.width,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _wallColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _pressed
                ? [BoxShadow(color: _wallColor.withOpacity(0.30), blurRadius: 4, offset: const Offset(0, 2))]
                : [
              BoxShadow(color: _wallColor.withOpacity(0.55), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 6)),
              BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 8)),
            ],
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, _pressed ? _sinkDepth : 0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_topColor, widget.color],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.22), width: 1.2),
            ),
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPLETION ANIMATOR WIDGET
// Wraps a single order card and drives the full celebration → exit sequence
// ─────────────────────────────────────────────────────────────────────────────
class _OrderCompletionAnimator extends StatefulWidget {
  final PendingOrder order;
  final Widget child;
  final bool isComplete;
  final VoidCallback onDismissed;

  const _OrderCompletionAnimator({
    required this.order,
    required this.child,
    required this.isComplete,
    required this.onDismissed,
  });

  @override
  State<_OrderCompletionAnimator> createState() =>
      _OrderCompletionAnimatorState();
}

class _OrderCompletionAnimatorState extends State<_OrderCompletionAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // Phase 1 (0.0 → 0.35): pulse / ripple glow on the card
  // Phase 2 (0.35 → 0.65): particle burst + label
  // Phase 3 (0.65 → 1.0 ): card shrinks & fades out upward
  late Animation<double> _glowPulse;   // 0→1→0 in phase1
  late Animation<double> _particles;   // 0→1 in phase2
  late Animation<double> _exitScale;   // 1→0.75 in phase3
  late Animation<double> _exitOpacity; // 1→0 in phase3
  late Animation<double> _exitSlide;   // 0→-60 in phase3

  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _glowPulse = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.38, curve: Curves.easeInOut),
    ));

    _particles = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.30, 0.68, curve: Curves.easeOutCubic),
    ));

    _exitScale = Tween(begin: 1.0, end: 0.78).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.65, 1.0, curve: Curves.easeInCubic),
    ));

    _exitOpacity = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.65, 1.0, curve: Curves.easeInQuart),
    ));

    _exitSlide = Tween(begin: 0.0, end: -55.0).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.65, 1.0, curve: Curves.easeInCubic),
    ));

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDismissed();
      }
    });
  }

  @override
  void didUpdateWidget(_OrderCompletionAnimator old) {
    super.didUpdateWidget(old);
    if (widget.isComplete && !old.isComplete && !_triggered) {
      _triggered = true;
      // Small delay so the last item's own tick animation finishes first
      Future.delayed(const Duration(milliseconds: 320), () {
        if (mounted) {
          HapticFeedback.heavyImpact();
          _ctrl.forward(from: 0);
        }
      });
    }
    // If an item is un-ticked while animating, reset
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
        final isAnimating = _ctrl.isAnimating || _ctrl.isCompleted;

        // ── Phase 3: exit transform ─────────────────────────────────────
        return Transform.translate(
          offset: Offset(0, _exitSlide.value),
          child: Transform.scale(
            scale: _exitScale.value,
            child: Opacity(
              opacity: _exitOpacity.value,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Card with glow border during phase 1 ──────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: _glowPulse.value > 0.01
                          ? [
                        BoxShadow(
                          color: const Color(0xFF27AE60)
                              .withOpacity(0.55 * _glowPulse.value),
                          blurRadius: 28 * _glowPulse.value,
                          spreadRadius: 4 * _glowPulse.value,
                        ),
                        BoxShadow(
                          color: const Color(0xFF2ECC71)
                              .withOpacity(0.25 * _glowPulse.value),
                          blurRadius: 50 * _glowPulse.value,
                          spreadRadius: 6 * _glowPulse.value,
                        ),
                      ]
                          : [],
                    ),
                    child: widget.child,
                  ),

                  // ── Phase 2: particle burst overlay ───────────────────
                  if (_particles.value > 0 && _particles.value < 1)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CustomPaint(
                            painter: _BurstParticlesPainter(
                              progress: _particles.value,
                              color: const Color(0xFF27AE60),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ── Ripple rings (phase 1) ─────────────────────────────
                  if (_glowPulse.value > 0.01)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _RippleRingPainter(
                            progress: _glowPulse.value,
                            color: const Color(0xFF27AE60),
                          ),
                        ),
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

// ─────────────────────────────────────────────────────────────────────────────
// RIPPLE RING PAINTER  (phase 1 — expanding green rings on the card)
// ─────────────────────────────────────────────────────────────────────────────
class _RippleRingPainter extends CustomPainter {
  final double progress; // 0→1→0
  final Color color;

  const _RippleRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.sqrt(size.width * size.width + size.height * size.height) / 2;

    for (int i = 0; i < 3; i++) {
      final delay = i * 0.18;
      final t = ((progress - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final radius = maxR * t * 1.1;
      final opacity = (1.0 - t) * 0.35 * progress;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 - i * 0.5
        ..color = color.withOpacity(opacity.clamp(0.0, 1.0));

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RippleRingPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// BURST PARTICLES PAINTER  (phase 2 — confetti-style explosion)
// ─────────────────────────────────────────────────────────────────────────────
class _BurstParticlesPainter extends CustomPainter {
  final double progress; // 0→1
  final Color color;

  const _BurstParticlesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(77);
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    const particleCount = 64;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi + rng.nextDouble() * 0.4;
      final speed = 0.35 + rng.nextDouble() * 0.65;
      final maxDist = (size.width * 0.55) * speed;

      // Ease out distance — fast start, slow end
      final dist = maxDist * (1 - math.pow(1 - progress, 2.5));

      final x = center.dx + math.cos(angle) * dist;
      // Slight vertical bias downward (gravity feel)
      final y = center.dy + math.sin(angle) * dist * 0.75 + progress * 12 * speed;

      final baseR = 1.8 + rng.nextDouble() * 3.2;
      final radius = baseR * (1 - progress * 0.65);

      // Opacity: fast appear, slower fade
      final opacity = (math.sin(progress * math.pi) *
          (0.5 + rng.nextDouble() * 0.5))
          .clamp(0.0, 1.0);

      // Color variety: mix green shades + white sparkles
      final colorChoice = rng.nextInt(4);
      Color pColor;
      switch (colorChoice) {
        case 0:
          pColor = const Color(0xFF27AE60);
          break;
        case 1:
          pColor = const Color(0xFF2ECC71);
          break;
        case 2:
          pColor = const Color(0xFF52D68A);
          break;
        default:
          pColor = Colors.white;
      }

      // Glow on larger particles
      if (baseR > 4.0) {
        final glowPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = pColor.withOpacity(opacity * 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(Offset(x, y), radius * 2.2, glowPaint);
      }

      paint.color = pColor.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius.clamp(0.5, 10.0), paint);
    }

    // Central flash (only in early progress)
    if (progress < 0.25) {
      final flashT = progress / 0.25;
      final flashPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white.withOpacity((1 - flashT) * 0.85);
      canvas.drawCircle(center, 22 * (1 - flashT) + 4, flashPaint);
    }

    // Energy ring expanding outward
    if (progress < 0.45) {
      final ringT = progress / 0.45;
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * (1 - ringT)
        ..color = const Color(0xFF2ECC71).withOpacity((1 - ringT) * 0.7);
      canvas.drawCircle(center, 15 + 50 * ringT, ringPaint);
    }
  }

  @override
  bool shouldRepaint(_BurstParticlesPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// KITCHEN ORDERS SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class KitchenOrdersScreen extends StatefulWidget {
  final String kitchenCode;
  final String kitchenName;
  final Color kitchenColor;

  const KitchenOrdersScreen({
    super.key,
    required this.kitchenCode,
    required this.kitchenName,
    required this.kitchenColor,
  });

  @override
  State<KitchenOrdersScreen> createState() => _KitchenOrdersScreenState();
}

class _KitchenOrdersScreenState extends State<KitchenOrdersScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  List<PendingOrder> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _loadOrders();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _orders = KitchenMockData.getOrdersForKitchen(widget.kitchenCode);
          _isLoading = false;
        });
      }
    });
  }

  int _totalPendingItems() {
    int pending = 0;
    for (var order in _orders) {
      for (var item in order.items) {
        if (item.status != ItemStatus.ready) pending++;
      }
    }
    return pending;
  }

  void _toggleItemStatus(PendingOrder order, OrderItem item) {
    HapticFeedback.lightImpact();
    setState(() {
      if (item.status == ItemStatus.ready) {
        item.status = ItemStatus.pending;
        item.endTime = null;
        order.isAllComplete = false;
      } else {
        item.status = ItemStatus.ready;
        item.endTime = _formatTime(DateTime.now());
        if (order.items.every((i) => i.status == ItemStatus.ready)) {
          order.isAllComplete = true;
        }
      }
    });
  }

  void _removeOrder(PendingOrder order) {
    if (mounted) {
      setState(() => _orders.remove(order));
    }
  }

  String _formatTime(DateTime dateTime) =>
      '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF5F0),
                Color(0xFFFFF0E6),
                Color(0xFFFFE8D9),
                Color(0xFFFFDBC8),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                ..._buildBackgroundElements(),
                FadeTransition(
                  opacity: CurvedAnimation(
                      parent: _fadeController, curve: Curves.easeOut),
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: _isLoading
                            ? _buildLoadingState()
                            : _buildOrdersList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundElements() {
    return [
      AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.kitchenColor
                        .withOpacity(0.06 * _pulseController.value),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildHeader() {
    final pendingCount = _totalPendingItems();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: widget.kitchenColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.kitchenColor.withOpacity(0.2),
                  widget.kitchenColor.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              widget.kitchenCode,
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: widget.kitchenColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.kitchenName,
              style: const TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D2D2D),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.kitchenColor,
                  widget.kitchenColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: widget.kitchenColor.withOpacity(0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$pendingCount',
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'pending',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 45,
            height: 45,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor:
              AlwaysStoppedAnimation<Color>(widget.kitchenColor),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading orders...',
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 17,
              color: widget.kitchenColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.kitchenColor.withOpacity(0.15),
                    widget.kitchenColor.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_outline_rounded,
                  size: 70, color: widget.kitchenColor),
            ),
            const SizedBox(height: 28),
            Text(
              'All Orders Completed!',
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: widget.kitchenColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Waiting for new orders...',
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 15,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return _OrderCompletionAnimator(
          order: order,
          isComplete: order.isAllComplete,
          onDismissed: () => _removeOrder(order),
          child: _buildOrderCard(order),
        );
      },
    );
  }

  Widget _buildOrderCard(PendingOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.92),
                  Colors.white.withOpacity(0.65),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTableHeader(order),
                _buildColumnHeaders(),
                ...order.items.asMap().entries.map(
                      (entry) =>
                      _buildItemRow(order, entry.value, entry.key),
                ),
                if (order.isAllComplete) _buildAllCompleteBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(PendingOrder order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.kitchenColor.withOpacity(0.08),
            widget.kitchenColor.withOpacity(0.02),
          ],
        ),
        border: const Border(
            bottom: BorderSide(color: Color(0xFFE8E8E8), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.kitchenColor.withOpacity(0.18),
                  widget.kitchenColor.withOpacity(0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.receipt_long_rounded,
                size: 18, color: widget.kitchenColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KOT #${order.kotNo}  ·  Table ${order.tableNo}',
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.waiterName}  ·  ${order.orderTime}  ·  ${order.customerName}',
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          if (order.isAllComplete)
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFF27AE60).withOpacity(0.3),
                    width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle,
                      size: 12, color: Color(0xFF27AE60)),
                  SizedBox(width: 5),
                  Text(
                    'DONE',
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF27AE60),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F8F8),
        border:
        Border(bottom: BorderSide(color: Color(0xFFE8E8E8), width: 1)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 5, child: _ColumnHeader('ITEM / REMARKS')),
          SizedBox(
              width: 44,
              child: Center(
                  child: _ColumnHeader('QTY', centered: true))),
          SizedBox(
              width: 72,
              child: Center(
                  child: _ColumnHeader('STATUS', centered: true))),
        ],
      ),
    );
  }

  Widget _buildItemRow(PendingOrder order, OrderItem item, int index) {
    final isReady = item.status == ItemStatus.ready;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isReady
            ? const Color(0xFF27AE60).withOpacity(0.05)
            : (index % 2 == 0
            ? Colors.white.withOpacity(0.4)
            : Colors.transparent),
        border: const Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: 3,
                  height: 30,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isReady
                        ? const Color(0xFF27AE60).withOpacity(0.5)
                        : widget.kitchenColor.withOpacity(0.4),
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontFamily: 'SpaceMono',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isReady
                              ? const Color(0xFFAAAAAA)
                              : const Color(0xFF2D2D2D),
                          decoration:
                          isReady ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (item.specialInstructions != null &&
                          item.specialInstructions!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.specialInstructions!,
                          style: TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isReady
                                ? Colors.orange.withOpacity(0.4)
                                : Colors.orange.shade800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 44,
            child: Center(
              child: Text(
                '${item.qty}',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isReady
                      ? const Color(0xFFAAAAAA)
                      : const Color(0xFF2D2D2D),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Center(
              child: GestureDetector(
                onTap: () => _toggleItemStatus(order, item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                      vertical: 9, horizontal: 10),
                  decoration: BoxDecoration(
                    gradient: isReady
                        ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2ECC71),
                        Color(0xFF1A9E52)
                      ],
                    )
                        : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        widget.kitchenColor.withOpacity(0.15),
                        widget.kitchenColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: isReady
                          ? const Color(0xFF27AE60).withOpacity(0.5)
                          : widget.kitchenColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: isReady
                        ? [
                      BoxShadow(
                        color: const Color(0xFF27AE60).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ]
                        : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child:
                      FadeTransition(opacity: anim, child: child),
                    ),
                    child: isReady
                        ? const Icon(Icons.check_rounded,
                        key: ValueKey('check'),
                        size: 20,
                        color: Colors.white)
                        : Icon(
                      Icons.radio_button_unchecked_rounded,
                      key: const ValueKey('circle'),
                      size: 19,
                      color: widget.kitchenColor.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllCompleteBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF27AE60).withOpacity(0.08),
        borderRadius:
        const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 18, color: Color(0xFF27AE60)),
            SizedBox(width: 8),
            Text(
              'ALL ITEMS COMPLETED',
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF27AE60),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COLUMN HEADER HELPER
// ─────────────────────────────────────────────────────────────────────────────
class _ColumnHeader extends StatelessWidget {
  final String text;
  final bool centered;

  const _ColumnHeader(this.text, {this.centered = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: centered ? TextAlign.center : TextAlign.start,
      style: const TextStyle(
        fontFamily: 'SpaceMono',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF888888),
        letterSpacing: 1.2,
      ),
    );
  }
}