import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../widgets/shared.dart';
import 'splash_screen.dart';
import 'dart:async';

class ChefScreen extends StatefulWidget {
  const ChefScreen({super.key});
  @override
  State<ChefScreen> createState() => _ChefScreenState();
}

class _ChefScreenState extends State<ChefScreen> with TickerProviderStateMixin {
  late TabController _kitchenTab;
  late Timer _clock;
  DateTime _now = DateTime.now();
  // 'kitchen' | 'table'
  String _viewMode = 'kitchen';

  @override
  void initState() {
    super.initState();
    _kitchenTab = TabController(length: KitchenDef.all.length, vsync: this);
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() { _kitchenTab.dispose(); _clock.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      body: AppBackground(
        child: SafeArea(
          child: Column(children: [
            _Header(now: _now, viewMode: _viewMode, onToggle: (v) => setState(() => _viewMode = v)),
            Expanded(child: _viewMode == 'kitchen'
              ? _KitchenTabView(tab: _kitchenTab, onUpdate: () => setState(() {}))
              : _TableView(onUpdate: () => setState(() {}))),
          ]),
        ),
      ),
    );
  }
}

// ──────────────────────────── HEADER ────────────────────────────────────────
class _Header extends StatelessWidget {
  final DateTime now;
  final String viewMode;
  final Function(String) onToggle;
  const _Header({required this.now, required this.viewMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final totalPending = AppData.orders.where((o) => !o.isReady).length;
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(children: [
        Row(children: [
          // Back
          TapScale(
            onTap: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const SplashScreen())),
            child: GlassCard(
              padding: const EdgeInsets.all(10),
              borderRadius: BorderRadius.circular(12),
              bgColor: const Color(0x15FFFFFF),
              child: const Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0xFF8888AA)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Text('👨‍🍳', style: TextStyle(fontSize: 14)),
              SizedBox(width: 6),
              Text('CHEF STATION', style: TextStyle(
                fontFamily: 'SpaceMono', fontSize: 14, fontWeight: FontWeight.w700,
                color: Color(0xFFFF6B35), letterSpacing: 1.5)),
            ]),
            Text('$h:$m:$s  ·  MAXIM KITCHEN', style: const TextStyle(
              fontFamily: 'SpaceMono', fontSize: 9, color: Color(0xFF44445A), letterSpacing: 1)),
          ])),
          // Pending badge
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            borderRadius: BorderRadius.circular(20),
            borderColor: const Color(0x44FF6B35),
            bgColor: const Color(0x15FF6B35),
            child: Row(children: [
              PulseDot(color: const Color(0xFFFF6B35)),
              const SizedBox(width: 6),
              Text('$totalPending PENDING', style: const TextStyle(
                fontFamily: 'SpaceMono', fontSize: 9, color: Color(0xFFFF6B35), letterSpacing: 1)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        // View toggle
        GlassCard(
          padding: const EdgeInsets.all(4),
          borderRadius: BorderRadius.circular(14),
          bgColor: const Color(0x10FFFFFF),
          child: Row(children: [
            _ToggleBtn(label: '🍳  KITCHEN VIEW', selected: viewMode == 'kitchen',
              color: const Color(0xFFFF6B35), onTap: () => onToggle('kitchen')),
            const SizedBox(width: 4),
            _ToggleBtn(label: '🪑  TABLE VIEW', selected: viewMode == 'table',
              color: const Color(0xFF4D9FFF), onTap: () => onToggle('table')),
          ]),
        ),
        const SizedBox(height: 4),
      ]),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _ToggleBtn({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected ? Border.all(color: color.withOpacity(0.4)) : null,
          boxShadow: selected ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 10)] : null,
        ),
        child: Text(label, textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SpaceMono', fontSize: 10, fontWeight: FontWeight.w700,
            color: selected ? color : const Color(0xFF44445A), letterSpacing: 0.5)),
      ),
    ));
  }
}

