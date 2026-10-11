import 'package:qr_app_devels/domain/domain.dart';
import 'package:qr_app_devels/infrastructure/models/products/product_response.dart';

class ProductMapper {

  static Product productDummyToEntity( ProductDummy productDummy ) {
    return Product(
      id: productDummy.id,
      name: productDummy.title,
      price: productDummy.price,
      thumbnailUrl: (productDummy.thumbnail != null && productDummy.thumbnail != '') 
        ? productDummy.thumbnail!
        : 'assets/images/no-image.jpg',
    );
  }

  static Map<String, Object?> productToDatabase(Product product) {
    return {
      'id': product.id,
      'title': product.name,
      'price': product.price,
      'thumbnail': product.thumbnailUrl,
    };
  }
}