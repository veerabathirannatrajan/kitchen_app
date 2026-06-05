import 'package:flutter/material.dart';
import 'order_item.dart';

class PendingOrder {
  final String billDate;
  final String outletCode;
  final String outletDesc;
  final String kotNo;
  final String memberCode;
  final String memberName;
  final String waiterCode;
  final String waiterDesc;
  final String colorClass;
  final String createdDate;
  final List<OrderItem> items;
  bool isAllComplete;

  PendingOrder({
    required this.billDate,
    required this.outletCode,
    required this.outletDesc,
    required this.kotNo,
    required this.memberCode,
    required this.memberName,
    required this.waiterCode,
    required this.waiterDesc,
    required this.colorClass,
    required this.createdDate,
    required this.items,
    this.isAllComplete = false,
  });

  factory PendingOrder.fromJson(Map<String, dynamic> json) {
    final kotItems = (json['kotItems'] as List?)
        ?.map((item) => OrderItem.fromJson(item))
        .toList() ?? [];

    return PendingOrder(
      billDate: json['BillDate']?.toString() ?? '',
      outletCode: json['OutletCode']?.toString() ?? '',
      outletDesc: json['OutletDesc']?.toString() ?? '',
      kotNo: json['KotNo']?.toString() ?? '',
      memberCode: json['MemberCode']?.toString() ?? '',
      memberName: json['MemberName']?.toString() ?? '',
      waiterCode: json['WaiterCode']?.toString() ?? '',
      waiterDesc: json['WaiterDesc']?.toString() ?? '',
      colorClass: json['ColorClass']?.toString() ?? 'Level1',
      createdDate: json['CreatedDate']?.toString() ?? '',
      items: kotItems,
    );
  }

  // For mock data compatibility
  String get tableNo => memberCode;
  String get waiterName => waiterDesc;
  String get orderTime => createdDate;
  String get customerName => memberName;
  int get priority => colorClass == 'Level1' ? 1 : (colorClass == 'Level2' ? 2 : 3);
  int get pax => 2;

  Color get displayColor {
    switch (colorClass) {
      case 'Level1': return const Color(0xFFFF6B35);
      case 'Level2': return const Color(0xFFE67E22);
      case 'Level3': return const Color(0xFFE74C3C);
      default: return const Color(0xFFFF6B35);
    }
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.qty);
  int get completedItems => items.where((item) => item.status == ItemStatus.ready).length;
}