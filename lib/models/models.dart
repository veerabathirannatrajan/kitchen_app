import 'package:flutter/material.dart';

class KitchenDef {
  final String code;
  final String name;
  final String emoji;
  final Color color;
  final Color colorDim;

  const KitchenDef({
    required this.code,
    required this.name,
    required this.emoji,
    required this.color,
    required this.colorDim,
  });

  static const all = [
    KitchenDef(code: 'K17', name: 'Main Kitchen', emoji: '🔥', color: Color(0xFFFF6B35), colorDim: Color(0x33FF6B35)),
    KitchenDef(code: 'K12', name: 'Grill & Fry',  emoji: '♨️', color: Color(0xFFFF3B7A), colorDim: Color(0x33FF3B7A)),
    KitchenDef(code: 'K5',  name: 'Tandoor',      emoji: '🫙', color: Color(0xFFFFD166), colorDim: Color(0x33FFD166)),
    KitchenDef(code: 'K15', name: 'Snacks',       emoji: '🍟', color: Color(0xFF00E5A0), colorDim: Color(0x3300E5A0)),
    KitchenDef(code: 'BA',  name: 'Bar',          emoji: '🍺', color: Color(0xFF4D9FFF), colorDim: Color(0x334D9FFF)),
    KitchenDef(code: 'SN',  name: 'Desserts',     emoji: '🍨', color: Color(0xFFB66DFF), colorDim: Color(0x33B66DFF)),
  ];

  static KitchenDef? byCode(String code) {
    try { return all.firstWhere((k) => k.code == code); } catch (_) { return null; }
  }
}

class MenuItem {
  final String code;
  final String name;
  final String kitchenCode;
  final double price;
  final String uom;
  final String category;

  const MenuItem({
    required this.code, required this.name, required this.kitchenCode,
    required this.price, required this.uom, required this.category,
  });

  KitchenDef? get kitchen => KitchenDef.byCode(kitchenCode);
}

class OrderItem {
  final String id;
  final int kotNo;
  final String tableCode;
  final String itemCode;
  final String itemDesc;
  final double quantity;
  final String kitchenCode;
  bool isReady;
  bool isCancelled;
  final String waiterCode;
  final DateTime startTime;
  final String uom;
  String? remarks;

  OrderItem({
    required this.id, required this.kotNo, required this.tableCode,
    required this.itemCode, required this.itemDesc, required this.quantity,
    required this.kitchenCode, required this.isReady, required this.waiterCode,
    required this.startTime, required this.uom,
    this.isCancelled = false, this.remarks,
  });

  KitchenDef? get kitchen => KitchenDef.byCode(kitchenCode);
  Duration get waitTime => DateTime.now().difference(startTime);
  Color get urgencyColor {
    final m = waitTime.inMinutes;
    if (m >= 20) return const Color(0xFFFF3B5C);
    if (m >= 10) return const Color(0xFFFFD166);
    return const Color(0xFF00E5A0);
  }
}

