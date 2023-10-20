class Cart {
  String userEmail;
  String cartId;
  double cartTotalPrice;
  List<CartItem> items;

  Cart({
    required this.userEmail,
    required this.cartId,
    required this.cartTotalPrice,
    required this.items,
  });
}

class CartItem {
  String itemName;
  double itemQuantity;
  double pricePerItem;

  CartItem({
    required this.itemName,
    required this.itemQuantity,
    required this.pricePerItem,
  });
}


