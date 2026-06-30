import 'kds_config.dart';

class ApiConfig {
  // Base URL from KDS Config
  static String get baseUrl => KDSConfig.baseUrl;

  // API Endpoints
  static String get getPendingItemReady => '$baseUrl/GetPendingItemReady';
  static String get setItemReady => '$baseUrl/SetItemReady';
  static String get kitchenMst => '$baseUrl/KitchenMst';
  static String get getOutletMst => '$baseUrl/GetOutletMst';
  static String get getWaiterMst => '$baseUrl/GetWaiterMst';

  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 15);

  // Production mode - ALWAYS false (no mock data)
  static const bool useMockData = false;
}