class AppData {
  static final List<MenuItem> menu = [
    const MenuItem(code: '6007', name: 'Chicken Tangri Kabab (2 pcs)', kitchenCode: 'K5',  price: 190, uom: 'POR',   category: 'Starters'),
    const MenuItem(code: '6101', name: 'Fish Tikka (4 pcs)',           kitchenCode: 'K5',  price: 210, uom: 'POR',   category: 'Starters'),
    const MenuItem(code: '4804', name: 'Finger Chips',                 kitchenCode: 'K12', price: 65,  uom: 'PLATE', category: 'Starters'),
    const MenuItem(code: '4805', name: 'Chicken 65',                   kitchenCode: 'K12', price: 150, uom: 'PLATE', category: 'Starters'),
    const MenuItem(code: '5471', name: 'Chicken Fried Rice',           kitchenCode: 'K17', price: 185, uom: 'PLATE', category: 'Mains'),
    const MenuItem(code: '5472', name: 'Steamed Rice',                 kitchenCode: 'K17', price: 99,  uom: 'PLATE', category: 'Mains'),
    const MenuItem(code: '5746', name: 'Chinese Parcel Pouch',         kitchenCode: 'K17', price: 10,  uom: 'NO',    category: 'Mains'),
    const MenuItem(code: '8250', name: 'Veg Kothu Parota',             kitchenCode: 'K15', price: 120, uom: 'PLATE', category: 'Mains'),
    const MenuItem(code: '8280', name: 'Potato Wafers',                kitchenCode: 'K15', price: 55,  uom: 'PLATE', category: 'Snacks'),
    const MenuItem(code: '8281', name: 'Karasev (60gm)',               kitchenCode: 'K15', price: 55,  uom: 'PLATE', category: 'Snacks'),
    const MenuItem(code: '1004', name: 'Beer Kingfisher Pint 325ml',  kitchenCode: 'BA',  price: 113, uom: 'BOT',   category: 'Bar'),
    const MenuItem(code: '1147', name: 'Morpheus Blue (S)',            kitchenCode: 'BA',  price: 88,  uom: 'SMALL', category: 'Bar'),
    const MenuItem(code: '1410', name: 'Eristoff Vodka (S)',           kitchenCode: 'BA',  price: 60,  uom: 'SMALL', category: 'Bar'),
    const MenuItem(code: '1202', name: 'Jim Beam Whisky (S)',          kitchenCode: 'BA',  price: 127, uom: 'SMALL', category: 'Bar'),
    const MenuItem(code: '1606', name: 'Pet Soda 250ml',              kitchenCode: 'SN',  price: 12,  uom: 'BOX',   category: 'Beverages'),
    const MenuItem(code: '7060', name: 'Ice Cream Feast Choco Bar',   kitchenCode: 'SN',  price: 22,  uom: 'NO',    category: 'Desserts'),
  ];

