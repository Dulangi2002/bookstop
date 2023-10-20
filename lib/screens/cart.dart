import 'package:bookstop/Cart.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
   final String userEmail;
  const CartScreen({
    required this.userEmail,
    Key? key,
  }) : super(key: key);
  

 
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Cart _cart = Cart(
    userEmail: ' ' ,
    cartId: ' ' ,
    cartTotalPrice: 0.0 ,
    items: [
      CartItem(
        itemName: ' ' ,
        itemQuantity: 0 ,
        pricePerItem: 0.0 ,
      ),
    ],
  );
 final userEmail = ' ' ;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: ListView.builder(
        itemCount: _cart.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = _cart.items[index];
          return ListTile(
            trailing: IconButton(
              icon: Icon(Icons.remove_shopping_cart),
              onPressed: () {
                setState(() {
                });
              },
            ),
          );
        },
      ),
    );
  }
}
