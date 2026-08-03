import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../config/app_colors.dart';
import '../config/api_config.dart';
import '../config/kds_config.dart';
import '../models/pending_order.dart';
import '../models/order_item.dart';
import '../services/api_service.dart';
import '../config/responsive.dart';
import '../widgets/order_completion_animator.dart';
import '../data/mock_orders.dart' as mock;

class KitchenOrdersScreen extends StatefulWidget {
  final String kitchenCode;
  final String kitchenName;
  final Color kitchenColor;

  const KitchenOrdersScreen({super.key, required this.kitchenCode, required this.kitchenName, required this.kitchenColor});

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
  List<Map<String, dynamic>> _cancelRemarks = [];

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

  void _startAutoRefresh() => _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadOrders());

  Future<void> _loadOrders() async {
    if (ApiConfig.useMockData) {
      final mockOrders = mock.KitchenMockData.getOrdersForKitchen(widget.kitchenCode);
      if (mounted) setState(() { _orders = mockOrders.cast<PendingOrder>(); _isLoading = false; });
    } else {
      final orders = await _apiService.getPendingOrders(widget.kitchenCode);
      if (mounted) setState(() { _orders = orders; _isLoading = false; });
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
        await _apiService.setItemReady(outletCode: order.outletCode, kotNo: int.tryParse(order.kotNo) ?? 0, itemCode: item.itemCode, serialNo: item.serialNo, kitchenCode: widget.kitchenCode, readyBy: 'CHEF');
      }
      setState(() { item.status = ItemStatus.ready; item.endTime = _formatTime(DateTime.now()); if (order.items.every((i) => i.status == ItemStatus.ready)) order.isAllComplete = true; });
    }
  }

  void _removeOrder(PendingOrder order) => mounted ? setState(() => _orders.remove(order)) : null;

  String _formatTime(DateTime dt) => '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';

  // ── CANCEL FEATURE ──────────────────────────────────────────
  Future<void> _loadCancelRemarks() async {
    if (_cancelRemarks.isNotEmpty) return;
    final remarks = await _apiService.getCancelRemarks('A1');
    if (mounted) setState(() => _cancelRemarks = remarks);
  }

  Future<void> _showCancelDialog(PendingOrder order, OrderItem item) async {
    await _loadCancelRemarks();
    if (!mounted) return;
    String? selected;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setD) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [Icon(Icons.cancel_rounded, color: AppColors.statusPending, size: 24), const SizedBox(width: 10), const Text('Cancel Item', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 18, fontWeight: FontWeight.w700))]),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${item.itemName} (x${item.qty})', style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const Text('Cancel reason:', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 12, color: AppColors.textMedium)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(border: Border.all(color: AppColors.cardBorder), borderRadius: BorderRadius.circular(12)),
              child: DropdownButton<String>(value: selected, isExpanded: true, underline: const SizedBox(), hint: const Text('Select', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 13)), items: _cancelRemarks.map((r) => DropdownMenuItem<String>(value: r['CancelRemarks']?.toString() ?? '', child: Text(r['CancelRemarks']?.toString() ?? '', style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 13)))).toList(), onChanged: (v) => setD(() => selected = v)),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CLOSE', style: TextStyle(fontFamily: 'SpaceMono', color: AppColors.textMedium))),
            ElevatedButton(
              onPressed: selected == null ? null : () async { Navigator.pop(ctx); await _cancelItem(order, item, selected!); },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusPending, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('CONFIRM', style: TextStyle(fontFamily: 'SpaceMono', color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelItem(PendingOrder order, OrderItem item, String remark) async {
    final ok = await _apiService.cancelKOTItem(outletCode: order.outletCode, kotNo: int.tryParse(order.kotNo) ?? 0, serialNo: int.tryParse(item.serialNo) ?? 0, itemCode: item.itemCode, itemDesc: item.itemName, qty: item.qty, billDate: order.billDate, userCode: 'club', cancelRemarks: remark);
    if (ok && mounted) {
      setState(() { order.items.remove(item); if (order.items.isEmpty) _orders.remove(order); });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.itemName} cancelled', style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 13)), backgroundColor: AppColors.statusPending, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false, onPopInvokedWithResult: (didPop, result) { if (!didPop) Navigator.pop(context); },
        child: Scaffold(
          body: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: AppColors.bgGradient, stops: [0.0, 0.3, 0.7, 1.0])), child: SafeArea(child: Stack(children: [_buildBackground(), FadeTransition(opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeOut), child: Column(children: [_buildHeader(), Expanded(child: _isLoading ? _buildLoading() : _buildOrdersList())]))]))),
        ));
  }

  Widget _buildBackground() => AnimatedBuilder(animation: _pulseController, builder: (_, __) => Positioned(top: -50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [widget.kitchenColor.withValues(alpha: 0.06 * _pulseController.value), Colors.transparent])))));

  Widget _buildHeader() {
    final c = _totalPendingItems();
    return Container(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 3))]), child: Row(children: [
      Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))]), child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => Navigator.pop(context), child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.primaryOrange))))),
      const SizedBox(width: 12),
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(gradient: LinearGradient(colors: [widget.kitchenColor.withValues(alpha: 0.2), widget.kitchenColor.withValues(alpha: 0.08)]), borderRadius: BorderRadius.circular(7)), child: Text(widget.kitchenCode, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 12, fontWeight: FontWeight.w700, color: widget.kitchenColor))),
      const SizedBox(width: 8),
      Expanded(child: Text(widget.kitchenName, style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark), overflow: TextOverflow.ellipsis)),
      const SizedBox(width: 8),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [widget.kitchenColor, widget.kitchenColor.withValues(alpha: 0.8)]), borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: widget.kitchenColor.withValues(alpha: 0.35), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 3))]), child: Row(mainAxisSize: MainAxisSize.min, children: [Text('$c', style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white)), const SizedBox(width: 5), const Text('pending', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70, letterSpacing: 0.5))])),
    ]));
  }

  Widget _buildLoading() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 45, height: 45, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(widget.kitchenColor))), const SizedBox(height: 20), Text('Loading...', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 17, color: widget.kitchenColor.withValues(alpha: 0.8)))]));

  Widget _buildOrdersList() {
    if (_orders.isEmpty) {
      return RefreshIndicator(color: widget.kitchenColor, onRefresh: _loadOrders, child: ListView(children: [SizedBox(height: MediaQuery.of(context).size.height * 0.3), Center(child: Column(children: [Container(padding: const EdgeInsets.all(40), decoration: BoxDecoration(gradient: LinearGradient(colors: [widget.kitchenColor.withValues(alpha: 0.15), widget.kitchenColor.withValues(alpha: 0.05)]), shape: BoxShape.circle), child: Icon(Icons.check_circle_outline_rounded, size: 70, color: widget.kitchenColor)), const SizedBox(height: 28), Text('All Orders Completed!', style: TextStyle(fontFamily: 'SpaceMono', fontSize: Responsive.fontSize(context, 23), fontWeight: FontWeight.w700, color: widget.kitchenColor)), const SizedBox(height: 10), const Text('Pull down to refresh', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 15, color: Color(0xFF999999)))]))]));
    }
    return RefreshIndicator(color: widget.kitchenColor, onRefresh: _loadOrders, child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), itemCount: _orders.length, itemBuilder: (_, i) { final o = _orders[i]; return OrderCompletionAnimator(order: o, isComplete: o.isAllComplete, onDismissed: () => _removeOrder(o), child: _buildOrderCard(o)); }));
  }

  Widget _buildOrderCard(PendingOrder o) {
    return Container(margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cardBorder, width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, spreadRadius: 1, offset: const Offset(0, 4))]), child: ClipRRect(borderRadius: BorderRadius.circular(20), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withValues(alpha: 0.92), Colors.white.withValues(alpha: 0.65)]), borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildTableHeader(o), _buildColumnHeaders(), ...o.items.asMap().entries.map((e) => _buildItemRow(o, e.value, e.key)), if (o.isAllComplete) _buildAllCompleteBanner()])))));
  }

  Widget _buildTableHeader(PendingOrder o) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(gradient: LinearGradient(colors: [widget.kitchenColor.withValues(alpha: 0.08), widget.kitchenColor.withValues(alpha: 0.02)]), border: const Border(bottom: BorderSide(color: AppColors.cardDivider, width: 1))), child: Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: [widget.kitchenColor.withValues(alpha: 0.18), widget.kitchenColor.withValues(alpha: 0.06)]), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.receipt_long_rounded, size: 18, color: widget.kitchenColor)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('KOT #${o.kotNo}  ·  ${o.memberCode}', style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))), const SizedBox(height: 2), Text('${o.waiterDesc}  ·  ${o.createdDate}  ·  ${o.memberName}', style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMedium))])),
      if (o.isAllComplete) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.statusReady.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.statusReady.withValues(alpha: 0.3), width: 1)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_circle, size: 12, color: AppColors.statusReady), SizedBox(width: 5), Text('DONE', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.statusReady, letterSpacing: 1))])),
    ]));
  }

  Widget _buildColumnHeaders() {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: const BoxDecoration(color: Color(0xFFF8F8F8), border: Border(bottom: BorderSide(color: AppColors.cardDivider, width: 1))), child: const Row(children: [Expanded(flex: 5, child: _ColumnHeader('ITEM / REMARKS')), SizedBox(width: 40, child: Center(child: _ColumnHeader('QTY', centered: true))), SizedBox(width: 60, child: Center(child: _ColumnHeader('DONE', centered: true))), SizedBox(width: 44, child: Center(child: _ColumnHeader('DEL', centered: true)))]));
  }

  Widget _buildItemRow(PendingOrder o, OrderItem item, int idx) {
    final ready = item.status == ItemStatus.ready;
    final orderComplete = o.isAllComplete;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ready ? AppColors.statusReady.withValues(alpha: 0.05) : (idx % 2 == 0 ? Colors.white.withValues(alpha: 0.4) : Colors.transparent),
        border: const Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(flex: 5, child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          AnimatedContainer(duration: const Duration(milliseconds: 280), width: 3, height: 28, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: ready ? AppColors.statusReady.withValues(alpha: 0.5) : widget.kitchenColor.withValues(alpha: 0.4))),
          Flexible(child: Text(item.itemName, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 13, fontWeight: FontWeight.w700, color: ready ? const Color(0xFFAAAAAA) : AppColors.textDark, decoration: ready ? TextDecoration.lineThrough : null), maxLines: 2, overflow: TextOverflow.ellipsis)),
        ])),
        SizedBox(width: 40, child: Center(child: Text('${item.qty}', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 15, fontWeight: FontWeight.w700, color: ready ? const Color(0xFFAAAAAA) : AppColors.textDark)))),
        SizedBox(width: 60, child: Center(child: GestureDetector(
          onTap: () => _toggleItemStatus(o, item),
          child: AnimatedContainer(duration: const Duration(milliseconds: 250), padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: ready ? AppColors.statusReady : widget.kitchenColor.withValues(alpha: 0.1)), child: Icon(ready ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 20, color: ready ? Colors.white : widget.kitchenColor.withValues(alpha: 0.5))),
        ))),
        // Cancel button - shows only when item is NOT ready AND order is NOT complete
        if (!ready && !orderComplete)
          SizedBox(width: 44, child: Center(child: GestureDetector(
            onTap: () => _showCancelDialog(o, item),
            child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.statusPending.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.statusPending.withValues(alpha: 0.3))), child: const Icon(Icons.close_rounded, size: 16, color: AppColors.statusPending)),
          ))),
        // If item is ready OR order is complete, keep spacing but hide cancel
        if (ready || orderComplete) const SizedBox(width: 44),
      ]),
    );
  }

  Widget _buildAllCompleteBanner() => Container(padding: const EdgeInsets.symmetric(vertical: 11), decoration: BoxDecoration(color: AppColors.statusReady.withValues(alpha: 0.08), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))), child: const Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, size: 18, color: AppColors.statusReady), SizedBox(width: 8), Text('ALL ITEMS COMPLETED', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.statusReady, letterSpacing: 1.5))])));
}

class _ColumnHeader extends StatelessWidget {
  final String text;
  final bool centered;
  const _ColumnHeader(this.text, {this.centered = false});
  @override
  Widget build(BuildContext context) => Text(text, textAlign: centered ? TextAlign.center : TextAlign.start, style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1));
}