  static List<OrderItem> orders = [
    OrderItem(id:'a1', kotNo:4,  tableCode:'T04', itemCode:'6007', itemDesc:'Chicken Tangri Kabab (2 pcs)', quantity:1, kitchenCode:'K5',  isReady:false, waiterCode:'Elangovan', startTime:DateTime.now().subtract(const Duration(minutes:12)), uom:'POR'),
    OrderItem(id:'a2', kotNo:5,  tableCode:'T05', itemCode:'6101', itemDesc:'Fish Tikka (4 pcs)',           quantity:2, kitchenCode:'K5',  isReady:false, waiterCode:'Elangovan', startTime:DateTime.now().subtract(const Duration(minutes:8)),  uom:'POR'),
    OrderItem(id:'a3', kotNo:5,  tableCode:'T05', itemCode:'7407', itemDesc:'Parcel Pouches',               quantity:2, kitchenCode:'K5',  isReady:true,  waiterCode:'Elangovan', startTime:DateTime.now().subtract(const Duration(minutes:8)),  uom:'PACK'),
    OrderItem(id:'b1', kotNo:6,  tableCode:'T06', itemCode:'5471', itemDesc:'Chicken Fried Rice',           quantity:1, kitchenCode:'K17', isReady:false, waiterCode:'Elangovan', startTime:DateTime.now().subtract(const Duration(minutes:5)),  uom:'PLATE'),
    OrderItem(id:'b2', kotNo:11, tableCode:'T06', itemCode:'5746', itemDesc:'Chinese Parcel Pouch',         quantity:1, kitchenCode:'K17', isReady:false, waiterCode:'Elangovan', startTime:DateTime.now().subtract(const Duration(minutes:3)),  uom:'NO'),
    OrderItem(id:'b3', kotNo:12, tableCode:'T07', itemCode:'5472', itemDesc:'Steamed Rice',                 quantity:1, kitchenCode:'K17', isReady:false, waiterCode:'Elangovan', startTime:DateTime.now().subtract(const Duration(minutes:22)), uom:'PLATE'),
    OrderItem(id:'c1', kotNo:14, tableCode:'T01', itemCode:'4804', itemDesc:'Finger Chips',                 quantity:1, kitchenCode:'K12', isReady:false, waiterCode:'bar',       startTime:DateTime.now().subtract(const Duration(minutes:2)),  uom:'PLATE'),
    OrderItem(id:'c2', kotNo:14, tableCode:'T01', itemCode:'4805', itemDesc:'Chicken 65',                   quantity:2, kitchenCode:'K12', isReady:true,  waiterCode:'bar',       startTime:DateTime.now().subtract(const Duration(minutes:2)),  uom:'PLATE'),
    OrderItem(id:'d1', kotNo:2,  tableCode:'T02', itemCode:'8280', itemDesc:'Potato Wafers',                quantity:1, kitchenCode:'K15', isReady:false, waiterCode:'Elangovan', startTime:DateTime.now().subtract(const Duration(minutes:20)), uom:'PLATE'),
    OrderItem(id:'d2', kotNo:2,  tableCode:'T02', itemCode:'8281', itemDesc:'Karasev (60gm)',               quantity:1, kitchenCode:'K15', isReady:true,  waiterCode:'Elangovan', startTime:DateTime.now().subtract(const Duration(minutes:20)), uom:'PLATE'),
    OrderItem(id:'d3', kotNo:10, tableCode:'T04', itemCode:'8250', itemDesc:'Veg Kothu Parota',             quantity:1, kitchenCode:'K15', isReady:false, waiterCode:'bar',       startTime:DateTime.now().subtract(const Duration(minutes:7)),  uom:'PLATE'),
    OrderItem(id:'e1', kotNo:9,  tableCode:'T09', itemCode:'1004', itemDesc:'Beer Kingfisher Pint',         quantity:2, kitchenCode:'BA',  isReady:false, waiterCode:'bar',       startTime:DateTime.now().subtract(const Duration(minutes:1)),  uom:'BOT'),
    OrderItem(id:'e2', kotNo:9,  tableCode:'T09', itemCode:'1147', itemDesc:'Morpheus Blue (S)',            quantity:2, kitchenCode:'BA',  isReady:false, waiterCode:'bar',       startTime:DateTime.now().subtract(const Duration(minutes:1)),  uom:'SMALL'),
    OrderItem(id:'f1', kotNo:13, tableCode:'T11', itemCode:'7060', itemDesc:'Ice Cream Feast Choco Bar',    quantity:2, kitchenCode:'SN',  isReady:false, waiterCode:'Elangovan', startTime:DateTime.now().subtract(const Duration(minutes:6)),  uom:'NO'),
    OrderItem(id:'f2', kotNo:13, tableCode:'T11', itemCode:'1606', itemDesc:'Pet Soda 250ml',               quantity:2, kitchenCode:'SN',  isReady:true,  waiterCode:'Elangovan', startTime:DateTime.now().subtract(const Duration(minutes:6)),  uom:'BOX'),
  ];

  static List<String> get activeTables {
    final ts = orders.map((o) => o.tableCode).toSet().toList()..sort();
    return ts;
  }

  static List<OrderItem> ordersForTable(String table) =>
      orders.where((o) => o.tableCode == table).toList();

  static List<OrderItem> ordersForKitchen(String code) =>
      orders.where((o) => o.kitchenCode == code).toList();

  static int pendingForKitchen(String code) =>
      orders.where((o) => o.kitchenCode == code && !o.isReady).length;

  static int pendingForTable(String table) =>
      orders.where((o) => o.tableCode == table && !o.isReady).length;

  static int nextKotNo() =>
      orders.isEmpty ? 1 : orders.map((o) => o.kotNo).reduce((a, b) => a > b ? a : b) + 1;
}
