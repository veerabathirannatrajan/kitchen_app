class ApiConfig {
  static const String baseUrl = 'http://115.246.237.26:8082/PCMobAppService/api/Service';

  static const String getPendingItemReady = '$baseUrl/GetPendingItemReady';
  static const String setItemReady = '$baseUrl/SetItemReady';
  static const String kitchenMst = '$baseUrl/KitchenMst';
  static const String getOutletMst = '$baseUrl/GetOutletMst';
  static const String getWaiterMst = '$baseUrl/GetWaiterMst';

  static const Duration connectionTimeout = Duration(seconds: 15);

  // Change to false for production with real API
  static const bool useMockData = false;
}