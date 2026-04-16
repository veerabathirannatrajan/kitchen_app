import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/shared.dart';
import 'chef_screen.dart';
import 'waiter_screen.dart';
import 'three_d_viewer_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _spin;
  late AnimationController _fade;
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _spin  = AnimationController(vsync: this, duration: const Duration(seconds: 25))..repeat();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _fade  = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    Future.delayed(const Duration(milliseconds: 200), () => _fade.forward());
  }

  @override
  void dispose() {
    _spin.dispose();
    _fade.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _go(Widget page) {
    Navigator.pushReplacement(context, PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, a, __) => page,
      transitionsBuilder: (_, a, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
        child: child,
      ),
    ));
  }

  Widget _build3DPreviewButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ThreeDViewerScreen(
                title: 'FRIED RICE',
                modelUrl: 'https://raw.githubusercontent.com/veerabathirannatrajan/kitchen_app/master/assets/threeD/friedrice.glb',
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF6B35).withOpacity(0.15),
                const Color(0xFFFF6B35).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.view_in_ar_rounded,
                  size: 18,
                  color: Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'VIEW 3D PREVIEW',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF6B35),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFFFF6B35),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      body: AppBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _fade, curve: Curves.easeOut),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // ── Logo cluster ──
                Stack(alignment: Alignment.center, children: [
                  // Outer spinning ring
                  AnimatedBuilder(animation: _spin, builder: (_, __) =>
                      Transform.rotate(angle: _spin.value * 2 * math.pi,
                          child: SizedBox(width: 160, height: 160,
                              child: CustomPaint(painter: _DashedRing(
                                  color: const Color(0xFFFF6B35).withOpacity(0.25), dashes: 24))))),
                  // Inner glow
                  AnimatedBuilder(animation: _pulse, builder: (_, __) =>
                      Container(width: 100, height: 100,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                              boxShadow: [BoxShadow(
                                  color: const Color(0xFFFF6B35).withOpacity(0.15 + _pulse.value * 0.2),
                                  blurRadius: 40 + _pulse.value * 20)]))),
                  // Logo card
                  ClipOval(child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                          width: 88, height: 88,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0x25FFFFFF),
                              border: Border.all(color: const Color(0x55FF6B35), width: 1.5)),
                          child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 34)))))),
                ]),
                const SizedBox(height: 28),
                // Title
                const Text('KitchX', style: TextStyle(
                    fontFamily: 'SpaceMono', fontSize: 36, fontWeight: FontWeight.w700,
                    color: Color(0xFFF0F0FF), letterSpacing: 10)),
                const SizedBox(height: 6),
                const Text('KITCHEN  COMMAND  CENTER', style: TextStyle(
                    fontFamily: 'SpaceMono', fontSize: 9, color: Color(0xFF8888AA), letterSpacing: 4)),
                const Spacer(flex: 2),
                // ── Role Cards ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Text('— SIGN IN AS —', style: TextStyle(
                          fontFamily: 'SpaceMono', fontSize: 9, color: Color(0xFF44445A), letterSpacing: 3)),
                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(child: _RoleCard(
                          imagePath: 'assets/images/waiter.jpg',
                          title: 'WAITER',
                          subtitle: 'Take orders\ntrack tables',
                          color: const Color(0xFF4D9FFF),
                          onTap: () => _go(const WaiterScreen()),
                        )),
                        const SizedBox(width: 14),
                        Expanded(child: _RoleCard(
                          imagePath: 'assets/images/chef.jpg',
                          title: 'CHEF',
                          subtitle: 'Cook orders\nmark done',
                          color: const Color(0xFFFF6B35),
                          onTap: () => _go(const ChefScreen()),
                        )),
                      ]),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // 3D Preview Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: _build3DPreviewButton(),
                ),

                const Spacer(),

                // Status bar
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    PulseDot(color: const Color(0xFF00E5A0)),
                    const SizedBox(width: 8),
                    const Text('LIVE  ·  DB: MAXIM  ·  115.246.237.26:7125',
                        style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9,
                            color: Color(0xFF44445A), letterSpacing: 1.5)),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String imagePath, title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _RoleCard({required this.imagePath, required this.title, required this.subtitle,
    required this.color, required this.onTap});
  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late AnimationController _imageFloatCtrl;
  late AnimationController _rotateCtrl;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _imageFloatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true);
    _rotateCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _imageFloatCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        setState(() => _hovered = true);
      },
      onTapUp: (_) {
        _ctrl.reverse();
        setState(() => _hovered = false);
        widget.onTap();
      },
      onTapCancel: () {
        _ctrl.reverse();
        setState(() => _hovered = false);
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(scale: 1 - _ctrl.value * 0.04, child: child),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: _hovered ? widget.color.withOpacity(0.12) : const Color(0x18FFFFFF),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _hovered ? widget.color.withOpacity(0.5) : widget.color.withOpacity(0.25),
                  width: 1,
                ),
                boxShadow: [BoxShadow(
                    color: widget.color.withOpacity(_hovered ? 0.2 : 0.08),
                    blurRadius: 24, offset: const Offset(0, 6))],
              ),
              child: Column(children: [
                // Modern 3D Image Container with Glassmorphism
                AnimatedBuilder(
                  animation: Listenable.merge([_imageFloatCtrl, _rotateCtrl]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _imageFloatCtrl.value * -5),
                      child: Transform.rotate(
                        angle: _rotateCtrl.value * 0.02 * math.pi,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        // Outer glow
                        BoxShadow(
                          color: widget.color.withOpacity(_hovered ? 0.5 : 0.25),
                          blurRadius: 25,
                          spreadRadius: _hovered ? 6 : 3,
                        ),
                        // 3D shadow
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Main Image with border radius
                        Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.color.withOpacity(0.6),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              widget.imagePath,
                              width: 85,
                              height: 85,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 85,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        widget.color.withOpacity(0.3),
                                        widget.color.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      widget.title == 'WAITER' ? Icons.person_outline : Icons.restaurant,
                                      color: widget.color,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Glassmorphism overlay (light)
                        ClipOval(
                          child: Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.08),
                                  Colors.white.withOpacity(0.02),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 3D Highlight effect
                        ClipOval(
                          child: Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: const Alignment(-0.4, -0.4),
                                radius: 0.7,
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Subtle inner shadow for depth
                        ClipOval(
                          child: Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.15),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Edge reflection
                        ClipOval(
                          child: Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(widget.title, style: TextStyle(
                    fontFamily: 'SpaceMono', fontSize: 13, fontWeight: FontWeight.w700,
                    color: widget.color, letterSpacing: 2)),
                const SizedBox(height: 6),
                Text(widget.subtitle, textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF8888AA), height: 1.5)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRing extends CustomPainter {
  final Color color;
  final int dashes;
  const _DashedRing({required this.color, required this.dashes});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;
    final p = Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke;
    for (int i = 0; i < dashes; i++) {
      final a1 = (i * 2 * math.pi / dashes);
      final a2 = a1 + (math.pi / dashes) * 0.7;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), a1, a2 - a1, false, p);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}