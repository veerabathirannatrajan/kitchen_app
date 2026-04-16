import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../widgets/shared.dart';
import 'splash_screen.dart';
import 'dart:async';

class WaiterScreen extends StatefulWidget {
  const WaiterScreen({super.key});
  @override
  State<WaiterScreen> createState() => _WaiterScreenState();
}

class _WaiterScreenState extends State<WaiterScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  late Timer _clock;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() { _tab.dispose(); _clock.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final pending = AppData.orders.where((o) => !o.isReady).length;
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      body: AppBackground(
        child: SafeArea(
          child: Column(children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(children: [
                TapScale(
                  onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const SplashScreen())),
                  child: GlassCard(
                    padding: const EdgeInsets.all(10),
                    borderRadius: BorderRadius.circular(12),
                    child: const Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0xFF8888AA)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Text('🧑‍🍽️', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Text('WAITER STATION', style: TextStyle(
                      fontFamily: 'SpaceMono', fontSize: 14, fontWeight: FontWeight.w700,
                      color: Color(0xFF4D9FFF), letterSpacing: 1.5)),
                  ]),
                  Text('$h:$m:$s  ·  ${AppData.activeTables.length} ACTIVE TABLES',
                    style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 9,
                      color: Color(0xFF44445A), letterSpacing: 1)),
                ])),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  borderRadius: BorderRadius.circular(20),
                  borderColor: const Color(0x44FF6B35),
                  bgColor: const Color(0x15FF6B35),
                  child: Row(children: [
                    PulseDot(color: const Color(0xFFFF6B35)),
                    const SizedBox(width: 6),
                    Text('$pending COOKING', style: const TextStyle(
                      fontFamily: 'SpaceMono', fontSize: 9, color: Color(0xFFFF6B35), letterSpacing: 1)),
                  ]),
                ),
              ]),
            ),
            // ── TAB BAR ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: GlassCard(
                padding: const EdgeInsets.all(4),
                borderRadius: BorderRadius.circular(14),
                bgColor: const Color(0x10FFFFFF),
                child: Row(children: [
                  _WTab(label: '🪑  TABLES',  index: 0, tab: _tab, color: const Color(0xFF4D9FFF)),
                  const SizedBox(width: 3),
                  _WTab(label: '📋  ORDERS',  index: 1, tab: _tab, color: const Color(0xFF00E5A0)),
                  const SizedBox(width: 3),
                  _WTab(label: '➕  NEW KOT', index: 2, tab: _tab, color: const Color(0xFFFFD166)),
                ]),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _TableOverview(onNewOrder: () => _tab.animateTo(2)),
                  _OrderStatusView(onRefresh: () => setState(() {})),
                  _NewOrderView(onPlaced: () { setState(() {}); _tab.animateTo(1); }),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _WTab extends StatefulWidget {
  final String label;
  final int index;
  final TabController tab;
  final Color color;
  const _WTab({required this.label, required this.index, required this.tab, required this.color});
  @override
  State<_WTab> createState() => _WTabState();
}

class _WTabState extends State<_WTab> {
  @override
  void initState() { super.initState(); widget.tab.addListener(() => setState(() {})); }

  @override
  Widget build(BuildContext context) {
    final sel = widget.tab.index == widget.index;
    return Expanded(child: GestureDetector(
      onTap: () => widget.tab.animateTo(widget.index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: sel ? widget.color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: sel ? Border.all(color: widget.color.withOpacity(0.4)) : null,
          boxShadow: sel ? [BoxShadow(color: widget.color.withOpacity(0.15), blurRadius: 8)] : null),
        child: Text(widget.label, textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9, fontWeight: FontWeight.w700,
            color: sel ? widget.color : const Color(0xFF44445A), letterSpacing: 0.3)),
      ),
    ));
  }
}

// ─────────────────── TABLE OVERVIEW ─────────────────────────────────────────
class _TableOverview extends StatefulWidget {
  final VoidCallback onNewOrder;
  const _TableOverview({required this.onNewOrder});
  @override
  State<_TableOverview> createState() => _TableOverviewState();
}

