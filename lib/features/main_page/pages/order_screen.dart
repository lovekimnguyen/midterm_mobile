import 'package:flutter/material.dart';
import '../../../common/services/data_helper.dart';
import '../model/order.dart';
import 'home_screen.dart';

class OrderScreen extends StatefulWidget {
  final Order? order;

  const OrderScreen({super.key, this.order});

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> {
  late TextEditingController quantityController;
  bool addWhippedCream = false;
  bool addChocolate = false;

  static const double coffeePrice = 5.0;
  static const double whippedCreamPrice = 2.0;
  static const double chocolatePrice = 3.0;

  double totalPrice = 0.0;

  late String selectedStatus ;

  @override
  void initState() {
    super.initState();
    if(widget.order != null){
        selectedStatus = widget.order!.status;
      }else{
        selectedStatus = 'Đang chế biến';
    }
    if (widget.order != null) {
      quantityController = TextEditingController(text: widget.order!.quantity.toString());
      addWhippedCream = widget.order!.isWhippedCream;
      addChocolate = widget.order!.isChocolate;
      totalPrice = _calculateTotalPrice(widget.order!.quantity);
    } else {
      quantityController = TextEditingController(text: '1');
      totalPrice = _calculateTotalPrice(1);
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  double _calculateTotalPrice(int quantity) {
    double price = coffeePrice * quantity;
    if (addWhippedCream) price += whippedCreamPrice * quantity;
    if (addChocolate) price += chocolatePrice * quantity;
    return price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'Add Order' : 'Edit Order'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'lib/common/images/logo.png',
                width: 200,
                height: 200,
              ),
            ),
            SizedBox(height: 20,),
            Text('Choose Toppings:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.only(left: 50 , right: 50 , top: 10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: addWhippedCream,
                      onChanged: widget.order != null ? null : (value) {
                        setState(() {
                          addWhippedCream = value!;
                          totalPrice = _calculateTotalPrice(int.parse(quantityController.text));
                        });
                      },
                    ),
                    Text('Whipped Cream', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 20),
                    Checkbox(
                      value: addChocolate,
                      onChanged: widget.order != null ? null : (value) {
                        setState(() {
                          addChocolate = value!;
                          totalPrice = _calculateTotalPrice(int.parse(quantityController.text)); // Recalculate price
                        });
                      },
                    ),
                    Text('Chocolate', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            Text('Quantity: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.only(top : 10 , left: 130 , right: 155),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Row(
                  children: [
                      IconButton(
                            icon: Icon(Icons.remove),
                            color: Colors.black54,
                            onPressed: widget.order != null ? null : () {
                              setState(() {
                                int quantity = int.parse(quantityController.text);
                                if (quantity > 1) {
                                  quantityController.text = (quantity - 1).toString();
                                  totalPrice = _calculateTotalPrice(quantity - 1);
                                }
                              });
                            },
                      ),
                    Expanded(
                      child: Center(
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          readOnly: widget.order != null ? true : false,
                          onChanged: widget.order != null ? null : (value) {
                            setState(() {
                              if (int.tryParse(value) != null && int.parse(value) > 0) {
                                totalPrice = _calculateTotalPrice(int.parse(value));
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: widget.order != null ? null : () {
                        setState(() {
                          int quantity = int.parse(quantityController.text);
                          quantityController.text = (quantity + 1).toString();
                          totalPrice = _calculateTotalPrice(quantity + 1);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            if(widget.order != null)  DropdownButton<String>(
              value: selectedStatus,
              onChanged: (String? newValue) {
                setState(() {
                  selectedStatus = newValue!;
                });
              },
              items: <String>['Đang chế biến', 'Đã phục vụ', 'Đã thanh toán']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (int.tryParse(quantityController.text) == null || int.parse(quantityController.text) <= 0) {
                    return;
                  }

                  var newOrder = Order(
                    id: widget.order?.id ?? '',
                    quantity: int.parse(quantityController.text),
                    status: selectedStatus,
                    isWhippedCream: addWhippedCream,
                    isChocolate: addChocolate,
                    price: totalPrice,
                  );

                  if (widget.order == null) {
                    await DatabaseHelper().insertOrder(newOrder);
                  } else {
                    await DatabaseHelper().updateOrderStatus(newOrder.id, newOrder.status);
                  }

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()),
                        (route) => false,
                  );
                },
                child: Text(widget.order == null ? 'Add Order' : 'Save Changes'),
              ),
            ),
            SizedBox(height: 20),
            Text('ORDER SUMMARY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 100 , right: 100 , top : 10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Add whipped cream? ${addWhippedCream ? 'yes' : 'no'}', style: TextStyle(fontSize: 16)),
                    Text('Add chocolate? ${addChocolate ? 'yes' : 'no'}', style: TextStyle(fontSize: 16)),
                    Text('Quantity: ${quantityController.text}', style: TextStyle(fontSize: 16)),
                    Text('Price: \$${totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Center(child: Text('THANK YOU!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
