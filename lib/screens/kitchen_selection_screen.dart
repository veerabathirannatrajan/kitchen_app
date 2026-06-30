import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'dart:ui';
import '../config/app_colors.dart';
import '../config/responsive.dart';
import '../services/api_service.dart';
import 'connection_status_screen.dart';
import 'kitchen_orders_screen.dart';

class KitchenSelectionScreen extends StatefulWidget {
  const KitchenSelectionScreen({super.key});

  @override
  State<KitchenSelectionScreen> createState() => _KitchenSelectionScreenState();
}

class _KitchenSelectionScreenState extends State<KitchenSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _floatController;

  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _kitchens = [];
  bool _isLoading = true;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();
  bool _showHeader = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))..repeat(reverse: true);
    _scrollController.addListener(_onScroll);
    _loadKitchens();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > 120 && _showHeader) {
      setState(() => _showHeader = false);
    } else if (_scrollController.position.pixels <= 120 && !_showHeader) {
      setState(() => _showHeader = true);
    }
  }

  Future<void> _loadKitchens() async {
    try {
      final kitchens = await _apiService.getKitchens();
      if (mounted) {
        kitchens.sort((a, b) {
          final aHas = _kitchenHasOrders(a['KitchenCode']?.toString() ?? '');
          final bHas = _kitchenHasOrders(b['KitchenCode']?.toString() ?? '');
          if (aHas && !bHas) return -1;
          if (!aHas && bHas) return 1;
          return (a['KitchenDesc']?.toString() ?? '').compareTo(b['KitchenDesc']?.toString() ?? '');
        });
        setState(() { _kitchens = kitchens; _isLoading = false; _errorMessage = null; });
      }
    } catch (e) {
      if (mounted) setState(() { _errorMessage = 'Failed to load kitchens. Check your connection.'; _isLoading = false; });
    }
  }

  Future<void> _onRefresh() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    await _loadKitchens();
  }

  bool _kitchenHasOrders(String code) {
    const withOrders = {'BA', 'K1', 'K11', 'K20', 'K22', 'K23', 'K4', 'K5', 'MK', 'SN'};
    return withOrders.contains(code);
  }

  String _getImagePath(String code) => 'assets/kitchens/$code.jpg';

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _floatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) { if (!didPop) Navigator.pop(context); },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: AppColors.bgGradient, stops: [0.0, 0.3, 0.7, 1.0])),
          child: SafeArea(
            child: Stack(
              children: [
                _buildBackground(),
                _build3DModels(),
                FadeTransition(opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeOut), child: Column(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _showHeader ? null : 0,
                    child: _showHeader ? _buildHeader() : const SizedBox.shrink(),
                  ),
                  if (!_showHeader)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: Responsive.fontSize(context, 20), vertical: Responsive.fontSize(context, 8)),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))]),
                      child: Row(children: [
                        GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.arrow_back_ios_new_rounded, size: Responsive.fontSize(context, 18), color: AppColors.primaryOrange)),
                        SizedBox(width: Responsive.fontSize(context, 12)),
                        Text('${_kitchens.length} Kitchens', style: TextStyle(fontFamily: 'SpaceMono', fontSize: Responsive.fontSize(context, 16), fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        const Spacer(),
                        GestureDetector(onTap: _onRefresh, child: Icon(Icons.refresh_rounded, size: Responsive.fontSize(context, 20), color: AppColors.primaryOrange)),
                      ]),
                    ),
                  Expanded(child: _buildBody()),
                ])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(children: [
      AnimatedBuilder(animation: _pulseController, builder: (_, __) => Positioned(top: -50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.primaryOrange.withValues(alpha: 0.06 * _pulseController.value), Colors.transparent]))))),
      AnimatedBuilder(animation: _pulseController, builder: (_, __) => Positioned(bottom: -50, left: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.primaryOrange.withValues(alpha: 0.06 * (1 - _pulseController.value)), Colors.transparent]))))),
    ]);
  }

  Widget _build3DModels() {
    return Stack(children: [
      // Chef2 - Top Right (User can rotate)
      Positioned(
        top: 4, right: 17,
        child: SizedBox(
          width: 170, height: 170,
          child: ModelViewer(
            src: 'assets/threeD/chef2.glb',
            alt: "Chef 3D Model",
            autoPlay: true,
            autoRotate: false,
            cameraControls: true,
            disableZoom: true,
            disableTap: true,
            backgroundColor: Colors.transparent,
            ar: false,
            arModes: [],
            iosSrc: '',
            exposure: 1.5,
            shadowIntensity: 1.0,
            environmentImage: '',
          ),
        ),
      ),
      // Grill - Bottom Right (Auto-rotate only)
      AnimatedBuilder(
        animation: _floatController,
        builder: (_, __) => Positioned(
          bottom: 20, right: 20,
          child: Transform.translate(
            offset: Offset(0, _floatController.value * -8),
            child: IgnorePointer(
              child: Container(
                width: 170, height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.primaryOrange.withValues(alpha: 0.10), blurRadius: 30, spreadRadius: 5)],
                ),
                child: ClipOval(
                  child: ModelViewer(
                    src: 'assets/threeD/grill.glb',
                    alt: "Grill 3D Model",
                    autoPlay: true,
                    autoRotate: true,
                    cameraControls: false,
                    disableZoom: true,
                    disableTap: true,
                    backgroundColor: Colors.transparent,
                    ar: false,
                    arModes: [],
                    iosSrc: '',
                    exposure: 1.5,
                    shadowIntensity: 0.8,
                    environmentImage: '',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Responsive.fontSize(context, 20), Responsive.fontSize(context, 12), Responsive.fontSize(context, 20), Responsive.fontSize(context, 12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(Responsive.fontSize(context, 15)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))]), child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(Responsive.fontSize(context, 15)), onTap: () => Navigator.pop(context), child: Container(padding: EdgeInsets.all(Responsive.fontSize(context, 10)), child: Icon(Icons.arrow_back_ios_new_rounded, size: Responsive.fontSize(context, 18), color: const Color(0xFF666666)))))),
          SizedBox(width: Responsive.fontSize(context, 10)),
          Container(padding: EdgeInsets.symmetric(horizontal: Responsive.fontSize(context, 14), vertical: Responsive.fontSize(context, 6)), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(Responsive.fontSize(context, 30))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.restaurant_menu_rounded, size: Responsive.fontSize(context, 14), color: AppColors.primaryOrange), SizedBox(width: Responsive.fontSize(context, 6)), Text('SELECT KITCHEN', style: TextStyle(fontFamily: 'SpaceMono', fontSize: Responsive.fontSize(context, 10), fontWeight: FontWeight.w600, color: const Color(0xFF666666), letterSpacing: 2))])),
          const Spacer(),
