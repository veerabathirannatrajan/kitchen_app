import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/pending_order.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<List<PendingOrder>> getPendingOrders(String kitchenCode) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getPendingItemReady),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'KitchenCode': kitchenCode}),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PendingOrder.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

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
        Uri.parse(ApiConfig.setItemReady),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'OutletCode': outletCode,
          'KotNo': kotNo,
          'ItemCode': itemCode,
          'SerialNo': serialNo,
          'ItemReadyFlg': 'I',
          'ItemReadyBy': readyBy,
          'KitchenCode': kitchenCode,
          'BrnCode': '001',
          'CompCode': '001',
        }),
      ).timeout(ApiConfig.connectionTimeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Error setting item ready: $e');
      return false;
    }
  }
}