// ──────────────────────── KITCHEN TAB VIEW ──────────────────────────────────
class _KitchenTabView extends StatelessWidget {
  final TabController tab;
  final VoidCallback onUpdate;
  const _KitchenTabView({required this.tab, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Kitchen tabs (scrollable)
      SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          itemCount: KitchenDef.all.length,
          itemBuilder: (_, i) {
            final k = KitchenDef.all[i];
            final pending = AppData.pendingForKitchen(k.code);
            return GestureDetector(
              onTap: () => tab.animateTo(i),
              child: AnimatedBuilder(
                animation: tab,
                builder: (_, __) {
                  final sel = tab.index == i;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel ? k.color.withOpacity(0.18) : const Color(0x12FFFFFF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: sel ? k.color.withOpacity(0.5) : const Color(0x20FFFFFF)),
                            boxShadow: sel ? [BoxShadow(color: k.color.withOpacity(0.2), blurRadius: 12)] : null,
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(k.emoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(k.name.toUpperCase(), style: TextStyle(
                              fontFamily: 'SpaceMono', fontSize: 9, fontWeight: FontWeight.w700,
                              color: sel ? k.color : const Color(0xFF8888AA), letterSpacing: 0.5)),
                            if (pending > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 18, height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: k.color,
                                  boxShadow: [BoxShadow(color: k.color.withOpacity(0.5), blurRadius: 6)]),
                                child: Center(child: Text('$pending',
                                  style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 9,
                                    fontWeight: FontWeight.w700, color: Colors.black)))),
                            ],
                          ]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      // Content
      Expanded(
        child: TabBarView(
          controller: tab,
          children: KitchenDef.all.map((k) => _KitchenContent(
            kitchen: k,
            items: AppData.ordersForKitchen(k.code),
            onUpdate: onUpdate,
          )).toList(),
        ),
      ),
    ]);
  }
}

class _KitchenContent extends StatelessWidget {
  final KitchenDef kitchen;
  final List<OrderItem> items;
  final VoidCallback onUpdate;
  const _KitchenContent({required this.kitchen, required this.items, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(kitchen.emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 14),
        Text('ALL CLEAR', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 14,
          color: kitchen.color, letterSpacing: 3)),
        const SizedBox(height: 6),
        const Text('No pending orders', style: TextStyle(fontSize: 13, color: Color(0xFF44445A))),
      ]));
    }

    final pending = items.where((i) => !i.isReady).length;
    final done    = items.where((i) => i.isReady).length;
    final progress = items.isNotEmpty ? done / items.length : 0.0;

    // Group by KOT
    final Map<int, List<OrderItem>> byKot = {};
    for (final it in items) byKot.putIfAbsent(it.kotNo, () => []).add(it);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // Stats card
        _StatsGlassCard(kitchen: kitchen, pending: pending, done: done, progress: progress),
        const SizedBox(height: 12),
        // KOT cards
        ...byKot.entries.map((e) => _KotCard(
          kotNo: e.key,
          items: e.value,
          kitchen: kitchen,
          onUpdate: onUpdate,
        )),
      ],
    );
  }
}

class _StatsGlassCard extends StatelessWidget {
  final KitchenDef kitchen;
  final int pending, done;
  final double progress;
  const _StatsGlassCard({required this.kitchen, required this.pending, required this.done, required this.progress});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: kitchen.color.withOpacity(0.3),
      bgColor: kitchen.color.withOpacity(0.06),
      shadows: [BoxShadow(color: kitchen.color.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
      child: Column(children: [
        Row(children: [
          Text(kitchen.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(kitchen.name.toUpperCase(), style: TextStyle(
            fontFamily: 'SpaceMono', fontSize: 13, fontWeight: FontWeight.w700,
            color: kitchen.color, letterSpacing: 1)),
          const Spacer(),
          Text('${(progress * 100).toInt()}%', style: TextStyle(
            fontFamily: 'SpaceMono', fontSize: 22, fontWeight: FontWeight.w700, color: kitchen.color)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _MiniStat(label: 'COOKING', value: '$pending', color: const Color(0xFFFF6B35)),
          const SizedBox(width: 8),
          _MiniStat(label: 'DONE', value: '$done', color: const Color(0xFF00E5A0)),
          const SizedBox(width: 8),
          _MiniStat(label: 'TOTAL', value: '${pending + done}', color: const Color(0xFF8888AA)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0x22FFFFFF),
            valueColor: AlwaysStoppedAnimation(kitchen.color),
            minHeight: 6,
          ),
        ),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Text(value, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 20,
          fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 8,
          color: color.withOpacity(0.7), letterSpacing: 1.5)),
      ]),
    ));
  }
}

