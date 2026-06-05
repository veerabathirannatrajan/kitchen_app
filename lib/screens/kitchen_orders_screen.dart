import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../config/app_colors.dart';
import '../config/api_config.dart';
import '../models/pending_order.dart';
import '../models/order_item.dart';
import '../services/api_service.dart';
import '../widgets/button_3d.dart';
import '../widgets/order_completion_animator.dart';
import '../data/mock_orders.dart' as mock;

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

class _KitchenOrdersScreenState extends State<KitchenOrdersScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  final ApiService _apiService = ApiService();
  List<PendingOrder> _orders = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _loadOrders();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadOrders());
  }

  Future<void> _loadOrders() async {
    if (ApiConfig.useMockData) {
      // Use mock data - import from mock_orders.dart directly
      final mockOrders = mock.KitchenMockData.getOrdersForKitchen(widget.kitchenCode);
      if (mounted) setState(() {
        _orders = mockOrders.cast<PendingOrder>();
        _isLoading = false;
      });
    } else {
      // Use real API
      final orders = await _apiService.getPendingOrders(widget.kitchenCode);
      if (mounted) setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
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

  Future<void> _toggleItemStatus(PendingOrder order, OrderItem item) async {
    HapticFeedback.lightImpact();

    if (item.status == ItemStatus.ready) {
      setState(() { item.status = ItemStatus.pending; item.endTime = null; order.isAllComplete = false; });
    } else {
      if (!ApiConfig.useMockData) {
        await _apiService.setItemReady(
          outletCode: order.outletCode,
          kotNo: int.tryParse(order.kotNo) ?? 0,
          itemCode: item.itemCode,
          serialNo: item.serialNo,
          kitchenCode: widget.kitchenCode,
          readyBy: 'CHEF',
        );
      }
      setState(() {
        item.status = ItemStatus.ready;
        item.endTime = _formatTime(DateTime.now());
        if (order.items.every((i) => i.status == ItemStatus.ready)) order.isAllComplete = true;
      });
    }
  }

  void _removeOrder(PendingOrder order) {
    if (mounted) setState(() => _orders.remove(order));
  }

  String _formatTime(DateTime dateTime) => '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: AppColors.bgGradient, stops: [0.0, 0.3, 0.7, 1.0])),
          child: SafeArea(
            child: Stack(
              children: [
                _buildBackground(),
                FadeTransition(opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeOut), child: Column(children: [_buildHeader(), Expanded(child: _isLoading ? _buildLoading() : _buildOrdersList())])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(animation: _pulseController, builder: (context, child) {
      return Positioned(top: -50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [widget.kitchenColor.withOpacity(0.06 * _pulseController.value), Colors.transparent]))));
    });
  }

  Widget _buildHeader() {
    final pendingCount = _totalPendingItems();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 3))]),
      child: Row(children: [
        Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))]), child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => Navigator.pop(context), child: Padding(padding: const EdgeInsets.all(8), child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: widget.kitchenColor))))),
        const SizedBox(width: 12),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(gradient: LinearGradient(colors: [widget.kitchenColor.withOpacity(0.2), widget.kitchenColor.withOpacity(0.08)]), borderRadius: BorderRadius.circular(7)), child: Text(widget.kitchenCode, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 12, fontWeight: FontWeight.w700, color: widget.kitchenColor))),
        const SizedBox(width: 8),
        Expanded(child: Text(widget.kitchenName, style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark), overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [widget.kitchenColor, widget.kitchenColor.withOpacity(0.8)]), borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: widget.kitchenColor.withOpacity(0.35), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 3))]), child: Row(mainAxisSize: MainAxisSize.min, children: [Text('$pendingCount', style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white)), const SizedBox(width: 5), const Text('pending', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70, letterSpacing: 0.5))])),
      ]),
    );
  }

  Widget _buildLoading() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 45, height: 45, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(widget.kitchenColor))), const SizedBox(height: 20), Text('Loading orders...', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 17, color: widget.kitchenColor.withOpacity(0.8)))]));
  }

  Widget _buildOrdersList() {
    if (_orders.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.all(40), decoration: BoxDecoration(gradient: LinearGradient(colors: [widget.kitchenColor.withOpacity(0.15), widget.kitchenColor.withOpacity(0.05)]), shape: BoxShape.circle), child: Icon(Icons.check_circle_outline_rounded, size: 70, color: widget.kitchenColor)), const SizedBox(height: 28), Text('All Orders Completed!', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 23, fontWeight: FontWeight.w700, color: widget.kitchenColor)), const SizedBox(height: 10), const Text('Waiting for new orders...', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 15, color: Color(0xFF999999)))]));
    }
    return ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), itemCount: _orders.length, itemBuilder: (context, index) {
      final order = _orders[index];
      return OrderCompletionAnimator(order: order, isComplete: order.isAllComplete, onDismissed: () => _removeOrder(order), child: _buildOrderCard(order));
    });
  }

  Widget _buildOrderCard(PendingOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cardBorder, width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, spreadRadius: 1, offset: const Offset(0, 4))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withOpacity(0.92), Colors.white.withOpacity(0.65)]), borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildTableHeader(order),
            _buildColumnHeaders(),
            ...order.items.asMap().entries.map((entry) => _buildItemRow(order, entry.value, entry.key)),
            if (order.isAllComplete) _buildAllCompleteBanner(),
          ]),
        )),
      ),
    );
  }

  Widget _buildTableHeader(PendingOrder order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [widget.kitchenColor.withOpacity(0.08), widget.kitchenColor.withOpacity(0.02)]), border: const Border(bottom: BorderSide(color: AppColors.cardDivider, width: 1))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: [widget.kitchenColor.withOpacity(0.18), widget.kitchenColor.withOpacity(0.06)]), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.receipt_long_rounded, size: 18, color: widget.kitchenColor)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('KOT #${order.kotNo}  ·  Table ${order.memberCode}', style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 2),
          Text('${order.waiterDesc}  ·  ${order.createdDate}  ·  ${order.memberName}', style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
        ])),
        if (order.isAllComplete) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.statusReady.withOpacity(0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.statusReady.withOpacity(0.3), width: 1)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_circle, size: 12, color: AppColors.statusReady), SizedBox(width: 5), Text('DONE', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.statusReady, letterSpacing: 1))])),
      ]),
    );
  }

  Widget _buildColumnHeaders() {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: const BoxDecoration(color: Color(0xFFF8F8F8), border: Border(bottom: BorderSide(color: AppColors.cardDivider, width: 1))), child: const Row(children: [Expanded(flex: 5, child: _ColumnHeader('ITEM / REMARKS')), SizedBox(width: 44, child: Center(child: _ColumnHeader('QTY', centered: true))), SizedBox(width: 72, child: Center(child: _ColumnHeader('STATUS', centered: true)))]));
  }

  Widget _buildItemRow(PendingOrder order, OrderItem item, int index) {
    final isReady = item.status == ItemStatus.ready;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: isReady ? AppColors.statusReady.withOpacity(0.05) : (index % 2 == 0 ? Colors.white.withOpacity(0.4) : Colors.transparent), border: const Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(flex: 5, child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          AnimatedContainer(duration: const Duration(milliseconds: 280), width: 3, height: 30, margin: const EdgeInsets.only(right: 10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: isReady ? AppColors.statusReady.withOpacity(0.5) : widget.kitchenColor.withOpacity(0.4))),
          Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.itemName, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 14, fontWeight: FontWeight.w700, color: isReady ? const Color(0xFFAAAAAA) : AppColors.textDark, decoration: isReady ? TextDecoration.lineThrough : null)),
            if (item.remarks != null && item.remarks!.isNotEmpty) ...[const SizedBox(height: 2), Text(item.remarks!, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, fontWeight: FontWeight.w700, color: isReady ? Colors.orange.withOpacity(0.4) : Colors.orange.shade800), overflow: TextOverflow.ellipsis)],
          ])),
        ])),
        SizedBox(width: 44, child: Center(child: Text('${item.qty}', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 16, fontWeight: FontWeight.w700, color: isReady ? const Color(0xFFAAAAAA) : AppColors.textDark)))),
        SizedBox(width: 72, child: Center(child: GestureDetector(
          onTap: () => _toggleItemStatus(order, item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
            decoration: BoxDecoration(
              gradient: isReady ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2ECC71), Color(0xFF1A9E52)]) : LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [widget.kitchenColor.withOpacity(0.15), widget.kitchenColor.withOpacity(0.05)]),
              borderRadius: BorderRadius.circular(11), border: Border.all(color: isReady ? AppColors.statusReady.withOpacity(0.5) : widget.kitchenColor.withOpacity(0.3), width: 1.5),
              boxShadow: isReady ? [BoxShadow(color: AppColors.statusReady.withOpacity(0.3), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 3))] : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: AnimatedSwitcher(duration: const Duration(milliseconds: 200), transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: FadeTransition(opacity: anim, child: child)), child: isReady ? const Icon(Icons.check_rounded, key: ValueKey('check'), size: 20, color: Colors.white) : Icon(Icons.radio_button_unchecked_rounded, key: const ValueKey('circle'), size: 19, color: widget.kitchenColor.withOpacity(0.6))),
          ),
        ))),
      ]),
    );
  }

  Widget _buildAllCompleteBanner() {
    return Container(padding: const EdgeInsets.symmetric(vertical: 11), decoration: BoxDecoration(color: AppColors.statusReady.withOpacity(0.08), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))), child: const Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, size: 18, color: AppColors.statusReady), SizedBox(width: 8), Text('ALL ITEMS COMPLETED', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.statusReady, letterSpacing: 1.5))])));
  }
}

class _ColumnHeader extends StatelessWidget {
  final String text;
  final bool centered;
  const _ColumnHeader(this.text, {this.centered = false});
  @override
  Widget build(BuildContext context) => Text(text, textAlign: centered ? TextAlign.center : TextAlign.start, style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1.2));
}