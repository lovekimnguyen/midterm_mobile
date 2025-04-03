import 'package:flutter/material.dart';

import '../../../common/services/data_helper.dart';
import '../model/order.dart';
import 'order_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late Future<List<Order>> orders;
  String searchQuery = "";
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    orders = DatabaseHelper().getOrders();
  }

  void _searchOrders(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coffee Orders'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search orders by ID...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _searchOrders,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Order>>(
        future: _searchOrdersById(searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found'));
          }

          var orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text('Order ID: ${order.id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add Whipped Cream? ${order.isWhippedCream ? 'Yes' : 'No'}'),
                      Text('Add Chocolate? ${order.isChocolate ? 'Yes' : 'No'}'),
                      Text('Quantity: ${order.quantity}'),
                      Text('Price: \$${order.price.toStringAsFixed(2)}'),
                      Text('Status: ${order.status}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isDeleting ? Icons.hourglass_empty : Icons.delete,
                      color: isDeleting ? Colors.grey : Colors.black,
                    ),
                    onPressed: () async {
                      setState(() {
                        isDeleting = true;
                      });
                      await DatabaseHelper().deleteOrder(order.id);
                      setState(() async {
                        orders = await DatabaseHelper().getOrders();
                        isDeleting = false;
                      });
                    },
                  ),

                  onTap: () {
                    // Navigate to order edit screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderScreen(order: order)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<List<Order>> _searchOrdersById(String query) async {
    if (query.isEmpty) {
      return await DatabaseHelper().getOrders();
    } else {
      return await DatabaseHelper().searchOrdersById(query);
    }
  }
}