class _KotCard extends StatefulWidget {
  final int kotNo;
  final List<OrderItem> items;
  final KitchenDef kitchen;
  final VoidCallback onUpdate;
  const _KotCard({required this.kotNo, required this.items, required this.kitchen, required this.onUpdate});
  @override
  State<_KotCard> createState() => _KotCardState();
}

class _KotCardState extends State<_KotCard> with SingleTickerProviderStateMixin {
  late AnimationController _tick;
  late Timer _timer;
  Duration _wait = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
    _wait = DateTime.now().difference(widget.items.first.startTime);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() => _wait = DateTime.now().difference(widget.items.first.startTime));
    });
  }

  @override
  void dispose() { _tick.dispose(); _timer.cancel(); super.dispose(); }

  Color get _urgency {
    final m = _wait.inMinutes;
    if (m >= 20) return const Color(0xFFFF3B5C);
    if (m >= 10) return const Color(0xFFFFD166);
    return const Color(0xFF00E5A0);
  }

  @override
  Widget build(BuildContext context) {
    final allDone = widget.items.every((i) => i.isReady);
    final tableCode = widget.items.first.tableCode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: allDone
                ? const Color(0x0800E5A0)
                : const Color(0x14FFFFFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: allDone
                  ? const Color(0xFF00E5A0).withOpacity(0.25)
                  : _urgency.withOpacity(0.25)),
              boxShadow: allDone ? [] : [
                BoxShadow(color: _urgency.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Column(children: [
              // ── KOT Header ──
              Container(
                padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
                decoration: BoxDecoration(
                  color: const Color(0x10FFFFFF),
                  border: Border(bottom: BorderSide(color: const Color(0x18FFFFFF)))),
                child: Row(children: [
                  // KOT badge
                  NeonBadge(
                    text: 'KOT  #${widget.kotNo.toString().padLeft(3, '0')}',
                    color: widget.kitchen.color, fontSize: 10),
                  const SizedBox(width: 8),
                  // Table badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x18FFFFFF), borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: const Color(0x25FFFFFF))),
                    child: Row(children: [
                      const Text('🪑', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Text(tableCode, style: const TextStyle(
                        fontFamily: 'SpaceMono', fontSize: 10, color: Color(0xFFCCCCDD))),
                    ])),
                  const Spacer(),
                  // Wait time
                  if (!allDone)
                    AnimatedBuilder(
                      animation: _tick,
                      builder: (_, __) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: _urgency.withOpacity(0.08 + _tick.value * 0.05),
                          borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          Icon(Icons.timer_outlined, size: 12, color: _urgency),
                          const SizedBox(width: 4),
                          Text('${_wait.inMinutes}m', style: TextStyle(
                            fontFamily: 'SpaceMono', fontSize: 10, color: _urgency)),
                        ])),
                    ),
                  if (allDone)
                    NeonBadge(text: '✓ DONE', color: const Color(0xFF00E5A0), fontSize: 10),
                ]),
              ),
              // ── Items ──
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: widget.items.map((item) =>
                  _ItemTile(item: item, kitchen: widget.kitchen,
                    onTap: () { item.isReady = !item.isReady; widget.onUpdate(); HapticFeedback.lightImpact(); })
                ).toList()),
              ),
              // ── Mark All ──
              if (!allDone)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: TapScale(
                    onTap: () {
                      for (final it in widget.items) it.isReady = true;
                      widget.onUpdate();
                      HapticFeedback.heavyImpact();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          const Color(0xFF00E5A0).withOpacity(0.2),
                          const Color(0xFF00E5A0).withOpacity(0.05),
                        ]),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00E5A0).withOpacity(0.35)),
                        boxShadow: [BoxShadow(color: const Color(0xFF00E5A0).withOpacity(0.1), blurRadius: 12)],
                      ),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.check_circle_outline, size: 15, color: Color(0xFF00E5A0)),
                        SizedBox(width: 8),
                        Text('MARK ALL DONE', style: TextStyle(
                          fontFamily: 'SpaceMono', fontSize: 11, fontWeight: FontWeight.w700,
                          color: Color(0xFF00E5A0), letterSpacing: 2)),
                      ]),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ItemTile extends StatefulWidget {
  final OrderItem item;
  final KitchenDef kitchen;
  final VoidCallback onTap;
  const _ItemTile({required this.item, required this.kitchen, required this.onTap});
  @override
  State<_ItemTile> createState() => _ItemTileState();
}

