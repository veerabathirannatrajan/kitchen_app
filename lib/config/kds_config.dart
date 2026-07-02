class KDSConfig {
  // ===================================================
  // CHANGE THESE FOR EACH CLIENT INSTALLATION
  // ===================================================

  // Server Settings
  static const String serverIP = '192.168.1.10';     // Local KDS Server IP
  static const int serverPort = 8082;                 // API Port

  // Database Settings (for future direct DB connection)
  static const String dbServerIP = '192.168.1.20';   // Database Server IP
  static const int dbPort = 1433;                    // SQL Server Port
  static const String dbName = 'MAXIM_COSMO';
  static const String dbUser = 'kds_user';
  static const String dbPassword = 'kds_pass_123';

  // Branch/Company Codes
  static const String brnCode = '001';
  static const String compCode = '001';

  // ===================================================
  // AUTO-GENERATED - DON'T CHANGE
  // ===================================================
  static String get baseUrl => 'http://$serverIP:$serverPort/PCMobAppService/api/Service';
}
