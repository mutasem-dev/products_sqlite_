class Product {
  int id;
  String productName;
  int quantity;
  double price;

  Product({this.id, this.productName, this.quantity, this.price});

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'],
      productName: data['pName'],
      quantity: data['quantity'],
      price: data['price'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'pName': this.productName,
      'quantity': this.quantity,
      'price': this.price
    };
  }
}