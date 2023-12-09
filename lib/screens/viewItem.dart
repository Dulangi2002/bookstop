import 'package:bookstop/fetchProducts.dart';
import 'package:bookstop/screens/favorites.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'cart.dart';

class ViewItem extends StatefulWidget {
  final Map<String, dynamic> product;
  final TextEditingController _reviewController;

  ViewItem({Key? key, required this.product})
      : _reviewController = TextEditingController(),
        super(key: key);

  @override
  State<ViewItem> createState() => _ViewItemState();
}

class _ViewItemState extends State<ViewItem> {
  late String firstHalf;
  late String secondHalf;
  List<String> isLikedReviews = [];
  List<String> reviewsByUser = [];
  bool flag = true;
  static const snackbar = SnackBar(content: Text('Item added to cart '));
  var quantityToAddToCart = 0;
  var pricePerItem = 0.0;
  String userEmail = FirebaseAuth.instance.currentUser!.email.toString();

  @override
  void initState() {
    super.initState();
    firstHalf = widget.product['description'].substring(0, 200);
    secondHalf = widget.product['description']
        .substring(200, widget.product['description'].length);
  }

  Future<void> addReview() async {
    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('Reviews');

      String review = widget._reviewController.text;
      DateTime reviewCreatedAt = DateTime.now();
      int numberOfLikesPerReview = 0;
      String reviewId = collectionReference.doc().id;
      String userEmail = FirebaseAuth.instance.currentUser!.email.toString();
      await collectionReference.doc(reviewId).set({
        'review': review,
        'reviewCreatedAt': reviewCreatedAt,
        'numberOfLikesPerReview': numberOfLikesPerReview,
        'reviewId': reviewId,
        'title': widget.product['title'],
        'userEmail': userEmail,
      });
      reviewsByUser
          .add(reviewId); //add review id to the list of reviews by user
      Navigator.pop(context);
      widget._reviewController.clear();
      setState(() {
        fetchReviews();
      });
    } catch (e) {
      print('Error adding review: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchReviews() async {
    List<Map<String, dynamic>> reviews = [];

    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('Reviews');
      QuerySnapshot querySnapshot = await collectionReference
          .where('title', isEqualTo: widget.product['title'])
          .get();

      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> reviewData = {
          'reviewId': doc['reviewId'],
          'review': doc['review'],
          'reviewCreatedAt': doc['reviewCreatedAt'],
          'numberOfLikesPerReview': doc['numberOfLikesPerReview'],
          'userEmail': doc['userEmail'],
        };
        if (doc['userEmail'] == userEmail) {
          reviewsByUser.add(doc['reviewId']);
        }
        reviews.add(reviewData);
      });

