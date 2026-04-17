import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:webview_flutter/webview_flutter.dart';

class KitchenOrdersScreen extends StatefulWidget {
  final String kitchenCode;
  final String kitchenName;
  final Color kitchenColor;

  const KitchenOrdersScreen({
    super.key,
    required this.kitchenCode,
    required this.kitchenName,
    required this.kitchenColor,
  });

  @override
  State<KitchenOrdersScreen> createState() => _KitchenOrdersScreenState();
}

class _KitchenOrdersScreenState extends State<KitchenOrdersScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  // Mock orders data
  List<PendingOrder> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _loadMockOrders();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _loadMockOrders() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _orders = _generateMockOrders();
        _isLoading = false;
      });
    });
  }

  List<PendingOrder> _generateMockOrders() {
    return [
      PendingOrder(
        kotNo: '101',
        tableNo: 'T05',
        waiterName: 'K.ELUMALAI',
        orderTime: '10:30 AM',
        items: [
          OrderItem(name: 'Grilled Chicken', qty: 2, status: ItemStatus.pending),
          OrderItem(name: 'Butter Naan', qty: 3, status: ItemStatus.pending),
        ],
        color: const Color(0xFFFF6B35),
      ),
      PendingOrder(
        kotNo: '102',
        tableNo: 'T12',
        waiterName: 'K.KANNAN',
        orderTime: '10:45 AM',
        items: [
          OrderItem(name: 'Chicken Biryani', qty: 2, status: ItemStatus.pending),
          OrderItem(name: 'Raita', qty: 2, status: ItemStatus.pending),
          OrderItem(name: 'Gulab Jamun', qty: 2, status: ItemStatus.pending),
        ],
        color: const Color(0xFF4D9FFF),
      ),
      PendingOrder(
        kotNo: '103',
        tableNo: 'T08',
        waiterName: 'M.SURESH',
        orderTime: '11:00 AM',
        items: [
          OrderItem(name: 'Paneer Tikka', qty: 1, status: ItemStatus.pending),
          OrderItem(name: 'Dal Makhani', qty: 1, status: ItemStatus.cooking),
          OrderItem(name: 'Jeera Rice', qty: 1, status: ItemStatus.pending),
        ],
        color: const Color(0xFF27AE60),
      ),
      PendingOrder(
        kotNo: '104',
        tableNo: 'T03',
        waiterName: 'R.PARTHIBAN',
        orderTime: '11:15 AM',
        items: [
          OrderItem(name: 'Tandoori Chicken', qty: 1, status: ItemStatus.pending),
          OrderItem(name: 'Rumali Roti', qty: 4, status: ItemStatus.pending),
        ],
        color: const Color(0xFFE74C3C),
      ),
    ];
  }

  void _markOrderComplete(PendingOrder order) {
    setState(() {
      _orders.remove(order);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'KOT #${order.kotNo} marked as complete!',
          style: const TextStyle(fontFamily: 'SpaceMono'),
        ),
        backgroundColor: widget.kitchenColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markItemReady(PendingOrder order, OrderItem item) {
    setState(() {
      item.status = ItemStatus.ready;
    });

    // Check if all items are ready
    if (order.items.every((item) => item.status == ItemStatus.ready)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _markOrderComplete(order);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF5F0),
                Color(0xFFFFF0E6),
                Color(0xFFFFE8D9),
                Color(0xFFFFDBC8),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                ..._buildBackgroundElements(),
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _fadeController,
                    curve: Curves.easeOut,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: _isLoading ? _buildLoadingState() : _buildOrdersList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundElements() {
    return [
      AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.kitchenColor.withOpacity(0.08 * _pulseController.value),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: widget.kitchenColor,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.kitchenColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 16,
                      color: widget.kitchenColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_orders.length} PENDING',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.kitchenColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.kitchenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.kitchen_rounded,
                  size: 24,
                  color: widget.kitchenColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.kitchenName,
                      style: const TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D2D2D),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Code: ${widget.kitchenCode} • Active Orders',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 11,
                        color: const Color(0xFF888888).withOpacity(0.8),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(widget.kitchenColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading orders...',
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 14,
              color: widget.kitchenColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: widget.kitchenColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 60,
                color: widget.kitchenColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'All orders completed!',
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: widget.kitchenColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting for new orders...',
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 12,
                color: const Color(0xFF888888).withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(_orders[index]);
      },
    );
  }

  Widget _buildOrderCard(PendingOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.85),
                  Colors.white.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: order.color.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: order.color.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: order.color.withOpacity(0.08),
                    border: Border(
                      bottom: BorderSide(
                        color: order.color.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: order.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.receipt_rounded,
                          color: order.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KOT #${order.kotNo} • Table ${order.tableNo}',
                              style: const TextStyle(
                                fontFamily: 'SpaceMono',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                            Text(
                              'Waiter: ${order.waiterName} • ${order.orderTime}',
                              style: TextStyle(
                                fontFamily: 'SpaceMono',
                                fontSize: 11,
                                color: const Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: order.color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${order.items.length} items',
                          style: const TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Items
                ...order.items.map((item) => _buildOrderItem(order, item)),
                // Complete Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _markOrderComplete(order),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              order.color,
                              order.color.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: order.color.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'MARK AS COMPLETE',
                            style: TextStyle(
                              fontFamily: 'SpaceMono',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(PendingOrder order, OrderItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: order.color.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: item.status != ItemStatus.ready
                ? () => _markItemReady(order, item)
                : null,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.status == ItemStatus.ready
                    ? const Color(0xFF27AE60)
                    : Colors.transparent,
                border: Border.all(
                  color: item.status == ItemStatus.ready
                      ? const Color(0xFF27AE60)
                      : order.color.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: item.status == ItemStatus.ready
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: item.status == ItemStatus.ready
                        ? const Color(0xFF888888)
                        : const Color(0xFF2D2D2D),
                    decoration: item.status == ItemStatus.ready
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (item.status == ItemStatus.cooking)
                  Text(
                    'Cooking...',
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 10,
                      color: const Color(0xFFFF6B35),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: order.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'x${item.qty}',
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: order.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PendingOrder {
  final String kotNo;
  final String tableNo;
  final String waiterName;
  final String orderTime;
  final List<OrderItem> items;
  final Color color;

  PendingOrder({
    required this.kotNo,
    required this.tableNo,
    required this.waiterName,
    required this.orderTime,
    required this.items,
    required this.color,
  });
}

class OrderItem {
  final String name;
  final int qty;
  ItemStatus status;

  OrderItem({
    required this.name,
    required this.qty,
    required this.status,
  });
}

enum ItemStatus {
  pending,
  cooking,
  ready,
}