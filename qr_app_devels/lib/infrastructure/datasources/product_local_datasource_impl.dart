import 'package:qr_app_devels/domain/entities/product.dart';
import 'package:qr_app_devels/infrastructure/datasources/my_database.dart';
import 'package:qr_app_devels/infrastructure/mappers/product_mapper.dart';
import 'package:qr_app_devels/infrastructure/models/products/product_response.dart';
import 'package:sqflite/sql.dart';

class ProductLocalDatasourceImpl {
  final MyDatabase _appDb;

  ProductLocalDatasourceImpl( this._appDb );

  Future<void> saveLocalProducts(List<Product> products ) async {
    final db = await _appDb.db;
    final batch = db.batch();

    for( final p in products ){
      batch.insert(
        'products',
        ProductMapper.productToDatabase(p),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit( noResult: true );
  }

  Future<List<Product>> getProducts() async {
    final db = await _appDb.db;
    final rows = await db.query('products', orderBy: 'title');
    final products = rows.map(
      (productDummy) => ProductMapper.productDummyToEntity( ProductDummy.fromJson( productDummy ) )
    ).toList();

    return products;
  }
}