class _TableOverviewState extends State<_TableOverview> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    if (_selected != null) {
      return _TableOrderDetail(
        tableCode: _selected!,
        onBack: () => setState(() => _selected = null),
      );
    }

    final tables = AppData.activeTables;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // Summary strip
        _SummaryStrip(),
        const SizedBox(height: 16),
        const Text('ACTIVE TABLES', style: TextStyle(
          fontFamily: 'SpaceMono', fontSize: 9, color: Color(0xFF44445A), letterSpacing: 2.5)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.05),
          itemCount: tables.length,
          itemBuilder: (_, i) {
            final t = tables[i];
            final allItems = AppData.ordersForTable(t);
            final pending = allItems.where((o) => !o.isReady).length;
            final done    = allItems.where((o) => o.isReady).length;
            final progress = allItems.isNotEmpty ? done / allItems.length : 0.0;
            final allDone  = pending == 0;

            // Dominant kitchen color
            final Map<String, int> kCount = {};
            for (final it in allItems) kCount[it.kitchenCode] = (kCount[it.kitchenCode] ?? 0) + 1;
            final topKitchen = kCount.isNotEmpty
              ? kCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
              : 'K17';
            final color = KitchenDef.byCode(topKitchen)?.color ?? const Color(0xFF8888AA);

            return TapScale(
              onTap: () => setState(() => _selected = t),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: allDone
                        ? const Color(0xFF00E5A0).withOpacity(0.07)
                        : color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: allDone
                          ? const Color(0xFF00E5A0).withOpacity(0.3)
                          : color.withOpacity(0.28)),
                      boxShadow: [BoxShadow(
                        color: (allDone ? const Color(0xFF00E5A0) : color).withOpacity(0.1),
                        blurRadius: 16)]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(allDone ? '✅' : '🪑', style: const TextStyle(fontSize: 20)),
                        const Spacer(),
                        if (pending > 0)
                          Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFF6B35),
                              boxShadow: [const BoxShadow(color: Color(0x55FF6B35), blurRadius: 6)]),
                            child: Center(child: Text('$pending',
                              style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 9,
                                fontWeight: FontWeight.w700, color: Colors.black)))),
                      ]),
                      const Spacer(),
                      Text(t.replaceAll('T', 'Table '), style: const TextStyle(
                        fontFamily: 'SpaceMono', fontSize: 13, fontWeight: FontWeight.w700,
                        color: Color(0xFFF0F0FF))),
                      const SizedBox(height: 2),
                      Text('${allItems.length} items  ·  $done ready',
                        style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 8, color: Color(0xFF8888AA))),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress, minHeight: 4,
                          backgroundColor: const Color(0x18FFFFFF),
                          valueColor: AlwaysStoppedAnimation(
                            allDone ? const Color(0xFF00E5A0) : color))),
                    ]),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        // Quick New Order
        TapScale(
          onTap: widget.onNewOrder,
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 16),
            borderColor: const Color(0xFF4D9FFF).withOpacity(0.35),
            bgColor: const Color(0xFF4D9FFF).withOpacity(0.06),
            shadows: [BoxShadow(color: const Color(0xFF4D9FFF).withOpacity(0.12), blurRadius: 16)],
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF4D9FFF)),
              SizedBox(width: 10),
              Text('TAKE NEW ORDER', style: TextStyle(
                fontFamily: 'SpaceMono', fontSize: 12, fontWeight: FontWeight.w700,
                color: Color(0xFF4D9FFF), letterSpacing: 2)),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final all = AppData.orders;
    final pending  = all.where((o) => !o.isReady).length;
    final done     = all.where((o) => o.isReady).length;
    final tables   = all.map((o) => o.tableCode).toSet().length;

    return Row(children: [
      _SummaryChip(value: '$tables', label: 'TABLES', color: const Color(0xFF4D9FFF)),
      const SizedBox(width: 8),
      _SummaryChip(value: '$pending', label: 'COOKING', color: const Color(0xFFFF6B35)),
      const SizedBox(width: 8),
      _SummaryChip(value: '$done', label: 'READY', color: const Color(0xFF00E5A0)),
    ]);
  }
}

class _SummaryChip extends StatelessWidget {
  final String value, label;
  final Color color;
  const _SummaryChip({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 12),
      borderColor: color.withOpacity(0.3),
      bgColor: color.withOpacity(0.07),
      shadows: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 12)],
      child: Column(children: [
        Text(value, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 22,
          fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 8,
          color: color.withOpacity(0.7), letterSpacing: 1.5)),
      ]),
    ));
  }
}

