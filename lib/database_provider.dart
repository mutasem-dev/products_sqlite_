import 'package:products_sql/product.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider db = DatabaseProvider._();
  static final int version = 1;
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    path += 'products.db';
    return await openDatabase(
      path,
      version: version,
      onCreate: (db, version) async {
        await db.execute('''
          create table products (
            id integer primary key autoincrement,
            pName text not null,
            quantity integer not null,
            price real not null
          )
          ''');
      },
    );
  }

  Future<List<Product>> get products async {
    final db = await database;
    List<Map> result = await db.query('products', orderBy: 'id asc');
    List<Product> prds = [];
    for (var value in result) {
      prds.add(Product.fromMap(value));
    }
    return prds;
  }

  Future insert(Product product) async {
    final db = await database;
//    return await db.rawInsert('''insert into products (pName,quantity,price)
//                  values (?,?,?)'''
//        ,[product.productName,product.quantity,product.price]);
    return await db.insert('products', product.toMap());
  }

  Future<Product> getProduct(int id) async {
    final db = await database;
    List<Map> product =
    await db.query('products', where: 'id=?', whereArgs: [id]);
    return Product.fromMap(product[0]);
  }

  Future removeAll() async {
    final db = await database;
    return await db.delete('products');
  }

  Future<int> removeProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id=?', whereArgs: [id]);
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update('products', product.toMap(),
        where: 'id=?', whereArgs: [product.id]);
  }
}