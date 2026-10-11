import 'package:qr_app_devels/domain/domain.dart';

abstract class ProductDatasource {
  Future<List<Product>> getProducts({ int limit = 30 });
  Future<Product> fetchProduct({ required int productId });
}