class _TableOrderDetail extends StatelessWidget {
  final String tableCode;
  final VoidCallback onBack;
  const _TableOrderDetail({required this.tableCode, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final items = AppData.ordersForTable(tableCode);
    final kotNos = items.map((i) => i.kotNo).toSet().toList()..sort();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(children: [
          TapScale(
            onTap: onBack,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              borderRadius: BorderRadius.circular(10),
              child: Row(children: [
                const Icon(Icons.arrow_back_ios_new, size: 12, color: Color(0xFF8888AA)),
                const SizedBox(width: 5),
                const Text('TABLES', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, color: Color(0xFF8888AA))),
              ]),
            ),
          ),
          const SizedBox(width: 10),
          Text('🪑  $tableCode', style: const TextStyle(
            fontFamily: 'SpaceMono', fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFF0F0FF))),
          const Spacer(),
          NeonBadge(
            text: '${items.where((i) => !i.isReady).length} PENDING',
            color: const Color(0xFFFF6B35), fontSize: 10),
        ]),
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          children: kotNos.map((kotNo) {
            final kotItems = items.where((i) => i.kotNo == kotNo).toList();
            final allDone = kotItems.every((i) => i.isReady);
            final done = kotItems.where((i) => i.isReady).length;
            final progress = kotItems.isNotEmpty ? done / kotItems.length : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(0),
                bgColor: allDone ? const Color(0x0D00E5A0) : const Color(0x14FFFFFF),
                borderColor: allDone ? const Color(0x3000E5A0) : const Color(0x25FFFFFF),
                child: Column(children: [
                  // KOT header
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    decoration: const BoxDecoration(
                      color: Color(0x10FFFFFF),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      border: Border(bottom: BorderSide(color: Color(0x15FFFFFF)))),
                    child: Row(children: [
                      NeonBadge(text: 'KOT  #${kotNo.toString().padLeft(3,'0')}',
                        color: const Color(0xFF4D9FFF), fontSize: 10),
                      const Spacer(),
                      if (allDone)
                        NeonBadge(text: '✓ READY TO SERVE', color: const Color(0xFF00E5A0), fontSize: 9)
                      else
                        Text('${kotItems.length - done} remaining',
                          style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: Color(0xFF8888AA))),
                    ]),
                  ),
                  // Progress bar
                  ClipRect(child: LinearProgressIndicator(
                    value: progress, minHeight: 3,
                    backgroundColor: const Color(0x10FFFFFF),
                    valueColor: AlwaysStoppedAnimation(
                      allDone ? const Color(0xFF00E5A0) : const Color(0xFF4D9FFF)))),
                  // Items grouped by kitchen
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(children: kotItems.map((item) {
                      final kColor = item.kitchen?.color ?? const Color(0xFF8888AA);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          Container(width: 3, height: 30,
                            decoration: BoxDecoration(
                              color: kColor, borderRadius: BorderRadius.circular(2),
                              boxShadow: [BoxShadow(color: kColor.withOpacity(0.5), blurRadius: 4)])),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(item.itemDesc, style: TextStyle(
                              fontFamily: 'SpaceMono', fontSize: 10,
                              color: item.isReady ? const Color(0xFF44445A) : const Color(0xFFF0F0FF),
                              decoration: item.isReady ? TextDecoration.lineThrough : null,
                              decorationColor: const Color(0xFF44445A))),
                            const SizedBox(height: 1),
                            Row(children: [
                              NeonBadge(text: item.kitchenCode, color: kColor, fontSize: 7),
                              const SizedBox(width: 5),
                              Text('×${item.quantity.toInt()}  ·  ${item.uom}',
                                style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 8, color: Color(0xFF44445A))),
                            ]),
                          ])),
                          // Status
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.isReady ? const Color(0xFF00E5A0).withOpacity(0.12) : const Color(0x12FFFFFF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: item.isReady ? const Color(0xFF00E5A0).withOpacity(0.3) : const Color(0x18FFFFFF))),
                            child: Text(item.isReady ? '✓ READY' : '⏳ COOKING',
                              style: TextStyle(fontFamily: 'SpaceMono', fontSize: 8,
                                color: item.isReady ? const Color(0xFF00E5A0) : const Color(0xFF8888AA)))),
                        ]),
                      );
                    }).toList()),
                  ),
                ]),
              ),
            );
          }).toList(),
        ),
      ),
    ]);
  }
}

