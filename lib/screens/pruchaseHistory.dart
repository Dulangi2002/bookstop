import 'package:bookstop/screens/cart.dart';
import 'package:bookstop/screens/favorites.dart';
import 'package:bookstop/screens/profile.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PurchaseHistory extends StatefulWidget {
  final String userEmail;

  const PurchaseHistory({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<PurchaseHistory> createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends State<PurchaseHistory> {
  late String userEmail;
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> orderItems = [];

  Future<void> fetchPurchaseHistory() async {
    try {
      List<Map<String, dynamic>> items = [];
      var documentReference = FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('Orders')
          .where(
            'orderStatus',
            isEqualTo: 'completed',
          )
          .get();

      documentReference.then((snapshot) {
        snapshot.docs.forEach((element) {
          items.add(Map<String, dynamic>.from(
              element.data() as Map<String, dynamic>));
          orderItems.addAll(
              List<Map<String, dynamic>>.from(element.data()['orderItems']));
        });

        setState(() {
          this.items = items;
          this.orderItems = orderItems;
        });
      });
    } catch (e) {
      print('Error fetching purchase history: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    userEmail = widget.userEmail;
    fetchPurchaseHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase History'),
      ),
      body: Column(
        children: [
          for (int index = 0; index < items.length; index++)
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
              ) ,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ('${items[index]['orderID'].toString()}'),
                  ),
                  Text(
                    'Order Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ('\$${items[index]['orderTotal'].toString()}'),
                  ),
                  Text(
                    'Order Items',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: orderItems.length,
                    itemBuilder: (context, innerIndex) {
                      return Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/${orderItems[innerIndex]['image']}',
                                fit: BoxFit.cover,
                                width: 100,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Title' +
                                  orderItems[innerIndex]['title'].toString()),
                              Text(
                                  'Product price : \$${orderItems[innerIndex]['price'].toString()}'),
                              Text(
                                  'Quantity : ${orderItems[innerIndex]['quantity'].toString()}'),
                              Text(
                                  'Total per item : \$${((double.parse(orderItems[innerIndex]['quantity']) * double.parse(orderItems[innerIndex]['price'])).toString())}')
                            ],
                          )
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ), bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.house),
              label: 'Home',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.heart),
              label: 'Favorites',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.cart),
              label: 'Cart',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.person),
              label: 'Profile',
              backgroundColor: Colors.black,
            ),
          ],
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => favorites(userEmail: userEmail),
                ),
              );
            }
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyCart(
                    userEmail: userEmail,
                  ),
                ),
              );
            }
            if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(
                    userEmail: userEmail,
                  ),
                ),
              );
            }
          },
        )
    );
  }
}
