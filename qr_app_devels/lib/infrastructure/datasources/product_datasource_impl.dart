import 'package:dio/dio.dart';
import 'package:qr_app_devels/domain/domain.dart';
import 'package:qr_app_devels/infrastructure/mappers/product_mapper.dart';
import 'package:qr_app_devels/infrastructure/models/products/product_response.dart';

class ProductDatasourceImpl implements ProductDatasource {

  final dio = Dio(BaseOptions(
    baseUrl: 'https://dummyjson.com/',
    connectTimeout: const Duration(seconds: 5),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  @override
  Future<List<Product>> getProducts({int limit = 30}) async {

    final response = await dio.get('products?limit=$limit');
    final productDummyResponse = ProductResponse.fromJson(response.data);

    return productDummyResponse.products.map(
      (productDummy) => ProductMapper.productDummyToEntity(productDummy)
    ).toList();
    
  }

  @override
  Future<Product> fetchProduct({required int productId}) async {
    try {
      final response = await dio.get('products/$productId');
      final product = ProductMapper.productDummyToEntity( ProductDummy.fromJson( response.data ));

      return product;
      
    } on DioException catch ( e ){

      if( e.response!.statusCode == 404 ) throw Exception( 'Producto no encontrado' );
      throw Exception();

    } catch (e) {
      throw Exception();
    }

  }


}