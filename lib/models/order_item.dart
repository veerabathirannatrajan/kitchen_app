enum ItemStatus { pending, cooking, ready }

class OrderItem {
  final String serialNo;
  final String itemCode;
  final String itemName;
  final int qty;
  ItemStatus status;
  final String? remarks;
  String? endTime;

  OrderItem({
    required this.serialNo,
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.status,
    this.remarks,
    this.endTime,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      serialNo: json['SerialNo']?.toString() ?? '',
      itemCode: json['ItemCode']?.toString() ?? '',
      itemName: json['ItemName']?.toString() ?? '',
      qty: int.tryParse(json['Qty']?.toString() ?? '0') ?? 0,
      status: ItemStatus.pending,
    );
  }

  // For mock data compatibility
  factory OrderItem.mock({
    required String name,
    required int qty,
    required ItemStatus status,
    String? specialInstructions,
    String? endTime,
  }) {
    return OrderItem(
      serialNo: '',
      itemCode: '',
      itemName: name,
      qty: qty,
      status: status,
      remarks: specialInstructions,
      endTime: endTime,
    );
  }
}