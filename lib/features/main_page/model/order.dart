class Order {
  String id;
  bool isWhippedCream;
  bool isChocolate;
  int quantity;
  String status;
  double price;

  Order({
    required this.id,
    required this.isWhippedCream,
    required this.isChocolate,
    required this.quantity,
    required this.price,
    this.status = "Đang chế biến",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quantity': quantity,
      'status': status,
      'isWhippedCream': isWhippedCream ? 1 : 0,
      'isChocolate': isChocolate ? 1 : 0,
      'price': price,  // Include price in the map
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'].toString(),
      isWhippedCream: map['isWhippedCream'] == 1,
      isChocolate: map['isChocolate'] == 1,
      quantity: map['quantity'],
      status: map['status'],
      price: map['price'].toDouble(),
    );
  }
}