class _ItemTileState extends State<_ItemTile> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final done = widget.item.isReady;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: done
              ? const Color(0x0D00E5A0)
              : const Color(0x12FFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: done
                ? const Color(0xFF00E5A0).withOpacity(0.2)
                : const Color(0x20FFFFFF)),
          ),
          child: Row(children: [
            // Check
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? const Color(0xFF00E5A0) : const Color(0x15FFFFFF),
                border: Border.all(
                  color: done ? const Color(0xFF00E5A0) : const Color(0x30FFFFFF), width: 1.5),
                boxShadow: done ? [const BoxShadow(color: Color(0x4400E5A0), blurRadius: 8)] : null),
              child: done
                ? const Icon(Icons.check, size: 15, color: Colors.black)
                : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.item.itemDesc,
                style: TextStyle(
                  fontFamily: 'SpaceMono', fontSize: 11, fontWeight: FontWeight.w700,
                  color: done ? const Color(0xFF44445A) : const Color(0xFFF0F0FF),
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor: const Color(0xFF44445A), letterSpacing: 0.2)),
              const SizedBox(height: 3),
              Text('QTY ${widget.item.quantity.toInt()}  ·  ${widget.item.uom}',
                style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: Color(0xFF44445A))),
            ])),
            NeonBadge(
              text: done ? '✓ DONE' : 'COOKING',
              color: done ? const Color(0xFF00E5A0) : widget.kitchen.color,
              fontSize: 8),
          ]),
        ),
      ),
    );
  }
}

// ──────────────────────── TABLE VIEW ────────────────────────────────────────
class _TableView extends StatefulWidget {
  final VoidCallback onUpdate;
  const _TableView({required this.onUpdate});
  @override
  State<_TableView> createState() => _TableViewState();
}

class _TableViewState extends State<_TableView> {
  String? _selectedTable;

  @override
  Widget build(BuildContext context) {
    final tables = AppData.activeTables;

    if (_selectedTable == null) {
      return Column(children: [
        const SectionLabel('ACTIVE TABLES'),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.1),
            itemCount: tables.length,
            itemBuilder: (_, i) {
              final t = tables[i];
              final pending = AppData.pendingForTable(t);
              final allItems = AppData.ordersForTable(t);
              final done = allItems.where((o) => o.isReady).length;
              final progress = allItems.isNotEmpty ? done / allItems.length : 0.0;

              // Pick color from first item's kitchen
              final kitchenColor = allItems.isNotEmpty
                ? (KitchenDef.byCode(allItems.first.kitchenCode)?.color ?? const Color(0xFF8888AA))
                : const Color(0xFF8888AA);

              return TapScale(
                onTap: () => setState(() => _selectedTable = t),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kitchenColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kitchenColor.withOpacity(0.3)),
                        boxShadow: [BoxShadow(color: kitchenColor.withOpacity(0.1), blurRadius: 16)]),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          const Text('🪑', style: TextStyle(fontSize: 22)),
                          const Spacer(),
                          if (pending > 0)
                            Container(
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle, color: const Color(0xFFFF6B35),
                                boxShadow: [const BoxShadow(color: Color(0x55FF6B35), blurRadius: 8)]),
                              child: Center(child: Text('$pending',
                                style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 9,
                                  fontWeight: FontWeight.w700, color: Colors.black)))),
                        ]),
                        const Spacer(),
                        Text(t.replaceAll('T', 'T '), style: const TextStyle(
                          fontFamily: 'SpaceMono', fontSize: 16, fontWeight: FontWeight.w700,
                          color: Color(0xFFF0F0FF))),
                        Text('${allItems.length} items  ·  $done done', style: const TextStyle(
                          fontFamily: 'SpaceMono', fontSize: 9, color: Color(0xFF8888AA))),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: const Color(0x18FFFFFF),
                            valueColor: AlwaysStoppedAnimation(
                              pending == 0 ? const Color(0xFF00E5A0) : kitchenColor),
                            minHeight: 4)),
                      ]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ]);
    }

    // Detail view for selected table
    return _TableDetail(
      tableCode: _selectedTable!,
      onBack: () => setState(() => _selectedTable = null),
      onUpdate: () { widget.onUpdate(); setState(() {}); },
    );
  }
}

