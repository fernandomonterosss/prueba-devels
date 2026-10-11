import 'package:qr_app_devels/domain/domain.dart';

abstract class OrderDatasource {
  Future<Order> createOrder({required Order order});
}