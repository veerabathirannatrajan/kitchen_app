import 'dart:ui';
import 'package:flutter/material.dart';

// ─── Glass Card ──────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? bgColor;
  final double blur;
  final List<BoxShadow>? shadows;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.bgColor,
    this.blur = 12,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor ?? const Color(0x1AFFFFFF),
              borderRadius: borderRadius ?? BorderRadius.circular(20),
              border: Border.all(
                color: borderColor ?? const Color(0x30FFFFFF),
                width: 1,
              ),
              boxShadow: shadows,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── Neon Badge ──────────────────────────────────────────────────────────────
class NeonBadge extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const NeonBadge({
    super.key,
    required this.text,
    required this.color,
    this.fontSize = 9,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35), width: 0.8),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 6)],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'SpaceMono',
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Glowing Dot ─────────────────────────────────────────────────────────────
class GlowDot extends StatelessWidget {
  final Color color;
  final double size;
  const GlowDot({super.key, required this.color, this.size = 7});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle, color: color,
        boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 6, spreadRadius: 1)],
      ),
    );
  }
}

// ─── Animated Pulse Dot ──────────────────────────────────────────────────────
class PulseDot extends StatefulWidget {
  final Color color;
  const PulseDot({super.key, required this.color});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 8, height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.lerp(widget.color.withOpacity(0.4), widget.color, _anim.value),
          boxShadow: [BoxShadow(
            color: widget.color.withOpacity(0.3 + _anim.value * 0.4),
            blurRadius: 4 + _anim.value * 6,
          )],
        ),
      ),
    );
  }
}

// ─── Gradient Background ─────────────────────────────────────────────────────
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFF080810)),
        // Radial blobs
        Positioned(top: -60, left: -60,
          child: _Blob(color: const Color(0x18FF6B35), size: 280)),
        Positioned(top: 200, right: -80,
          child: _Blob(color: const Color(0x144D9FFF), size: 220)),
        Positioned(bottom: 100, left: 40,
          child: _Blob(color: const Color(0x1200E5A0), size: 200)),
        Positioned(bottom: -40, right: -40,
          child: _Blob(color: const Color(0x18B66DFF), size: 240)),
        // Grid
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x0DFFFFFF)..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 44) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 44) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

// ─── Section Header ──────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'SpaceMono',
          fontSize: 10,
          color: Color(0xFF44445A),
          letterSpacing: 2.5,
        ),
      ),
    );
  }
}

// ─── Tap Scale Wrapper ───────────────────────────────────────────────────────
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const TapScale({super.key, required this.child, required this.onTap});

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
