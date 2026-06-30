import 'package:flutter/material.dart';
import 'dart:async';
import '../config/kds_config.dart';
import '../config/app_colors.dart';
import '../config/responsive.dart';
import '../services/api_service.dart';

class ConnectionStatusScreen extends StatefulWidget {
  const ConnectionStatusScreen({super.key});

  @override
  State<ConnectionStatusScreen> createState() => _ConnectionStatusScreenState();
}

class _ConnectionStatusScreenState extends State<ConnectionStatusScreen> with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();

  bool _isServerConnected = false;
  bool _isDatabaseReachable = false;
  int _kitchenCount = 0;
  int _pendingOrders = 0;
  String _lastSyncTime = '';
  String _statusMessage = 'Tap "Test Connection" to check';
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _autoTestConnection();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _autoTestConnection();
    }
  }

  Future<void> _autoTestConnection() async {
    await Future.delayed(const Duration(milliseconds: 800));
    await _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _statusMessage = 'Testing connection...';
    });

    try {
      final kitchens = await _apiService.getKitchens();

      if (kitchens.isNotEmpty) {
        setState(() {
          _isServerConnected = true;
          _kitchenCount = kitchens.length;
          _lastSyncTime = _formatTime(DateTime.now());
          _statusMessage = 'Connected successfully';
        });

        int totalPending = 0;
        for (final kitchen in kitchens.take(5)) {
          final orders = await _apiService.getPendingOrders(
            kitchen['KitchenCode']?.toString() ?? 'MK',
          );
          totalPending += orders.fold(0, (sum, order) => sum + order.items.length);
        }

        setState(() {
          _isDatabaseReachable = true;
          _pendingOrders = totalPending;
        });
      } else {
        setState(() {
          _isServerConnected = false;
          _statusMessage = 'Server not responding';
        });
      }
    } catch (e) {
      setState(() {
        _isServerConnected = false;
        _isDatabaseReachable = false;
        _statusMessage = 'Connection failed';
      });
    }

    setState(() => _isTesting = false);
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final rs = Responsive.fontSize(context, 1.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.bgGradient,
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(rs),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(16 * rs),
                  child: Column(
                    children: [
                      _buildOverallStatus(rs),
                      SizedBox(height: 14 * rs),
                      _buildNetworkCard(rs),
                      SizedBox(height: 14 * rs),
                      _buildServerCard(rs),
                      SizedBox(height: 14 * rs),
                      _buildDatabaseCard(rs),
                      SizedBox(height: 14 * rs),
                      _buildConfigCard(rs),
                      SizedBox(height: 14 * rs),
                      _buildSyncCard(rs),
                      SizedBox(height: 20 * rs),
                      _buildTestButton(rs),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double rs) {
    return Container(
      padding: EdgeInsets.fromLTRB(16 * rs, 12 * rs, 16 * rs, 12 * rs),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(10 * rs),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12 * rs),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18 * rs, color: const Color(0xFF666666)),
          ),
        ),
        SizedBox(width: 12 * rs),
        Expanded(
          child: Text('System Status', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 20 * rs, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ),
        Container(
          width: 10 * rs, height: 10 * rs,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isServerConnected ? AppColors.statusReady : AppColors.statusPending,
            boxShadow: [BoxShadow(color: (_isServerConnected ? AppColors.statusReady : AppColors.statusPending).withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 2)],
          ),
        ),
        SizedBox(width: 6 * rs),
        Text(_isServerConnected ? 'LIVE' : 'OFFLINE', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11 * rs, fontWeight: FontWeight.w700, color: _isServerConnected ? AppColors.statusReady : AppColors.statusPending, letterSpacing: 1)),
      ]),
    );
  }

  Widget _buildOverallStatus(double rs) {
    final ok = _isServerConnected && _isDatabaseReachable;
    return Container(
      padding: EdgeInsets.all(16 * rs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * rs),
        gradient: LinearGradient(colors: [ok ? AppColors.statusReady.withValues(alpha: 0.12) : AppColors.statusPending.withValues(alpha: 0.12), ok ? AppColors.statusReady.withValues(alpha: 0.04) : AppColors.statusPending.withValues(alpha: 0.04)]),
        border: Border.all(color: ok ? AppColors.statusReady.withValues(alpha: 0.25) : AppColors.statusPending.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Container(
          padding: EdgeInsets.all(12 * rs),
          decoration: BoxDecoration(shape: BoxShape.circle, color: ok ? AppColors.statusReady.withValues(alpha: 0.18) : AppColors.statusPending.withValues(alpha: 0.18)),
          child: Icon(ok ? Icons.cloud_done_rounded : Icons.cloud_off_rounded, size: 28 * rs, color: ok ? AppColors.statusReady : AppColors.statusPending),
        ),
        SizedBox(width: 14 * rs),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ok ? 'All Systems Operational' : 'Connection Issue', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 15 * rs, fontWeight: FontWeight.w700, color: ok ? AppColors.statusReady : AppColors.statusPending)),
            SizedBox(height: 3 * rs),
            Text(_statusMessage, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10 * rs, color: AppColors.textMedium)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildNetworkCard(double rs) {
    return _buildCard(
      rs: rs,
      icon: Icons.wifi_rounded,
      iconColor: AppColors.primaryBlue,
      title: 'Network',
      children: [
        _buildInfoRow(rs, 'Server', '${KDSConfig.serverIP}:${KDSConfig.serverPort}'),
        _buildInfoRow(rs, 'API URL', KDSConfig.baseUrl),
        _buildInfoRow(rs, 'Type', 'LAN'),
      ],
    );
  }

  Widget _buildServerCard(double rs) {
    return _buildCard(
      rs: rs,
      icon: Icons.dns_rounded,
      iconColor: _isServerConnected ? AppColors.statusReady : AppColors.statusPending,
      title: 'Application Server',
      status: _isServerConnected ? 'ONLINE' : 'OFFLINE',
      statusColor: _isServerConnected ? AppColors.statusReady : AppColors.statusPending,
      children: [
        _buildInfoRow(rs, 'Kitchens Loaded', '$_kitchenCount'),
      ],
    );
  }

  Widget _buildDatabaseCard(double rs) {
    return _buildCard(
      rs: rs,
      icon: Icons.storage_rounded,
      iconColor: _isDatabaseReachable ? AppColors.statusReady : AppColors.statusPending,
      title: 'Database Server',
      status: _isDatabaseReachable ? 'ONLINE' : 'OFFLINE',
      statusColor: _isDatabaseReachable ? AppColors.statusReady : AppColors.statusPending,
      children: [
        _buildInfoRow(rs, 'Host', '${KDSConfig.dbServerIP}:${KDSConfig.dbPort}'),
        _buildInfoRow(rs, 'Database', KDSConfig.dbName),
        _buildInfoRow(rs, 'Pending Orders', '$_pendingOrders'),
      ],
    );
  }

  Widget _buildConfigCard(double rs) {
    return _buildCard(
      rs: rs,
      icon: Icons.settings_rounded,
      iconColor: AppColors.primaryOrange,
      title: 'Configuration',
      children: [
        _buildInfoRow(rs, 'IP', KDSConfig.serverIP),
        _buildInfoRow(rs, 'Port', '${KDSConfig.serverPort}'),
        _buildInfoRow(rs, 'Branch', KDSConfig.brnCode),
        _buildInfoRow(rs, 'Company', KDSConfig.compCode),
      ],
    );
  }

  Widget _buildSyncCard(double rs) {
    return _buildCard(
      rs: rs,
      icon: Icons.sync_rounded,
      iconColor: AppColors.primaryBlue,
      title: 'Sync Info',
      children: [
        _buildInfoRow(rs, 'Last Sync', _lastSyncTime.isEmpty ? 'Never' : _lastSyncTime),
        _buildInfoRow(rs, 'Kitchens', '$_kitchenCount'),
        _buildInfoRow(rs, 'Orders', '$_pendingOrders'),
      ],
    );
  }

  Widget _buildCard({
    required double rs,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? status,
    Color? statusColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16 * rs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * rs),
        color: Colors.white.withValues(alpha: 0.75),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: EdgeInsets.all(8 * rs),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10 * rs)),
            child: Icon(icon, size: 18 * rs, color: iconColor),
          ),
          SizedBox(width: 10 * rs),
          Expanded(child: Text(title, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 14 * rs, fontWeight: FontWeight.w700, color: AppColors.textDark))),
          if (status != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8 * rs, vertical: 3 * rs),
              decoration: BoxDecoration(color: statusColor!.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12 * rs)),
              child: Text(status, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9 * rs, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 1)),
            ),
        ]),
        SizedBox(height: 12 * rs),
        ...children,
      ]),
    );
  }

  Widget _buildInfoRow(double rs, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * rs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80 * rs,
            child: Text(label, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11 * rs, color: AppColors.textLight)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11 * rs, fontWeight: FontWeight.w600, color: AppColors.textDark),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(double rs) {
    return GestureDetector(
      onTap: _isTesting ? null : _testConnection,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16 * rs),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.primaryOrange, AppColors.primaryOrange.withValues(alpha: 0.8)]),
          borderRadius: BorderRadius.circular(16 * rs),
          boxShadow: [
            BoxShadow(color: AppColors.primaryOrange.withValues(alpha: 0.35), blurRadius: 12, spreadRadius: 1, offset: Offset(0, 5 * rs)),
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _isTesting
              ? SizedBox(width: 18 * rs, height: 18 * rs, child: const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              : Icon(Icons.refresh_rounded, size: 20 * rs, color: Colors.white),
          SizedBox(width: 10 * rs),
          Text(_isTesting ? 'TESTING...' : 'TEST CONNECTION', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 14 * rs, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2)),
        ]),
      ),
    );
  }
}