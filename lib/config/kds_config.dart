class KDSConfig {

  // KDS Application Server
  static const String serverIP = '115.246.237.26';
  static const int serverPort = 8082;

  // Branch & Company Codes
  static const String brnCode = '001';
  static const String compCode = '001';


  // ===================================================
  static String get baseUrl => 'http://$serverIP:$serverPort/CosmoKDSAPI/api/Service';
}

