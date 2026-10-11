import 'package:dio/dio.dart';
import 'package:qr_app_devels/domain/domain.dart';

class OrderDatasourceImpl extends OrderDatasource {
  OrderDatasourceImpl({Dio? dio})
    : _dio =
          dio ??
          Dio(
    BaseOptions(
      baseUrl: 'https://dummyjson.com/',
      connectTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
      },
    )
  );

  final Dio _dio;

  @override
  Future<Order> createOrder({required Order order}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'carts/add',
      data: {
        'userId': order.userId,
        'products': order.items
            .map(
              (item) => {
                'id': item.product.id,
                'quantity': item.quantity,
              },
            )
            .toList(),
      },
    );
    final data = response.data;
    if (data == null ||
        data['id'] is! int ||
        data['total'] is! num ||
        data['userId'] != order.userId ||
        data['products'] is! List) {
      throw const FormatException('Respuesta inválida al crear el pedido');
    }
    final returnedProducts = data['products'] as List;
    if (returnedProducts.length != order.items.length) {
      throw const FormatException('La respuesta contiene productos inválidos');
    }
    final expectedQuantities = {
      for (final item in order.items) item.product.id: item.quantity,
    };
    for (final product in returnedProducts) {
      if (product is! Map ||
          product['id'] is! int ||
          product['quantity'] is! int ||
          expectedQuantities.remove(product['id']) != product['quantity']) {
        throw const FormatException('La respuesta contiene productos inválidos');
      }
    }
    if (expectedQuantities.isNotEmpty) {
      throw const FormatException('La respuesta no coincide con el pedido');
    }

    return Order(
      remoteId: data['id'] as int,
      items: order.items,
      total: (data['total'] as num).toDouble(),
      userId: order.userId,
    );
  }

}