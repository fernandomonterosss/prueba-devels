import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qr_app_devels/domain/domain.dart';

part 'order.freezed.dart';

enum OrderSyncStatus { pending, sending, confirmedSimulated, error, unknown }

@freezed
abstract class Order with _$Order {
  const factory Order({
    int? id,
    int? remoteId,
    required List<OrderItem> items,
    required int userId,
    required double total,
    @Default(OrderSyncStatus.pending) OrderSyncStatus status,
    String? errorMessage,
    @Default(true) bool retryable,
  }) = _Order;
}

@freezed
abstract class OrderItem with _$OrderItem {
  const OrderItem._(); // necesario porque hay un getter propio

  const factory OrderItem({
    required Product product,
    required int quantity,
  }) = _OrderItem;

  double get subtotal => product.price * quantity;
}