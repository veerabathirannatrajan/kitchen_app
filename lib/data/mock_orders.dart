import 'package:flutter/material.dart';

enum ItemStatus {
  pending,
  cooking,
  ready,
}

class OrderItem {
  final String name;
  final int qty;
  ItemStatus status;
  final String? specialInstructions;
  String? endTime;

  OrderItem({
    required this.name,
    required this.qty,
    required this.status,
    this.specialInstructions,
    this.endTime,
  });
}

class PendingOrder {
  final String kotNo;
  final String tableNo;
  final String waiterName;
  final String waiterImage;
  final String orderTime;
  final int priority; // 1=High, 2=Medium, 3=Low
  final List<OrderItem> items;
  final Color color;
  final String customerName;
  final int pax;
  bool isAllComplete;

  PendingOrder({
    required this.kotNo,
    required this.tableNo,
    required this.waiterName,
    required this.waiterImage,
    required this.orderTime,
    required this.priority,
    required this.items,
    required this.color,
    required this.customerName,
    required this.pax,
    this.isAllComplete = false,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.qty);
  int get completedItems => items.where((item) => item.status == ItemStatus.ready).length;
  double get progress => items.isEmpty ? 0 : completedItems / items.length;
}

class KitchenMockData {
  static List<PendingOrder> getOrdersForKitchen(String kitchenCode) {
    switch (kitchenCode) {
      case 'MK':
        return _mainKitchenOrders();
      case 'K1':
        return _continentalKitchenOrders();
      case 'K5':
        return _tandooriKitchenOrders();
      case 'K11':
        return _arusuvaiKitchenOrders();
      case 'K4':
        return _chineseKitchenOrders();
      case 'K22':
        return _newContinentalKitchenOrders();
      case 'K23':
        return _vegetarianKitchenOrders();
      default:
        return [];
    }
  }