// ─────────────────── ORDER STATUS VIEW ──────────────────────────────────────
class _OrderStatusView extends StatelessWidget {
  final VoidCallback onRefresh;
  const _OrderStatusView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final tables = AppData.activeTables;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: tables.map((t) {
        final items = AppData.ordersForTable(t);
        final pending = items.where((o) => !o.isReady).length;
        final done    = items.where((o) => o.isReady).length;
        final allDone = pending == 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: GlassCard(
            padding: const EdgeInsets.all(0),
            bgColor: allDone ? const Color(0x0A00E5A0) : const Color(0x12FFFFFF),
            borderColor: allDone ? const Color(0x2500E5A0) : const Color(0x20FFFFFF),
            child: Column(children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Row(children: [
                  Text(allDone ? '✅' : '🪑', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(t.replaceAll('T', 'Table '), style: const TextStyle(
                    fontFamily: 'SpaceMono', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFF0F0FF))),
                  const Spacer(),
                  if (allDone)
                    NeonBadge(text: '✓ ALL READY', color: const Color(0xFF00E5A0), fontSize: 9)
                  else
                    NeonBadge(text: '$pending COOKING', color: const Color(0xFFFF6B35), fontSize: 9),
                ]),
              ),
              // Items
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Column(children: items.map((item) {
                  final kColor = item.kitchen?.color ?? const Color(0xFF8888AA);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      GlowDot(color: item.isReady ? const Color(0xFF00E5A0) : kColor, size: 6),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.itemDesc, style: TextStyle(
                        fontSize: 11, color: item.isReady ? const Color(0xFF44445A) : const Color(0xFFCCCCDD),
                        decoration: item.isReady ? TextDecoration.lineThrough : null,
                        decorationColor: const Color(0xFF44445A)))),
                      NeonBadge(text: item.kitchenCode, color: kColor, fontSize: 7),
                      const SizedBox(width: 6),
                      Text('×${item.quantity.toInt()}', style: const TextStyle(
                        fontFamily: 'SpaceMono', fontSize: 10, color: Color(0xFF8888AA))),
                    ]),
                  );
                }).toList()),
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────── NEW ORDER VIEW ─────────────────────────────────────────
class _NewOrderView extends StatefulWidget {
  final VoidCallback onPlaced;
  const _NewOrderView({required this.onPlaced});
  @override
  State<_NewOrderView> createState() => _NewOrderViewState();
}

class _NewOrderViewState extends State<_NewOrderView> {
  String _selectedTable = 'T01';
  String _selectedCategory = 'All';
  final Map<String, int> _cart = {};
  bool _placed = false;

  final List<String> _tables = List.generate(12,
    (i) => 'T${(i + 1).toString().padLeft(2, '0')}');

