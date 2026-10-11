import 'package:dio/dio.dart';
import 'package:qr_app_devels/domain/domain.dart';
import 'package:qr_app_devels/infrastructure/datasources/order_local_datasource_impl.dart';
import 'package:qr_app_devels/infrastructure/network/network_info.dart';

class OrderRepositoryImpl extends OrderRepository {
  final OrderDatasource orderDatasource;
  final OrderLocalDatasourceImpl localDatasource;
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({
    required this.orderDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<Order> createOrder({required Order order}) async {
    final total = order.items.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );
    final savedOrder = await localDatasource.createOrder(
      order.copyWith(total: total),
    );
    if (!await networkInfo.isConnected) return savedOrder;
    return sendPendingOrder(orderId: savedOrder.id!);
  }

  @override
  Future<Order> sendPendingOrder({required int orderId}) async {
    if (!await networkInfo.isConnected) {
      final order = await localDatasource.getOrder(orderId);
      if (order == null) throw StateError('No existe el pedido $orderId');
      return order;
    }

    final claimed = await localDatasource.markSending(orderId);
    if (!claimed) {
      final order = await localDatasource.getOrder(orderId);
      if (order == null) throw StateError('No existe el pedido $orderId');
      return order;
    }

    final order = await localDatasource.getOrder(orderId);
    if (order == null) throw StateError('No existe el pedido $orderId');

    late Order response;
    try {
      response = await orderDatasource.createOrder(order: order);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final message = statusCode == null
          ? 'Error de conexión: ${error.message ?? error.type.name}'
          : 'El servicio respondió con HTTP $statusCode.';

      if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        if (statusCode == 408) {
          await localDatasource.markUnknown(
            orderId,
            '$message El resultado del envío no se puede confirmar.',
          );
        } else {
          await localDatasource.markError(
            orderId,
            message: message,
            retryable: statusCode == 429,
          );
        }
      } else if (statusCode == null &&
          (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout)) {
        await localDatasource.markPending(
          orderId,
          'No se pudo establecer conexión; el pedido sigue pendiente.',
        );
      } else {
        await localDatasource.markUnknown(
          orderId,
          '$message El pedido pudo haber llegado al servicio; '
          'no se reenviará automáticamente.',
        );
      }

      return _getOrderOrThrow(orderId);
    } on FormatException catch (error) {
      await localDatasource.markUnknown(
        orderId,
        'El servicio respondió con contenido inválido: ${error.message}. '
        'El pedido pudo haberse creado; no se reenviará automáticamente.',
      );
      return _getOrderOrThrow(orderId);
    } catch (error) {
      await localDatasource.markUnknown(
        orderId,
        'No se pudo confirmar el resultado del envío: $error. '
        'No se reenviará automáticamente para evitar pedidos duplicados.',
      );
      return _getOrderOrThrow(orderId);
    }

    await localDatasource.markConfirmed(orderId, response);
    return _getOrderOrThrow(orderId);
  }

  Future<Order> _getOrderOrThrow(int id) async {
    final order = await localDatasource.getOrder(id);
    if (order == null) throw StateError('No existe el pedido $id');
    return order;
  }

  @override
  Future<List<Order>> getOrders() {
    return localDatasource.getOrders();
  }
}
