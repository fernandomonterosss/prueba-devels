import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_app_devels/domain/entities/order.dart';
import 'package:qr_app_devels/presentation/providers/providers.dart';

final ordersProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(orderRepoProvider).getOrders();
});