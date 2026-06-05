import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class _Button3DState extends State<Button3D> with SingleTickerProviderStateMixin {
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
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_topColor, widget.color]),
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