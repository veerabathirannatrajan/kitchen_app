import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/kds_config.dart';
import '../models/pending_order.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Fetch all active kitchens from API
  /// Fetch all active kitchens from API
  Future<List<Map<String, dynamic>>> getKitchens({String userCode = 'club'}) async {
    try {
      final response = await http.post(
        Uri.parse('${KDSConfig.baseUrl}/KitchenMst'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'UserCode': userCode}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Fetch pending orders for a kitchen
  Future<List<PendingOrder>> getPendingOrders(String kitchenCode) async {
    try {
      final response = await http.post(
        Uri.parse('${KDSConfig.baseUrl}/GetPendingItemReady'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'KitchenCode': kitchenCode}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PendingOrder.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Mark item as ready
  Future<bool> setItemReady({
    required String outletCode,
    required int kotNo,
    required String itemCode,
    required String serialNo,
    required String kitchenCode,
    required String readyBy,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${KDSConfig.baseUrl}/SetItemReady'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'OutletCode': outletCode,
          'KotNo': kotNo,
          'ItemCode': itemCode,
          'SerialNo': serialNo,
          'ItemReadyFlg': 'I',
          'ItemReadyBy': readyBy,
          'KitchenCode': kitchenCode,
          'BrnCode': KDSConfig.brnCode,
          'CompCode': KDSConfig.compCode,
        }),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get cancel KOT remarks list
  Future<List<Map<String, dynamic>>> getCancelRemarks(String outletCode) async {
    try {
      final response = await http.post(
        Uri.parse('${KDSConfig.baseUrl}/GetCancelKOTRemarksList'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'OutletCode': outletCode}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Cancel a single KOT item
  Future<bool> cancelKOTItem({
    required String outletCode,
    required int kotNo,
    required int serialNo,
    required String itemCode,
    required String itemDesc,
    required int qty,
    required String billDate,
    required String userCode,
    required String cancelRemarks,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${KDSConfig.baseUrl}/SaveCancelKOT'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode([
          {
            'BillDate': billDate,
            'KotNo': kotNo,
            'SerialNum': serialNo,
            'OutletCode': outletCode,
            'Checked': true,
            'ItemCode': itemCode,
            'ItemDesc': itemDesc,
            'Qty': qty,
            'SessionCode': 1,
            'UserCode': userCode,
            'CancelRemarks': cancelRemarks,
            'BrnCode': KDSConfig.brnCode,
            'CompCode': KDSConfig.compCode,
          }
        ]),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['Status'] == 'S';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}