// Settings Gear Icon
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConnectionStatusScreen()),
              );
            },
            child: Container(
              padding: EdgeInsets.all(Responsive.fontSize(context, 10)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(Responsive.fontSize(context, 12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.settings_rounded, size: Responsive.fontSize(context, 18), color: const Color(0xFF666666)),
            ),
          ),
          const Spacer(),

          // Refresh button in header
          GestureDetector(
            onTap: _onRefresh,
            child: Container(
              padding: EdgeInsets.all(Responsive.fontSize(context, 10)),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(Responsive.fontSize(context, 12)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]),
              child: Icon(Icons.refresh_rounded, size: Responsive.fontSize(context, 18), color: AppColors.primaryOrange),
            ),
          ),
        ]),
        SizedBox(height: Responsive.fontSize(context, 16)),
        ShaderMask(shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.primaryOrange, Color(0xFFFF8C42)]).createShader(bounds), child: Text('Available Kitchens', style: TextStyle(fontFamily: 'SpaceMono', fontSize: Responsive.fontSize(context, 26), fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2))),
        SizedBox(height: Responsive.fontSize(context, 6)),
        Text('${_kitchens.length} kitchens ready', style: TextStyle(fontFamily: 'SpaceMono', fontSize: Responsive.fontSize(context, 11), color: const Color(0xFF888888).withValues(alpha: 0.8), letterSpacing: 1)),
      ]),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 45, height: 45, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryOrange))), SizedBox(height: Responsive.fontSize(context, 20)), Text('Loading kitchens...', style: TextStyle(fontFamily: 'SpaceMono', fontSize: Responsive.fontSize(context, 17), color: AppColors.primaryOrange.withValues(alpha: 0.8)))]));

    if (_errorMessage != null) return Center(child: Padding(padding: EdgeInsets.all(Responsive.fontSize(context, 40)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(padding: EdgeInsets.all(Responsive.fontSize(context, 30)), decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.wifi_off_rounded, size: Responsive.fontSize(context, 50), color: AppColors.primaryRed)),
      SizedBox(height: Responsive.fontSize(context, 20)),
      Text(_errorMessage!, style: TextStyle(fontFamily: 'SpaceMono', fontSize: Responsive.fontSize(context, 14), color: AppColors.textMedium), textAlign: TextAlign.center),
      SizedBox(height: Responsive.fontSize(context, 24)),
      GestureDetector(
        onTap: () { setState(() { _isLoading = true; _errorMessage = null; }); _loadKitchens(); },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: Responsive.fontSize(context, 30), vertical: Responsive.fontSize(context, 14)),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryOrange, AppColors.primaryOrange.withValues(alpha: 0.8)]), borderRadius: BorderRadius.circular(Responsive.fontSize(context, 16)), boxShadow: [BoxShadow(color: AppColors.primaryOrange.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]),
          child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.refresh_rounded, size: Responsive.fontSize(context, 18), color: Colors.white), SizedBox(width: Responsive.fontSize(context, 8)), Text('RETRY', style: TextStyle(fontFamily: 'SpaceMono', fontSize: Responsive.fontSize(context, 14), fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2))]),
        ),
      ),
    ])));

    if (_kitchens.isEmpty) return Center(child: Text('No kitchens available', style: TextStyle(fontFamily: 'SpaceMono', fontSize: Responsive.fontSize(context, 16), color: AppColors.textLight)));

    return RefreshIndicator(
      color: AppColors.primaryOrange,
      onRefresh: _onRefresh,
      child: _buildKitchenGrid(),
    );
  }

  Widget _buildKitchenGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.fontSize(context, 16)),
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(top: Responsive.fontSize(context, 8), bottom: Responsive.fontSize(context, 20)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: Responsive.fontSize(context, 14), mainAxisSpacing: Responsive.fontSize(context, 14), childAspectRatio: 0.82),
        itemCount: _kitchens.length,
        itemBuilder: (context, index) => _buildKitchenCard(_kitchens[index]),
      ),
    );
  }

  Widget _buildKitchenCard(Map<String, dynamic> kitchenData) {
    final code = kitchenData['KitchenCode']?.toString() ?? '';
    final name = kitchenData['KitchenDesc']?.toString() ?? '';
    final color = _getKitchenColor(code);
    final hasOrders = _kitchenHasOrders(code);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(Responsive.fontSize(context, 22)),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => KitchenOrdersScreen(kitchenCode: code, kitchenName: name, kitchenColor: color))),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Responsive.fontSize(context, 22)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withValues(alpha: 0.85), Colors.white.withValues(alpha: 0.5)]), borderRadius: BorderRadius.circular(Responsive.fontSize(context, 22)), border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 4))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 3, child: Stack(children: [
                  Container(margin: EdgeInsets.all(Responsive.fontSize(context, 8)), decoration: BoxDecoration(borderRadius: BorderRadius.circular(Responsive.fontSize(context, 14)), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 2))]), child: ClipRRect(borderRadius: BorderRadius.circular(Responsive.fontSize(context, 14)), child: Image.asset(_getImagePath(code), fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (context, error, stackTrace) => Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)])), child: Center(child: Icon(Icons.kitchen_rounded, size: Responsive.fontSize(context, 35), color: color.withValues(alpha: 0.5))))))),
                  if (hasOrders) Positioned(top: Responsive.fontSize(context, 12), right: Responsive.fontSize(context, 12), child: Container(padding: EdgeInsets.symmetric(horizontal: Responsive.fontSize(context, 8), vertical: Responsive.fontSize(context, 3)), decoration: BoxDecoration(color: AppColors.primaryOrange, borderRadius: BorderRadius.circular(Responsive.fontSize(context, 10)), boxShadow: [BoxShadow(color: AppColors.primaryOrange.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))]), child: Text('LIVE', style: TextStyle(fontFamily: 'SpaceMono', fontSize: Responsive.fontSize(context, 8), fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)))),
                ])),
                Padding(padding: EdgeInsets.fromLTRB(Responsive.fontSize(context, 12), Responsive.fontSize(context, 6), Responsive.fontSize(context, 12), Responsive.fontSize(context, 12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(padding: EdgeInsets.symmetric(horizontal: Responsive.fontSize(context, 8), vertical: Responsive.fontSize(context, 3)), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(Responsive.fontSize(context, 10))), child: Text(code, style: TextStyle(fontFamily: 'SpaceMono', fontSize: Responsive.fontSize(context, 12), fontWeight: FontWeight.w700, color: color, letterSpacing: 1))),
                  SizedBox(height: Responsive.fontSize(context, 6)),
                  Text(name, style: TextStyle(fontFamily: 'SpaceMono', fontSize: Responsive.fontSize(context, 17), fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.15), maxLines: 3, overflow: TextOverflow.ellipsis),
                ])),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Color _getKitchenColor(String code) {
    final colors = [const Color(0xFFFF6B35), const Color(0xFF4D9FFF), const Color(0xFFE74C3C), const Color(0xFF27AE60), const Color(0xFF8E44AD), const Color(0xFFD35400), const Color(0xFF16A085), const Color(0xFF2ECC71), const Color(0xFFE67E22), const Color(0xFF3498DB), const Color(0xFF9B59B6), const Color(0xFF1ABC9C)];
    return colors[code.hashCode.abs() % colors.length];
  }
}