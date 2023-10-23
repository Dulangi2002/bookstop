import 'package:bookstop/fetchProducts.dart';
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
    firstHalf = widget.product['description'].substring(0, 100);
    secondHalf = widget.product['description']
        .substring(100, widget.product['description'].length);
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
        };
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
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
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
              SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/${widget.product['image']}',
                  fit: BoxFit.cover,
                  width:
                      50, // Set the width of the image as per your requirement
                  height:
                      50, // Set the height of the image as per your requirement
                ),
              ),
              Text(
                widget.product['price'].toString(),
              ),
              SizedBox(height: 20),
              //quantity buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (quantityToAddToCart > 1) {
                              quantityToAddToCart--;
                              pricePerItem = (widget.product['price'] *
                                      quantityToAddToCart)
                                  .toDouble();
                            }
                          });
                        },
                        icon: Icon(Icons.remove),
                      ),
                      Text(quantityToAddToCart.toString()),
                      Text(pricePerItem.toString()),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            quantityToAddToCart++;
                            pricePerItem =
                                (widget.product['price'] * quantityToAddToCart)
                                    .toDouble();
                          });
                        },
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  ElevatedButton(
                      onPressed: () {
                        viewCart();
                      },
                      child: Text('View Cart')),

                  SizedBox(height: 10),

                  //add to cart button
                  ElevatedButton(
                    onPressed: () {
                      addToCart(widget.product['title'],
                          quantityToAddToCart.toDouble(), pricePerItem);
                    },
                    child: Text('Add to cart'),
                  ),

                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () async {
                        await showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Write a review'),
                            content: TextField(
                              controller: widget._reviewController,
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
                  // SizedBox(height: 50),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     ElevatedButton(
                  //       onPressed: () {
                  //         setState(() {
                  //           filterReviewsBasedOnNewest();
                  //         });
                  //       },
                  //       child: Text('Sort by newest'),
                  //     ),
                  //   ],
                  // ),
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
                              ElevatedButton(
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
                                child:
                                    Text(isReviewLiked ? 'Undo Like' : 'Like'),
                              ),
                            ];

                            if (isReviewByUser) {
                              buttons.add(
                                ElevatedButton(
                                  onPressed: () {
                                    // Delete the review
                                    DeleteReview(
                                      reviewId,
                                    );
                                  },
                                  child: Text('Delete'),
                                ),
                              );
                            }
                            ;
                            if (isReviewByUser) {
                              final oldReview = snapshot.data![index]['review'];
                              TextEditingController _reviewController =
                                  TextEditingController(text: oldReview);
                              buttons.add(
                                ElevatedButton(
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
                                  child: Text('Edit'),
                                ),
                              );
                            }

                            return Column(
                              children: [
                                Text(
                                  snapshot.data![index]['review'],
                                ),
                                SizedBox(height: 20),
                                Text(
                                  snapshot.data![index]['reviewCreatedAt']
                                      .toString(),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  snapshot.data![index]
                                          ['numberOfLikesPerReview']
                                      .toString(),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: buttons,
                                ),
                              ],
                            );
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
        ));
  }
}
