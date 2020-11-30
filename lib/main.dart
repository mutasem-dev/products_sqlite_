import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:products_sql/product_info.dart';
import 'product.dart';
import 'package:toast/toast.dart';
import 'database_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  List<Product> products = [];
  int updateId;
  var control = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'delete all',
        onPressed: () {
          DatabaseProvider.db.removeAll().then((value) {
            Toast.show('$value product(s) deleted', context);
          });
          setState(() {});
        },
        child: Icon(Icons.delete_sweep),
      ),
      appBar: AppBar(
        title: Text('Products'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20.0,
          ),
          Text(
            'Product information',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
                letterSpacing: 2.0),
          ),

          Divider(height: 10.0,color: Colors.black,),
          TextField(
            controller: control[0],
            decoration: InputDecoration(
              labelText: 'Product Name',
            ),
          ),
          TextField(
            controller: control[1],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantity',
            ),
          ),
          TextField(
            controller: control[2],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Price',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton.icon(
                onPressed: () {
                  if (control[0].text.isEmpty ||
                      control[1].text.isEmpty ||
                      control[2].text.isEmpty) {
                    Toast.show('Please fill all fields', context,
                        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                    return;
                  }
                  DatabaseProvider.db
                      .insert(Product(
                      productName: control[0].text,
                      quantity: int.parse(control[1].text),
                      price: double.parse(control[2].text)))
                      .then((value) {
                    print(value);
                  });
                  control.forEach((element) {
                    element.clear();
                  });
                  setState(() {});
                },
                icon: Icon(Icons.add),
                label: Text('Add Product'),
              ),
              RaisedButton.icon(
                onPressed: () {
                  if (control[0].text.isEmpty ||
                      control[1].text.isEmpty ||
                      control[2].text.isEmpty) {
                    Toast.show('Please fill all fields', context,
                        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                    return;
                  }
                  DatabaseProvider.db
                      .updateProduct(Product(
                      id: updateId,
                      productName: control[0].text,
                      quantity: int.parse(control[1].text),
                      price: double.parse(control[2].text)))
                      .then((value) {
                    if (value != 0)
                      Toast.show('Updated', context);
                    else
                      Toast.show('not updated', context);
                  });
                  control.forEach((element) {
                    element.clear();
                  });
                  updateId = -1;
                  setState(() {});
                },
                icon: Icon(Icons.update),
                label: Text('Update Product'),
              ),
            ],
          ),
          Text(
            'Your Products:',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
                letterSpacing: 2.0),
          ),
          FutureBuilder(
            future: DatabaseProvider.db.products,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Product> products = snapshot.data;
                if (products.isNotEmpty) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: EdgeInsets.all(8.0),
                          color: Colors.blue[200],
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductInfo(products[index].id),
                                  ));
                            },
                            onLongPress: () {
                              updateId = products[index].id;
                              control[0].text = products[index].productName;
                              control[1].text =
                                  products[index].quantity.toString();
                              control[2].text =
                                  products[index].price.toString();
                              setState(() {});
                            },
                            contentPadding: EdgeInsets.symmetric(horizontal: 1),
                            leading: Text(
                              products.elementAt(index).productName,
                              style: TextStyle(
                                letterSpacing: 2.0,
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            title: Text('Price: ${products[index].price}'),
                            subtitle:
                            Text('Quantity: ${products[index].quantity}'),
                            trailing: FlatButton.icon(
                              onPressed: () {
                                DatabaseProvider.db
                                    .removeProduct(products[index].id)
                                    .then((value) {
                                  if (value != 0)
                                    Toast.show('deleted successfully', context);
                                  else
                                    Toast.show('nothing deleted', context);
                                });
                                setState(() {});
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              label: Text(''),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else
                  return Text('no products');
              } else if (snapshot.hasError) return Text('${snapshot.error}');
              return CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }
}
