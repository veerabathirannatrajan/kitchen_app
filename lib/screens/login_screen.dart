import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../config/app_colors.dart';
import '../config/responsive.dart';
import '../services/auth_service.dart';
import '../widgets/chef_3d_viewer.dart';
import 'kitchen_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _rotateController;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat(reverse: true);
    _rotateController = AnimationController(vsync: this, duration: const Duration(seconds: 25))..repeat();
    _loadSavedUsername();
  }

  Future<void> _loadSavedUsername() async {
    final saved = await AuthService.getSavedUsername();
    if (saved.isNotEmpty) _usernameController.text = saved;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPress == null || now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Press back again to exit', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 12)),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _errorMessage = null; });
    HapticFeedback.mediumImpact();

    final response = await AuthService.validateUser(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (AuthService.isLoginSuccessful(response)) {
      await AuthService.saveUsername(_usernameController.text.trim());
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const KitchenSelectionScreen()));
      }
    } else {
      setState(() { _errorMessage = AuthService.getErrorMessage(response); });
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final rs = Responsive.fontSize(context, 1.0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && await _onWillPop() && context.mounted) SystemNavigator.pop();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.bgGradient,
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                _buildBackground(),
                FadeTransition(
                  opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 28 * rs),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 30 * rs),
                            // 3D Chef
                            AnimatedBuilder(
                              animation: _floatController,
                              builder: (_, child) => Transform.translate(
                                offset: Offset(0, _floatController.value * -8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: AppColors.primaryOrange.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 10),
                                      BoxShadow(color: AppColors.primaryOrange.withValues(alpha: 0.1), blurRadius: 60, spreadRadius: 15),
                                    ],
                                  ),
                                  child: const Chef3DViewer(size: 260, autoRotate: true),
                                ),
                              ),
                            ),
                            SizedBox(height: 16 * rs),
                            // Title
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF8C42), Color(0xFFFFA366)]).createShader(bounds),
                              child: Text('KitchX', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 36 * rs, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 6)),
                            ),
                            SizedBox(height: 4 * rs),
                            Text('KITCHEN DISPLAY SYSTEM', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9 * rs, fontWeight: FontWeight.w500, color: AppColors.textLight, letterSpacing: 3)),
                            SizedBox(height: 28 * rs),
                            // Username
                            _buildTextField(rs, _usernameController, 'Username', Icons.person_outline_rounded, false, (v) => (v == null || v.trim().isEmpty) ? 'Enter username' : null),
                            SizedBox(height: 12 * rs),
                            // Password
                            _buildTextField(rs, _passwordController, 'Password', Icons.lock_outline_rounded, _obscurePassword, (v) => (v == null || v.trim().isEmpty) ? 'Enter password' : null,
                              suffix: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.textLight), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                              onSubmitted: (_) => _login(),
                            ),
                            // Error
                            if (_errorMessage != null)
                              Padding(
                                padding: EdgeInsets.only(top: 6 * rs),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.error_outline, size: 14 * rs, color: AppColors.statusPending),
                                  SizedBox(width: 6 * rs),
                                  Flexible(child: Text(_errorMessage!, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11 * rs, color: AppColors.statusPending))),
                                ]),
                              ),
                            SizedBox(height: 22 * rs),
                            // Login Button
                            _buildLoginButton(rs),
                            SizedBox(height: 30 * rs),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(double rs, TextEditingController controller, String hint, IconData icon, bool obscure,
      String? Function(String?)? validator, {Widget? suffix, void Function(String)? onSubmitted}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      onFieldSubmitted: onSubmitted,
      style: TextStyle(fontFamily: 'SpaceMono', fontSize: 14 * rs, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'SpaceMono', fontSize: 13 * rs, color: AppColors.textLight),
        prefixIcon: Icon(icon, size: 20 * rs, color: AppColors.primaryOrange),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.85),
        contentPadding: EdgeInsets.symmetric(vertical: 15 * rs, horizontal: 16 * rs),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14 * rs), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14 * rs), borderSide: BorderSide(color: AppColors.cardBorder, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14 * rs), borderSide: BorderSide(color: AppColors.primaryOrange, width: 2)),
      ),
      validator: validator,
    );
  }

  Widget _buildLoginButton(double rs) {
    return GestureDetector(
      onTap: _isLoading ? null : _login,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 17 * rs),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)]),
          borderRadius: BorderRadius.circular(18 * rs),
          boxShadow: [BoxShadow(color: AppColors.primaryOrange.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 8))],
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(width: 22 * rs, height: 22 * rs, child: const CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.login_rounded, size: 20, color: Colors.white),
            SizedBox(width: 10 * rs),
            Text('SIGN IN', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 15 * rs, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 4)),
          ]),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(children: [
      AnimatedBuilder(
        animation: _pulseController,
        builder: (_, __) => Positioned(
          top: -100, right: -100,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppColors.primaryOrange.withValues(alpha: 0.08 * _pulseController.value), Colors.transparent]),
            ),
          ),
        ),
      ),
      AnimatedBuilder(
        animation: _pulseController,
        builder: (_, __) => Positioned(
          bottom: -50, left: -50,
          child: Container(
            width: 250, height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppColors.primaryOrange.withValues(alpha: 0.06 * (1 - _pulseController.value)), Colors.transparent]),
            ),
          ),
        ),
      ),
      AnimatedBuilder(
        animation: _rotateController,
        builder: (_, __) => Positioned(
          top: 100, right: -50,
          child: Transform.rotate(
            angle: _rotateController.value * 2 * math.pi,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: _Ring(color: AppColors.primaryOrange.withValues(alpha: 0.12)),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _Ring extends CustomPainter {
  final Color color;
  _Ring({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0;
    for (int i = 0; i < 36; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2 - 5),
        (i * 10) * math.pi / 180,
        5 * math.pi / 180,
        false,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}