class _TableDetail extends StatelessWidget {
  final String tableCode;
  final VoidCallback onBack;
  final VoidCallback onUpdate;
  const _TableDetail({required this.tableCode, required this.onBack, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final items = AppData.ordersForTable(tableCode);
    final pending = items.where((i) => !i.isReady).length;
    final done = items.where((i) => i.isReady).length;

    // Group by kitchen
    final Map<String, List<OrderItem>> byKitchen = {};
    for (final it in items) byKitchen.putIfAbsent(it.kitchenCode, () => []).add(it);

    return Column(children: [
      // Back header
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(children: [
          TapScale(
            onTap: onBack,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              borderRadius: BorderRadius.circular(10),
              child: Row(children: [
                const Icon(Icons.arrow_back_ios_new, size: 12, color: Color(0xFF8888AA)),
                const SizedBox(width: 6),
                const Text('TABLES', style: TextStyle(
                  fontFamily: 'SpaceMono', fontSize: 10, color: Color(0xFF8888AA))),
              ]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('🪑  $tableCode', style: const TextStyle(
            fontFamily: 'SpaceMono', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFF0F0FF)))),
          NeonBadge(text: '$pending PENDING', color: const Color(0xFFFF6B35)),
        ]),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
          children: byKitchen.entries.map((e) {
            final k = KitchenDef.byCode(e.key);
            return _TableKitchenSection(
              kitchen: k, items: e.value, onUpdate: onUpdate);
          }).toList(),
        ),
      ),
    ]);
  }
}

class _TableKitchenSection extends StatelessWidget {
  final KitchenDef? kitchen;
  final List<OrderItem> items;
  final VoidCallback onUpdate;
  const _TableKitchenSection({required this.kitchen, required this.items, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final color = kitchen?.color ?? const Color(0xFF8888AA);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        borderColor: color.withOpacity(0.3),
        bgColor: color.withOpacity(0.05),
        child: Column(children: [
          // Kitchen label
          Row(children: [
            Text(kitchen?.emoji ?? '🍽️', style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text((kitchen?.name ?? 'Kitchen').toUpperCase(), style: TextStyle(
              fontFamily: 'SpaceMono', fontSize: 11, fontWeight: FontWeight.w700,
              color: color, letterSpacing: 1)),
            const Spacer(),
            NeonBadge(text: 'KOT #${items.first.kotNo.toString().padLeft(3,'0')}', color: color, fontSize: 9),
          ]),
          const SizedBox(height: 10),
          const Divider(color: Color(0x15FFFFFF), height: 1),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              GlowDot(color: item.isReady ? const Color(0xFF00E5A0) : color),
              const SizedBox(width: 10),
              Expanded(child: Text(item.itemDesc, style: TextStyle(
                fontFamily: 'SpaceMono', fontSize: 11,
                color: item.isReady ? const Color(0xFF44445A) : const Color(0xFFF0F0FF),
                decoration: item.isReady ? TextDecoration.lineThrough : null,
                decorationColor: const Color(0xFF44445A)))),
              Text('×${item.quantity.toInt()}', style: const TextStyle(
                fontFamily: 'SpaceMono', fontSize: 11, color: Color(0xFF8888AA))),
              const SizedBox(width: 8),
              TapScale(
                onTap: () { item.isReady = !item.isReady; onUpdate(); HapticFeedback.lightImpact(); },
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.isReady ? const Color(0xFF00E5A0) : color.withOpacity(0.15),
                    border: Border.all(color: item.isReady ? const Color(0xFF00E5A0) : color.withOpacity(0.4)),
                    boxShadow: [BoxShadow(
                      color: (item.isReady ? const Color(0xFF00E5A0) : color).withOpacity(0.3),
                      blurRadius: 6)]),
                  child: Icon(
                    item.isReady ? Icons.check : Icons.radio_button_unchecked,
                    size: 14, color: item.isReady ? Colors.black : color)),
              ),
            ]),
          )),
        ]),
      ),
    );
  }
}
