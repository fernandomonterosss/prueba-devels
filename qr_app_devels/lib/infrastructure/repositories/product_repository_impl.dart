import 'package:qr_app_devels/domain/domain.dart';
import 'package:qr_app_devels/infrastructure/datasources/product_local_datasource_impl.dart';
import 'package:qr_app_devels/infrastructure/network/network_info.dart';

class ProductRepositoryImpl implements ProductRepository {

  final ProductDatasource productDatasource;
  final ProductLocalDatasourceImpl localDatasource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.productDatasource, 
    required this.localDatasource,
    required this.networkInfo
  });

  @override
  Future<List<Product>> getProducts({int limit = 30}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await productDatasource.getProducts();
        await localDatasource.saveLocalProducts(remoteProducts);
        return remoteProducts;
      } catch (_) {
        final cached = await localDatasource.getProducts();
        if (cached.isEmpty) throw Exception('No hay productos en caché');
        return cached;
      }
    }

    final cached = await localDatasource.getProducts();
    if (cached.isEmpty) throw Exception('No hay productos en caché');
    return cached;
  }

  @override
  Future<Product> fetchProduct({required int productId}) {
    return productDatasource.fetchProduct(productId: productId);
  }

}