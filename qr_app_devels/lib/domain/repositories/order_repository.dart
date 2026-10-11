import 'package:qr_app_devels/domain/entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<Order> createOrder({required Order order});
  Future<Order> sendPendingOrder({required int orderId});
}