import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:webview_flutter/webview_flutter.dart';
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

  late WebViewController _grillController;
  late WebViewController _friedRiceController;

  final List<Kitchen> _kitchens = [
    Kitchen(code: 'MK', name: 'Main Kitchen', color: const Color(0xFFFF6B35), imagePath: 'assets/kitchens/MK.jpg'),
    Kitchen(code: 'K1', name: 'Continental Kitchen', color: const Color(0xFF4D9FFF), imagePath: 'assets/kitchens/K1.jpg'),
    Kitchen(code: 'K5', name: 'Tandoori Kitchen', color: const Color(0xFFE74C3C), imagePath: 'assets/kitchens/K5.jpg'),
    Kitchen(code: 'K11', name: 'Arusuvai Arasu Fresh Foods', color: const Color(0xFF27AE60), imagePath: 'assets/kitchens/K11.jpg'),
    Kitchen(code: 'K4', name: 'New Chinese', color: const Color(0xFF8E44AD), imagePath: 'assets/kitchens/K4.png'),
    Kitchen(code: 'K22', name: 'New Continental Kitchen', color: const Color(0xFFD35400), imagePath: 'assets/kitchens/K22.jpg'),
    Kitchen(code: 'K23', name: 'New Vegetarian Kitchen', color: const Color(0xFF16A085), imagePath: 'assets/kitchens/K23.jpg'),
  ];

  static const String grillModelUrl = 'https://raw.githubusercontent.com/veerabathirannatrajan/kitchen_app/master/assets/threeD/grill.glb';
  static const String friedRiceModelUrl = 'https://raw.githubusercontent.com/veerabathirannatrajan/kitchen_app/master/assets/threeD/friedrice.glb';

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

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _initWebViews();
  }

  void _initWebViews() {
    _grillController = _createWebViewController(grillModelUrl);
    _friedRiceController = _createWebViewController(friedRiceModelUrl);
  }

  WebViewController _createWebViewController(String modelUrl) {
    final String html = '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { 
                background: transparent !important;
                overflow: hidden;
            }
            model-viewer {
                width: 100%;
                height: 100vh;
                background: transparent;
                --poster-color: transparent;
            }
        </style>
        <script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/4.0.0/model-viewer.min.js"></script>
    </head>
    <body>
        <model-viewer 
            src="$modelUrl"
            alt="3D Model"
            auto-rotate
            camera-controls
            camera-orbit="0deg 75deg 2.5m"
            exposure="1.5"
            shadow-intensity="0.8"
            environment-image="neutral"
            loading="eager"
            style="background: transparent;">
        </model-viewer>
    </body>
    </html>
    ''';

    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString(html);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
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
                _build3DBackgroundModels(),
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _fadeController,
                    curve: Curves.easeOut,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: _buildKitchenGrid(),
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
                    const Color(0xFFFF6B35).withOpacity(0.06 * _pulseController.value),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      ),
      AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF8C42).withOpacity(0.06 * (1 - _pulseController.value)),
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

  Widget _build3DBackgroundModels() {
    return Stack(
      children: [
        // Grill model - Bottom Right Corner
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Positioned(
              bottom: 10,
              right: 10,
              child: Transform.translate(
                offset: Offset(0, _floatController.value * -8),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: WebViewWidget(controller: _grillController),
                  ),
                ),
              ),
            );
          },
        ),
        // Fried Rice model - Top Left Corner
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Positioned(
              top: 60,
              left: 10,
              child: Transform.translate(
                offset: Offset(0, _floatController.value * 8),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4D9FFF).withOpacity(0.12),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: WebViewWidget(controller: _friedRiceController),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.restaurant_menu_rounded,
                      size: 16,
                      color: Color(0xFFFF6B35),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'SELECT KITCHEN',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFFFF6B35),
                Color(0xFFFF8C42),
              ],
            ).createShader(bounds),
            child: const Text(
              'Available Kitchens',
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_kitchens.length} kitchens ready for service',
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 12,
              color: const Color(0xFF888888).withOpacity(0.8),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: _kitchens.length,
        itemBuilder: (context, index) {
          return _buildKitchenCard(_kitchens[index]);
        },
      ),
    );
  }

  Widget _buildKitchenCard(Kitchen kitchen) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KitchenOrdersScreen(
                kitchenCode: kitchen.code,
                kitchenName: kitchen.name,
                kitchenColor: kitchen.color,
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.85),
                    Colors.white.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kitchen.color.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kitchen Image - FIXED EQUAL SIZE FOR ALL
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: kitchen.color.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          kitchen.imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    kitchen.color.withOpacity(0.2),
                                    kitchen.color.withOpacity(0.05),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.kitchen_rounded,
                                  size: 50,
                                  color: kitchen.color.withOpacity(0.5),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Kitchen Info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kitchen.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            kitchen.code,
                            style: TextStyle(
                              fontFamily: 'SpaceMono',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: kitchen.color,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          kitchen.name,
                          style: const TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 22, // INCREASED FONT SIZE
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2D2D2D),
                            height: 1.2,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Kitchen {
  final String code;
  final String name;
  final Color color;
  final String imagePath;

  Kitchen({
    required this.code,
    required this.name,
    required this.color,
    required this.imagePath,
  });
}