  // MAIN KITCHEN (MK) - 6 Orders
  static List<PendingOrder> _mainKitchenOrders() {
    return [
      PendingOrder(
        kotNo: 'MK-101',
        tableNo: 'T05',
        waiterName: 'K. Elumalai',
        waiterImage: 'https://randomuser.me/api/portraits/men/32.jpg',
        orderTime: '10:30 AM',
        priority: 1,
        customerName: 'Mr. Sharma',
        pax: 4,
        color: const Color(0xFFFF6B35),
        items: [
          OrderItem(name: 'Grilled Chicken', qty: 2, status: ItemStatus.pending, specialInstructions: 'Extra spicy'),
          OrderItem(name: 'Butter Naan', qty: 3, status: ItemStatus.cooking, specialInstructions: null),
          OrderItem(name: 'Dal Makhani', qty: 1, status: ItemStatus.pending, specialInstructions: 'Less oil'),
          OrderItem(name: 'Jeera Rice', qty: 1, status: ItemStatus.ready, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'MK-102',
        tableNo: 'T12',
        waiterName: 'K. Kannan',
        waiterImage: 'https://randomuser.me/api/portraits/men/45.jpg',
        orderTime: '10:45 AM',
        priority: 2,
        customerName: 'Mrs. Patel',
        pax: 2,
        color: const Color(0xFF4D9FFF),
        items: [
          OrderItem(name: 'Chicken Biryani', qty: 2, status: ItemStatus.pending, specialInstructions: 'Boneless'),
          OrderItem(name: 'Raita', qty: 2, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Gulab Jamun', qty: 2, status: ItemStatus.cooking, specialInstructions: 'Warm'),
        ],
      ),
      PendingOrder(
        kotNo: 'MK-103',
        tableNo: 'T08',
        waiterName: 'M. Suresh',
        waiterImage: 'https://randomuser.me/api/portraits/men/22.jpg',
        orderTime: '11:00 AM',
        priority: 3,
        customerName: 'Dr. Gupta',
        pax: 3,
        color: const Color(0xFF27AE60),
        items: [
          OrderItem(name: 'Paneer Tikka', qty: 1, status: ItemStatus.pending, specialInstructions: 'No onion'),
          OrderItem(name: 'Dal Tadka', qty: 1, status: ItemStatus.cooking, specialInstructions: null),
          OrderItem(name: 'Tandoori Roti', qty: 4, status: ItemStatus.pending, specialInstructions: 'Crispy'),
        ],
      ),
      PendingOrder(
        kotNo: 'MK-104',
        tableNo: 'T03',
        waiterName: 'R. Parthiban',
        waiterImage: 'https://randomuser.me/api/portraits/men/52.jpg',
        orderTime: '11:15 AM',
        priority: 1,
        customerName: 'Mr. Kumar',
        pax: 6,
        color: const Color(0xFFE74C3C),
        items: [
          OrderItem(name: 'Mutton Biryani', qty: 3, status: ItemStatus.pending, specialInstructions: 'Extra spicy'),
          OrderItem(name: 'Chicken 65', qty: 2, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Raita', qty: 3, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Gulab Jamun', qty: 6, status: ItemStatus.pending, specialInstructions: 'Warm'),
        ],
      ),
      PendingOrder(
        kotNo: 'MK-105',
        tableNo: 'T17',
        waiterName: 'S. Srikanth',
        waiterImage: 'https://randomuser.me/api/portraits/men/36.jpg',
        orderTime: '11:30 AM',
        priority: 2,
        customerName: 'Mrs. Lakshmi',
        pax: 2,
        color: const Color(0xFF8E44AD),
        items: [
          OrderItem(name: 'Fish Curry', qty: 1, status: ItemStatus.cooking, specialInstructions: 'Less spicy'),
          OrderItem(name: 'Steam Rice', qty: 2, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Papad', qty: 2, status: ItemStatus.ready, specialInstructions: 'Roasted'),
        ],
      ),
      PendingOrder(
        kotNo: 'MK-106',
        tableNo: 'T22',
        waiterName: 'G. Sankar',
        waiterImage: 'https://randomuser.me/api/portraits/men/41.jpg',
        orderTime: '11:45 AM',
        priority: 3,
        customerName: 'Mr. Rahman',
        pax: 4,
        color: const Color(0xFFD35400),
        items: [
          OrderItem(name: 'Chicken Curry', qty: 2, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Parotta', qty: 4, status: ItemStatus.pending, specialInstructions: 'Flaky'),
          OrderItem(name: 'Egg Masala', qty: 1, status: ItemStatus.cooking, specialInstructions: null),
        ],
      ),
    ];
  }

  // CONTINENTAL KITCHEN (K1) - 5 Orders
  static List<PendingOrder> _continentalKitchenOrders() {
    return [
      PendingOrder(
        kotNo: 'K1-201',
        tableNo: 'T03',
        waiterName: 'R. Parthiban',
        waiterImage: 'https://randomuser.me/api/portraits/men/52.jpg',
        orderTime: '10:15 AM',
        priority: 1,
        customerName: 'Ms. Jennifer',
        pax: 2,
        color: const Color(0xFFE74C3C),
        items: [
          OrderItem(name: 'Grilled Salmon', qty: 1, status: ItemStatus.cooking, specialInstructions: 'Medium rare'),
          OrderItem(name: 'Mashed Potato', qty: 2, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Caesar Salad', qty: 1, status: ItemStatus.ready, specialInstructions: 'Dressing on side'),
        ],
      ),
      PendingOrder(
        kotNo: 'K1-202',
        tableNo: 'T07',
        waiterName: 'S. Srikanth',
        waiterImage: 'https://randomuser.me/api/portraits/men/36.jpg',
        orderTime: '11:20 AM',
        priority: 2,
        customerName: 'Mr. Anderson',
        pax: 4,
        color: const Color(0xFF8E44AD),
        items: [
          OrderItem(name: 'Pasta Alfredo', qty: 2, status: ItemStatus.pending, specialInstructions: 'Extra cheese'),
          OrderItem(name: 'Garlic Bread', qty: 2, status: ItemStatus.cooking, specialInstructions: null),
          OrderItem(name: 'Tiramisu', qty: 2, status: ItemStatus.pending, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K1-203',
        tableNo: 'T11',
        waiterName: 'K. Elumalai',
        waiterImage: 'https://randomuser.me/api/portraits/men/32.jpg',
        orderTime: '11:35 AM',
        priority: 1,
        customerName: 'Dr. Williams',
        pax: 2,
        color: const Color(0xFF3498DB),
        items: [
          OrderItem(name: 'Beef Steak', qty: 1, status: ItemStatus.pending, specialInstructions: 'Well done'),
          OrderItem(name: 'French Fries', qty: 1, status: ItemStatus.pending, specialInstructions: 'Crispy'),
          OrderItem(name: 'Onion Rings', qty: 1, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Coleslaw', qty: 1, status: ItemStatus.pending, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K1-204',
        tableNo: 'T19',
        waiterName: 'M. Suresh',
        waiterImage: 'https://randomuser.me/api/portraits/men/22.jpg',
        orderTime: '12:00 PM',
        priority: 2,
        customerName: 'Mrs. Taylor',
        pax: 3,
        color: const Color(0xFF2ECC71),
        items: [
          OrderItem(name: 'Margherita Pizza', qty: 1, status: ItemStatus.cooking, specialInstructions: 'Thin crust'),
          OrderItem(name: 'Spaghetti Bolognese', qty: 1, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Bruschetta', qty: 2, status: ItemStatus.ready, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K1-205',
        tableNo: 'T25',
        waiterName: 'K. Kannan',
        waiterImage: 'https://randomuser.me/api/portraits/men/45.jpg',
        orderTime: '12:15 PM',
        priority: 3,
        customerName: 'Mr. Robert',
        pax: 1,
        color: const Color(0xFFE67E22),
        items: [
          OrderItem(name: 'Grilled Sandwich', qty: 1, status: ItemStatus.pending, specialInstructions: 'No mayo'),
          OrderItem(name: 'French Fries', qty: 1, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Cold Coffee', qty: 1, status: ItemStatus.pending, specialInstructions: 'Less sugar'),
        ],
      ),
    ];
  }

  // TANDOORI KITCHEN (K5) - 6 Orders
  static List<PendingOrder> _tandooriKitchenOrders() {
    return [
      PendingOrder(
        kotNo: 'K5-301',
        tableNo: 'T15',
        waiterName: 'G. Sankar',
        waiterImage: 'https://randomuser.me/api/portraits/men/41.jpg',
        orderTime: '10:50 AM',
        priority: 1,
        customerName: 'Mr. Singh',
        pax: 6,
        color: const Color(0xFFE67E22),
        items: [
          OrderItem(name: 'Tandoori Chicken', qty: 2, status: ItemStatus.cooking, specialInstructions: 'Extra masala'),
          OrderItem(name: 'Seekh Kebab', qty: 3, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Rumali Roti', qty: 6, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Green Chutney', qty: 2, status: ItemStatus.ready, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K5-302',
        tableNo: 'T09',
        waiterName: 'V. Radhakrishnan',
        waiterImage: 'https://randomuser.me/api/portraits/men/28.jpg',
        orderTime: '11:30 AM',
        priority: 2,
        customerName: 'Mrs. Kaur',
        pax: 2,
        color: const Color(0xFFC0392B),
        items: [
          OrderItem(name: 'Chicken Tikka', qty: 1, status: ItemStatus.pending, specialInstructions: 'Creamy'),
          OrderItem(name: 'Naan', qty: 2, status: ItemStatus.cooking, specialInstructions: 'Butter'),
        ],
      ),
      PendingOrder(
        kotNo: 'K5-303',
        tableNo: 'T06',
        waiterName: 'B. Velayutham',
        waiterImage: 'https://randomuser.me/api/portraits/men/55.jpg',
        orderTime: '11:45 AM',
        priority: 1,
        customerName: 'Mr. Malhotra',
        pax: 4,
        color: const Color(0xFFFF6B35),
        items: [
          OrderItem(name: 'Paneer Tikka', qty: 2, status: ItemStatus.pending, specialInstructions: 'Spicy'),
          OrderItem(name: 'Tandoori Roti', qty: 4, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Dal Makhani', qty: 1, status: ItemStatus.cooking, specialInstructions: 'Creamy'),
        ],
      ),
      PendingOrder(
        kotNo: 'K5-304',
        tableNo: 'T18',
        waiterName: 'K. Suresh',
        waiterImage: 'https://randomuser.me/api/portraits/men/48.jpg',
        orderTime: '12:10 PM',
        priority: 2,
        customerName: 'Mr. Chopra',
        pax: 3,
        color: const Color(0xFF4D9FFF),
        items: [
          OrderItem(name: 'Afghani Chicken', qty: 1, status: ItemStatus.cooking, specialInstructions: null),
          OrderItem(name: 'Butter Naan', qty: 3, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Pudina Paratha', qty: 2, status: ItemStatus.pending, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K5-305',
        tableNo: 'T21',
        waiterName: 'N. Ramesh',
        waiterImage: 'https://randomuser.me/api/portraits/men/33.jpg',
        orderTime: '12:25 PM',
        priority: 3,
        customerName: 'Mrs. Bedi',
        pax: 2,
        color: const Color(0xFF27AE60),
        items: [
          OrderItem(name: 'Malai Chicken', qty: 1, status: ItemStatus.pending, specialInstructions: 'Less spicy'),
          OrderItem(name: 'Garlic Naan', qty: 2, status: ItemStatus.pending, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K5-306',
        tableNo: 'T04',
        waiterName: 'L. Baskar',
        waiterImage: 'https://randomuser.me/api/portraits/men/19.jpg',
        orderTime: '12:40 PM',
        priority: 1,
        customerName: 'Mr. Oberoi',
        pax: 5,
        color: const Color(0xFFD35400),
        items: [
          OrderItem(name: 'Tandoori Prawns', qty: 2, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Fish Tikka', qty: 1, status: ItemStatus.cooking, specialInstructions: null),
          OrderItem(name: 'Roomali Roti', qty: 5, status: ItemStatus.pending, specialInstructions: null),
        ],
      ),
    ];
  }

  // ARUSUVAI ARASU KITCHEN (K11) - 4 Orders
  static List<PendingOrder> _arusuvaiKitchenOrders() {
    return [
      PendingOrder(
        kotNo: 'K11-401',
        tableNo: 'T22',
        waiterName: 'B. Velayutham',
        waiterImage: 'https://randomuser.me/api/portraits/men/55.jpg',
        orderTime: '10:20 AM',
        priority: 1,
        customerName: 'Mr. Kumar',
        pax: 3,
        color: const Color(0xFF27AE60),
        items: [
          OrderItem(name: 'Chettinad Chicken', qty: 1, status: ItemStatus.cooking, specialInstructions: 'Spicy'),
          OrderItem(name: 'Parotta', qty: 3, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Egg Curry', qty: 1, status: ItemStatus.pending, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K11-402',
        tableNo: 'T10',
        waiterName: 'K. Elumalai',
        waiterImage: 'https://randomuser.me/api/portraits/men/32.jpg',
        orderTime: '11:00 AM',
        priority: 2,
        customerName: 'Mr. Murugan',
        pax: 4,
        color: const Color(0xFFFF6B35),
        items: [
          OrderItem(name: 'Mutton Chukka', qty: 2, status: ItemStatus.pending, specialInstructions: 'Extra pepper'),
          OrderItem(name: 'Idiyappam', qty: 4, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Coconut Milk', qty: 2, status: ItemStatus.ready, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K11-403',
        tableNo: 'T16',
        waiterName: 'M. Suresh',
        waiterImage: 'https://randomuser.me/api/portraits/men/22.jpg',
        orderTime: '11:40 AM',
        priority: 1,
        customerName: 'Mrs. Lakshmi',
        pax: 2,
        color: const Color(0xFFE74C3C),
        items: [
          OrderItem(name: 'Fish Fry', qty: 1, status: ItemStatus.cooking, specialInstructions: 'Masala coated'),
          OrderItem(name: 'Rice', qty: 2, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Rasam', qty: 1, status: ItemStatus.pending, specialInstructions: 'Pepper heavy'),
        ],
      ),
      PendingOrder(
        kotNo: 'K11-404',
        tableNo: 'T28',
        waiterName: 'G. Sankar',
        waiterImage: 'https://randomuser.me/api/portraits/men/41.jpg',
        orderTime: '12:20 PM',
        priority: 3,
        customerName: 'Mr. Raja',
        pax: 1,
        color: const Color(0xFF8E44AD),
        items: [
          OrderItem(name: 'Kothu Parotta', qty: 1, status: ItemStatus.pending, specialInstructions: 'Spicy'),
          OrderItem(name: 'Egg', qty: 1, status: ItemStatus.pending, specialInstructions: 'Half boil'),
        ],
      ),
    ];
  }

  // CHINESE KITCHEN (K4) - 4 Orders
  static List<PendingOrder> _chineseKitchenOrders() {
    return [
      PendingOrder(
        kotNo: 'K4-501',
        tableNo: 'T18',
        waiterName: 'K. Suresh',
        waiterImage: 'https://randomuser.me/api/portraits/men/48.jpg',
        orderTime: '11:10 AM',
        priority: 2,
        customerName: 'Ms. Lee',
        pax: 2,
        color: const Color(0xFFD35400),
        items: [
          OrderItem(name: 'Fried Rice', qty: 2, status: ItemStatus.pending, specialInstructions: 'No MSG'),
          OrderItem(name: 'Chilli Chicken', qty: 1, status: ItemStatus.cooking, specialInstructions: 'Gravy'),
          OrderItem(name: 'Manchurian', qty: 1, status: ItemStatus.pending, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K4-502',
        tableNo: 'T05',
        waiterName: 'R. Parthiban',
        waiterImage: 'https://randomuser.me/api/portraits/men/52.jpg',
        orderTime: '11:45 AM',
        priority: 1,
        customerName: 'Mr. Chen',
        pax: 4,
        color: const Color(0xFFE74C3C),
        items: [
          OrderItem(name: 'Hakka Noodles', qty: 2, status: ItemStatus.pending, specialInstructions: 'Veg'),
          OrderItem(name: 'Dragon Chicken', qty: 1, status: ItemStatus.cooking, specialInstructions: null),
          OrderItem(name: 'Spring Rolls', qty: 3, status: ItemStatus.pending, specialInstructions: 'Crispy'),
          OrderItem(name: 'Sweet Corn Soup', qty: 2, status: ItemStatus.ready, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K4-503',
        tableNo: 'T14',
        waiterName: 'S. Srikanth',
        waiterImage: 'https://randomuser.me/api/portraits/men/36.jpg',
        orderTime: '12:10 PM',
        priority: 2,
        customerName: 'Mrs. Wong',
        pax: 3,
        color: const Color(0xFF4D9FFF),
        items: [
          OrderItem(name: 'Schezwan Rice', qty: 2, status: ItemStatus.pending, specialInstructions: 'Extra spicy'),
          OrderItem(name: 'Gobi Manchurian', qty: 1, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Baby Corn Fry', qty: 1, status: ItemStatus.cooking, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K4-504',
        tableNo: 'T20',
        waiterName: 'K. Kannan',
        waiterImage: 'https://randomuser.me/api/portraits/men/45.jpg',
        orderTime: '12:30 PM',
        priority: 3,
        customerName: 'Mr. Zhang',
        pax: 2,
        color: const Color(0xFF27AE60),
        items: [
          OrderItem(name: 'Triple Rice', qty: 1, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Chicken Lollipop', qty: 2, status: ItemStatus.pending, specialInstructions: 'Dry'),
        ],
      ),
    ];
  }

  // NEW CONTINENTAL KITCHEN (K22) - 4 Orders
  static List<PendingOrder> _newContinentalKitchenOrders() {
    return [
      PendingOrder(
        kotNo: 'K22-601',
        tableNo: 'T25',
        waiterName: 'M. Wilson',
        waiterImage: 'https://randomuser.me/api/portraits/men/62.jpg',
        orderTime: '10:35 AM',
        priority: 1,
        customerName: 'Mr. Davis',
        pax: 2,
        color: const Color(0xFF16A085),
        items: [
          OrderItem(name: 'Beef Steak', qty: 1, status: ItemStatus.cooking, specialInstructions: 'Well done'),
          OrderItem(name: 'French Fries', qty: 1, status: ItemStatus.ready, specialInstructions: null),
          OrderItem(name: 'Red Wine', qty: 2, status: ItemStatus.pending, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K22-602',
        tableNo: 'T02',
        waiterName: 'K. Elumalai',
        waiterImage: 'https://randomuser.me/api/portraits/men/32.jpg',
        orderTime: '11:15 AM',
        priority: 2,
        customerName: 'Mrs. Brown',
        pax: 3,
        color: const Color(0xFFE74C3C),
        items: [
          OrderItem(name: 'Grilled Fish', qty: 1, status: ItemStatus.pending, specialInstructions: 'Lemon butter'),
          OrderItem(name: 'Sauteed Veggies', qty: 1, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Mushroom Soup', qty: 2, status: ItemStatus.cooking, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K22-603',
        tableNo: 'T12',
        waiterName: 'R. Parthiban',
        waiterImage: 'https://randomuser.me/api/portraits/men/52.jpg',
        orderTime: '11:50 AM',
        priority: 1,
        customerName: 'Mr. Smith',
        pax: 4,
        color: const Color(0xFFFF6B35),
        items: [
          OrderItem(name: 'Roast Chicken', qty: 1, status: ItemStatus.pending, specialInstructions: 'Gravy separate'),
          OrderItem(name: 'Mashed Potato', qty: 2, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Steamed Broccoli', qty: 1, status: ItemStatus.ready, specialInstructions: null),
          OrderItem(name: 'Garlic Bread', qty: 2, status: ItemStatus.pending, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K22-604',
        tableNo: 'T30',
        waiterName: 'M. Suresh',
        waiterImage: 'https://randomuser.me/api/portraits/men/22.jpg',
        orderTime: '12:25 PM',
        priority: 3,
        customerName: 'Ms. Emma',
        pax: 1,
        color: const Color(0xFF8E44AD),
        items: [
          OrderItem(name: 'Veg Lasagna', qty: 1, status: ItemStatus.pending, specialInstructions: 'No mushrooms'),
          OrderItem(name: 'Orange Juice', qty: 1, status: ItemStatus.pending, specialInstructions: null),
        ],
      ),
    ];
  }

  // VEGETARIAN KITCHEN (K23) - 5 Orders
  static List<PendingOrder> _vegetarianKitchenOrders() {
    return [
      PendingOrder(
        kotNo: 'K23-701',
        tableNo: 'T14',
        waiterName: 'N. Ramesh',
        waiterImage: 'https://randomuser.me/api/portraits/men/33.jpg',
        orderTime: '10:55 AM',
        priority: 2,
        customerName: 'Mrs. Mehta',
        pax: 4,
        color: const Color(0xFF2ECC71),
        items: [
          OrderItem(name: 'Veg Biryani', qty: 2, status: ItemStatus.pending, specialInstructions: 'No onion'),
          OrderItem(name: 'Paneer Butter Masala', qty: 1, status: ItemStatus.cooking, specialInstructions: 'Creamy'),
          OrderItem(name: 'Veg Pakora', qty: 1, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Raita', qty: 2, status: ItemStatus.ready, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K23-702',
        tableNo: 'T06',
        waiterName: 'L. Baskar',
        waiterImage: 'https://randomuser.me/api/portraits/men/19.jpg',
        orderTime: '11:25 AM',
        priority: 3,
        customerName: 'Mr. Joshi',
        pax: 2,
        color: const Color(0xFF3498DB),
        items: [
          OrderItem(name: 'Malai Kofta', qty: 1, status: ItemStatus.pending, specialInstructions: 'Sweet'),
          OrderItem(name: 'Naan', qty: 2, status: ItemStatus.cooking, specialInstructions: 'Garlic'),
          OrderItem(name: 'Dal Fry', qty: 1, status: ItemStatus.pending, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K23-703',
        tableNo: 'T09',
        waiterName: 'G. Sankar',
        waiterImage: 'https://randomuser.me/api/portraits/men/41.jpg',
        orderTime: '11:50 AM',
        priority: 1,
        customerName: 'Mrs. Agarwal',
        pax: 6,
        color: const Color(0xFFE74C3C),
        items: [
          OrderItem(name: 'Palak Paneer', qty: 2, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Mix Veg', qty: 1, status: ItemStatus.cooking, specialInstructions: null),
          OrderItem(name: 'Tandoori Roti', qty: 6, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Jeera Rice', qty: 3, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Gulab Jamun', qty: 6, status: ItemStatus.ready, specialInstructions: 'Warm'),
        ],
      ),
      PendingOrder(
        kotNo: 'K23-704',
        tableNo: 'T17',
        waiterName: 'K. Suresh',
        waiterImage: 'https://randomuser.me/api/portraits/men/48.jpg',
        orderTime: '12:10 PM',
        priority: 2,
        customerName: 'Mr. Rathore',
        pax: 3,
        color: const Color(0xFFFF6B35),
        items: [
          OrderItem(name: 'Chana Masala', qty: 1, status: ItemStatus.pending, specialInstructions: 'Punjabi style'),
          OrderItem(name: 'Bhatura', qty: 3, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Onion Salad', qty: 1, status: ItemStatus.pending, specialInstructions: null),
        ],
      ),
      PendingOrder(
        kotNo: 'K23-705',
        tableNo: 'T24',
        waiterName: 'B. Velayutham',
        waiterImage: 'https://randomuser.me/api/portraits/men/55.jpg',
        orderTime: '12:35 PM',
        priority: 3,
        customerName: 'Mrs. Iyer',
        pax: 2,
        color: const Color(0xFF27AE60),
        items: [
          OrderItem(name: 'Masala Dosa', qty: 2, status: ItemStatus.pending, specialInstructions: 'Crispy'),
          OrderItem(name: 'Sambar', qty: 1, status: ItemStatus.pending, specialInstructions: null),
          OrderItem(name: 'Coconut Chutney', qty: 1, status: ItemStatus.ready, specialInstructions: null),
        ],
      ),
    ];
  }
}