  List<String> get _categories {
    final cats = AppData.menu.map((m) => m.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<MenuItem> get _filteredMenu => _selectedCategory == 'All'
    ? AppData.menu
    : AppData.menu.where((m) => m.category == _selectedCategory).toList();

  int get _totalItems => _cart.values.fold(0, (a, b) => a + b);
  double get _totalPrice => _cart.entries.fold(0.0, (sum, e) {
    final item = AppData.menu.firstWhere((m) => m.name == e.key, orElse: () =>
      const MenuItem(code: '', name: '', kitchenCode: '', price: 0, uom: '', category: ''));
    return sum + item.price * e.value;
  });

  void _place() {
    if (_cart.isEmpty) return;
    final kotNo = AppData.nextKotNo();
    _cart.forEach((name, qty) {
      final menu = AppData.menu.firstWhere((m) => m.name == name,
        orElse: () => const MenuItem(code: '0', name: 'Unknown', kitchenCode: 'K17', price: 0, uom: 'PLATE', category: 'Mains'));
      AppData.orders.add(OrderItem(
        id: '${DateTime.now().millisecondsSinceEpoch}$name',
        kotNo: kotNo, tableCode: _selectedTable,
        itemCode: menu.code, itemDesc: menu.name,
        quantity: qty.toDouble(), kitchenCode: menu.kitchenCode,
        isReady: false, waiterCode: 'Waiter',
        startTime: DateTime.now(), uom: menu.uom,
      ));
    });
    setState(() { _cart.clear(); _placed = true; });
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) { setState(() => _placed = false); widget.onPlaced(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(children: [
        // Table selector
        SizedBox(
          height: 46,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            itemCount: _tables.length,
            itemBuilder: (_, i) {
              final t = _tables[i];
              final sel = t == _selectedTable;
              return GestureDetector(
                onTap: () => setState(() => _selectedTable = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFF4D9FFF).withOpacity(0.18) : const Color(0x12FFFFFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel
                      ? const Color(0xFF4D9FFF).withOpacity(0.5)
                      : const Color(0x20FFFFFF)),
                    boxShadow: sel ? [const BoxShadow(color: Color(0x224D9FFF), blurRadius: 8)] : null),
                  child: Center(child: Text(t.replaceAll('T', 'T '),
                    style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, fontWeight: FontWeight.w700,
                      color: sel ? const Color(0xFF4D9FFF) : const Color(0xFF44445A)))),
                ),
              );
            },
          ),
        ),
        // Category pills
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final sel = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFFFFD166).withOpacity(0.15) : const Color(0x10FFFFFF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel
                      ? const Color(0xFFFFD166).withOpacity(0.4) : const Color(0x18FFFFFF))),
                  child: Center(child: Text(cat,
                    style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: sel ? const Color(0xFFFFD166) : const Color(0xFF44445A)))),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        // Menu list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
            itemCount: _filteredMenu.length,
            itemBuilder: (_, i) {
              final item = _filteredMenu[i];
              final qty = _cart[item.name] ?? 0;
              final kColor = item.kitchen?.color ?? const Color(0xFF8888AA);
              final selected = qty > 0;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: selected ? kColor.withOpacity(0.08) : const Color(0x10FFFFFF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? kColor.withOpacity(0.35) : const Color(0x18FFFFFF))),
                      child: Row(children: [
                        Container(width: 3, height: 36, decoration: BoxDecoration(
                          color: kColor, borderRadius: BorderRadius.circular(2),
                          boxShadow: [BoxShadow(color: kColor.withOpacity(0.5), blurRadius: 4)])),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.name, style: const TextStyle(
                            fontFamily: 'SpaceMono', fontSize: 11, fontWeight: FontWeight.w700,
                            color: Color(0xFFF0F0FF))),
                          const SizedBox(height: 3),
                          Row(children: [
                            NeonBadge(text: item.kitchenCode, color: kColor, fontSize: 7),
                            const SizedBox(width: 6),
                            Text('₹${item.price.toInt()}  ·  ${item.uom}',
                              style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: Color(0xFF8888AA))),
                          ]),
                        ])),
                        // Qty controls
                        Row(children: [
                          if (qty > 0) ...[
                            _QtyBtn(
                              icon: Icons.remove, color: const Color(0xFFFF3B5C),
                              onTap: () => setState(() {
                                if (qty == 1) _cart.remove(item.name);
                                else _cart[item.name] = qty - 1;
                              }),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(width: 22, child: Text('$qty', textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'SpaceMono', fontSize: 14,
                                fontWeight: FontWeight.w700, color: kColor))),
                            const SizedBox(width: 8),
                          ],
                          _QtyBtn(
                            icon: Icons.add, color: const Color(0xFF00E5A0),
                            onTap: () => setState(() => _cart[item.name] = qty + 1),
                          ),
                        ]),
                      ]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
      // Cart bar
      if (_totalItems > 0 || _placed)
        Positioned(
          bottom: 0, left: 16, right: 16,
          child: _CartBar(
            itemCount: _totalItems, table: _selectedTable,
            totalPrice: _totalPrice, placed: _placed, onPlace: _place),
        ),
    ]);
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle, color: color.withOpacity(0.12),
          border: Border.all(color: color.withOpacity(0.35)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 6)]),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  final int itemCount;
  final String table;
  final double totalPrice;
  final bool placed;
  final VoidCallback onPlace;
  const _CartBar({required this.itemCount, required this.table, required this.totalPrice,
    required this.placed, required this.onPlace});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TapScale(
        onTap: placed ? () {} : onPlace,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: placed
                  ? const Color(0xFF00E5A0).withOpacity(0.15)
                  : const Color(0xFF4D9FFF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: placed
                  ? const Color(0xFF00E5A0).withOpacity(0.4)
                  : const Color(0xFF4D9FFF).withOpacity(0.4)),
                boxShadow: [BoxShadow(
                  color: (placed ? const Color(0xFF00E5A0) : const Color(0xFF4D9FFF)).withOpacity(0.2),
                  blurRadius: 20, offset: const Offset(0, 4))]),
              child: placed
                ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('✅', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Text('KOT SENT TO KITCHEN!', style: TextStyle(
                      fontFamily: 'SpaceMono', fontSize: 13, fontWeight: FontWeight.w700,
                      color: Color(0xFF00E5A0), letterSpacing: 1)),
                  ])
                : Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('$itemCount ITEMS  ·  ${table.replaceAll('T','Table ')}',
                        style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: Color(0xFF8888AA))),
                      Text('₹${totalPrice.toInt()}', style: const TextStyle(
                        fontFamily: 'SpaceMono', fontSize: 18, fontWeight: FontWeight.w700,
                        color: Color(0xFF4D9FFF))),
                    ]),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D9FFF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4D9FFF).withOpacity(0.4))),
                      child: const Row(children: [
                        Icon(Icons.send_rounded, size: 14, color: Color(0xFF4D9FFF)),
                        SizedBox(width: 8),
                        Text('FIRE KOT', style: TextStyle(
                          fontFamily: 'SpaceMono', fontSize: 11, fontWeight: FontWeight.w700,
                          color: Color(0xFF4D9FFF), letterSpacing: 1)),
                      ]),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