      return reviews;
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  Future<void> likeReview(String reviewId) async {
    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('Reviews');
      await collectionReference.doc(reviewId).update({
        'numberOfLikesPerReview': FieldValue.increment(1),
      });
      isLikedReviews.add(reviewId);

      setState(() {
        fetchReviews();
      });
    } catch (e) {
      print('Error liking review: $e');
    }
  }

  Future<void> undoLike(String reviewId) async {
    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('Reviews');
      await collectionReference.doc(reviewId).update({
        'numberOfLikesPerReview': FieldValue.increment(-1),
      });
      isLikedReviews.remove(reviewId);
      setState(() {
        fetchReviews();
      });
    } catch (e) {
      print('Error undoing like: $e');
    }
  }

  //delete review
  Future<void> DeleteReview(
    String reviewId,
  ) async {
    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('Reviews');
      await collectionReference.doc(reviewId).delete();
      reviewsByUser.remove(reviewId);
      setState(() {
        fetchReviews();
      });
    } catch (e) {
      print('Error deleting review: $e');
    }
  }

  Future<void> EditReview(
    String reviewId,
    String editedReview,
  ) async {
    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('Reviews');
      await collectionReference.doc(reviewId).update({
        'review': editedReview,
      });
      Navigator.pop(context);
      setState(() {
        fetchReviews();
      });
    } catch (e) {
      print('Error editing review: $e');
    }
  }

  Future filterReviewsBasedOnNewest() async {
    List<Map<String, dynamic>> reviews = [];

    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('Reviews');
      QuerySnapshot querySnapshot = await collectionReference
          .where('title', isEqualTo: widget.product['title'])
          .orderBy('reviewCreatedAt', descending: true)
          .get();

      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> reviewData = {
          'reviewId': doc['reviewId'],
          'review': doc['review'],
          'reviewCreatedAt': doc['reviewCreatedAt'],
          'numberOfLikesPerReview': doc['numberOfLikesPerReview'],
        };
        reviews.add(reviewData);
      });

      return reviews;
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  //add to favourites

  Future<void> addToFavorites(String title, int price) async {
    final user = FirebaseAuth.instance.currentUser;

    DocumentReference _userDoc =
        FirebaseFirestore.instance.collection('Users').doc(user!.email);
    CollectionReference _collectionRef = _userDoc.collection('Favorites');

    try {
      final DocumentSnapshot _doc = await _userDoc.get();
      if (_doc.exists) {
        //check if the product already exists in favouries
        final DocumentSnapshot _doc = await _collectionRef.doc(title).get();
        if (_doc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Item already in favorites'),
          ));
        } else {
          await _collectionRef.doc(title).set({
            'title': title,
            'price': widget.product['price'],
            'productImage': widget.product['image'],
            'author': widget.product['author'],
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Item added to favorites'),
          ));
        }
      }
    } catch (error) {
      print("Failed to add item: $error");
    }
  }

  //add to cart function
  Future<void> addToCart(
      String title, double quantityToAddToCart, double pricePerItem) async {
    final user = FirebaseAuth.instance.currentUser;

    DocumentReference _userDoc =
        FirebaseFirestore.instance.collection('Users').doc(user!.email);
    CollectionReference _collectionRef = _userDoc.collection('Cart');

    try {
      final DocumentSnapshot _doc = await _userDoc.get();
      if (_doc.exists) {
        //check if the product already exists in the cart
        final DocumentSnapshot _doc = await _collectionRef.doc(title).get();
        if (_doc.exists) {
          //if the product exists, update the quantity
          await _collectionRef.doc(title).update({
            
            'quantity': FieldValue.increment(quantityToAddToCart),
            'price': FieldValue.increment(pricePerItem),
          });
        } else {
          await _collectionRef.doc(title).set({
            'title': title,
            'quantity': quantityToAddToCart,
            'price': pricePerItem,
            'productImage': widget.product['image'],
          });
        }
      } else {
        await _collectionRef.doc(title).set({
          'title': title,
          'quantity': quantityToAddToCart,
          'price': pricePerItem,
          'productImage': widget.product['image'],
        });
      }
      setState(() {
        quantityToAddToCart = 1;
        pricePerItem = widget.product['price'] * quantityToAddToCart;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Item added to cart'),
      ));
    } catch (error) {
      print("Failed to add item: $error");
    }
  }

  Future<void> viewCart() async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyCart(
            userEmail: userEmail,
          ),
        ),
      );
    } catch (error) {
      print("Failed to add item: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.product['title'],
          ),
        ),
        body: SingleChildScrollView(
            child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/${widget.product['image']}',
                  fit: BoxFit.cover,
                  width:
                      140, // Set the width of the image as per your requirement

                  // Set the height of the image as per your requirement
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Text(
                  widget.product['author'].toString(),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                child: Text(
                  widget.product['title'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Text(
                  widget.product['price'].toString(),
                ),
              ),

              Container(
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(255, 30, 19, 0),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //quantity buttons
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  
                                  onPressed: () {
                                    setState(() {
                                      if (quantityToAddToCart > 1) {
                                        quantityToAddToCart--;
                                        pricePerItem =
                                            (widget.product['price'] *
                                                    quantityToAddToCart)
                                                .toDouble();
                                      }
                                    });
                                  },
                                  icon: Icon(
                                    Icons.remove,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                                Text(quantityToAddToCart.toString(),
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      quantityToAddToCart++;
                                      pricePerItem = (widget.product['price'] *
                                              quantityToAddToCart)
                                          .toDouble();
                                    });
                                  },
                                  icon: Icon(Icons.add ,   color: Color.fromARGB(255, 255, 255, 255)),
                                ),
                                Text(pricePerItem.toString()
                                ,style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(BootstrapIcons.cart 
                          ,  color: Color.fromARGB(255, 255, 255, 255,)),
                          
                          onPressed: () {
                            addToCart(widget.product['title'],
                                quantityToAddToCart.toDouble(), pricePerItem);
                          },
                        ),

                        IconButton(
                          icon: Icon(BootstrapIcons.heart, 
                          color: Color.fromARGB(255, 255, 255, 255)),
                          onPressed: () {
                            addToFavorites(widget.product['title'],
                                widget.product['price']);
                          },
                        ),
                      ])),
              GestureDetector(
                onTap: () {
                  setState(() {
                    flag = !flag;
                  });
                },
                child: Text(
                  flag ? (firstHalf + "...") : (firstHalf + secondHalf),
                ),
              ),

              // quantity buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                
                  SizedBox(
                    child: Container(
                      margin: EdgeInsets.only(top: 20, bottom: 20),
                      child: ElevatedButton(
                        style: (ElevatedButton.styleFrom(
                          foregroundColor: Color.fromARGB(255, 255, 255, 255),
                          backgroundColor: Color.fromARGB(255, 30, 19, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        )),
                        onPressed: () async {
                          await showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              titleTextStyle: TextStyle(
                                color: Color.fromARGB(255, 30, 19, 0),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              surfaceTintColor: Color.fromARGB(255, 0, 0, 0),
                              title: Container(
                                  alignment: Alignment.center,
                                  child: Text('Write a review')),
                              content: TextField(
                                controller: widget._reviewController,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 30, 19, 0),
                                        width: 2.0),
                                  ),
                                  border: OutlineInputBorder(),
                                  labelText: 'Review',
                                  labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (widget
                                        ._reviewController.text.isNotEmpty) {
                                      addReview();
                                    } else {
                                      print('Review is empty');
                                    }
                                  },
                                  child: Text('Submit'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text('Write a review'),
                      ),
                    ),
                  ),
              
                  Container(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchReviews(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            String reviewId =
                                snapshot.data![index]['reviewId'].toString();
                            bool isReviewLiked = false;
                            bool isReviewByUser = false;

                            // Check if the review is liked
                            if (isLikedReviews.contains(reviewId)) {
                              isReviewLiked = true;
                            }

                            if (reviewsByUser.contains(reviewId)) {
                              isReviewByUser = true;
                            }

                            List<Widget> buttons = [
                              IconButton(
                                  onPressed: () {
                                    if (!isReviewLiked) {
                                      // Like the review if it's not already liked
                                      likeReview(reviewId);
                                      setState(() {
                                        isLikedReviews.add(reviewId);
                                      });
                                    } else {
                                      // Undo like if it's already liked
                                      undoLike(reviewId);
                                      setState(() {
                                        isLikedReviews.remove(reviewId);
                                      });
                                    }
                                  },
                                  icon: Icon(isReviewLiked
                                      ? BootstrapIcons.hand_thumbs_up_fill
                                      : BootstrapIcons.hand_thumbs_up)
                                  // Text(isReviewLiked ? 'Undo Like' : 'Like'),
                                  ),
                            ];

                            if (isReviewByUser) {
                              buttons.add(
                                Row(
                                  children: [
                                    Text(
                                      snapshot.data![index]
                                              ['numberOfLikesPerReview']
                                          .toString(),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        // Delete the review
                                        DeleteReview(
                                          reviewId,
                                        );
                                      },
                                      icon: Icon(BootstrapIcons.trash),
                                    ),
                                  ],
                                ),
                              );
                            }
                            ;
                            if (isReviewByUser) {
                              final oldReview = snapshot.data![index]['review'];
                              TextEditingController _reviewController =
                                  TextEditingController(text: oldReview);
                              buttons.add(
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Edit Review'),
                                        content: TextField(
                                          controller: _reviewController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Review',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              final editedReview =
                                                  _reviewController.text;
                                              if (editedReview.isNotEmpty) {
                                                // Call EditReview with the edited review
                                                EditReview(
                                                    reviewId, editedReview);
                                              } else {
                                                _reviewController.text =
                                                    oldReview;
                                              }
                                            },
                                            child: Text('Submit'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: Icon(BootstrapIcons.pencil),
                                ),
                              );
                            }

                            return Container(
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromARGB(255, 30, 19, 0),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                snapshot.data![index]['review'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              )),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: buttons,
                                        ),
                                      ],
                                    )));
                          },
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ))
                ],
              ),
            ],
          ),
        )
        ),  

         bottomNavigationBar: BottomNavigationBar(
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
              label: 'Profile',
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
          },
        )
        )
        ;
  }
}
