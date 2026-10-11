import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:qr_app_devels/domain/entities/order.dart';
import 'package:qr_app_devels/presentation/providers/providers.dart';

class OrderPendingListPage extends ConsumerStatefulWidget {
  const OrderPendingListPage({super.key});

  @override
  ConsumerState<OrderPendingListPage> createState() =>
      _OrderPendingListPageState();
}

class _OrderPendingListPageState extends ConsumerState<OrderPendingListPage> {
  final Set<int> _sendingOrderIds = {};

  Future<void> _send(Order order) async {
    final id = order.id;
    if (id == null || !_sendingOrderIds.add(id)) return;
    setState(() {});

    try {
      final result = await ref
          .read(orderRepoProvider)
          .sendPendingOrder(orderId: id);
      ref.invalidate(ordersProvider);
      if (!mounted) return;
      final message = switch (result.status) {
        OrderSyncStatus.pending => 'El pedido sigue pendiente de envío',
        OrderSyncStatus.sending => 'El pedido ya se está enviando',
        OrderSyncStatus.confirmedSimulated =>
          'Pedido #${result.id} confirmado por el servicio',
        OrderSyncStatus.error =>
          'No se pudo enviar el pedido: ${result.errorMessage}',
        OrderSyncStatus.unknown =>
          'Resultado desconocido. No se reintentó para evitar duplicados.',
      };
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('No se pudo enviar el pedido: $error')),
        );
    } finally {
      _sendingOrderIds.remove(id);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos pendientes')),
      body: orders.when(
        data: (allOrders) {
          final pendingOrders = allOrders
              .where(
                (order) =>
                    order.status != OrderSyncStatus.confirmedSimulated,
              )
              .toList();
          if (pendingOrders.isEmpty) {
            return const Center(child: Text('No hay pedidos pendientes'));
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(ordersProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: pendingOrders.length,
              separatorBuilder: (context, index) => const Gap(12),
              itemBuilder: (context, index) {
                final order = pendingOrders[index];
                final id = order.id!;
                final isSending = _sendingOrderIds.contains(id) ||
                    order.status == OrderSyncStatus.sending;
                final canSend = order.status == OrderSyncStatus.pending ||
                    (order.status == OrderSyncStatus.error && order.retryable);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pedido #$id · ${_statusLabel(order.status)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Gap(6),
                        Text(
                          '${order.items.length} productos · '
                          '\$${order.total.toStringAsFixed(2)}',
                        ),
                        if (order.errorMessage != null) ...[
                          const Gap(8),
                          Text(order.errorMessage!),
                        ],
                        if (order.status == OrderSyncStatus.unknown) ...[
                          const Gap(8),
                          const Text(
                            'Verifica el pedido en el servicio antes de '
                            'crear o enviar otro igual.',
                          ),
                        ],
                        if (canSend) ...[
                          const Gap(12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: isSending ? null : () => _send(order),
                              icon: isSending
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.cloud_upload_outlined),
                              label: Text(
                                order.status == OrderSyncStatus.error
                                    ? 'Reintentar envío'
                                    : 'Enviar manualmente',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No se pudieron cargar los pedidos: $error'),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  String _statusLabel(OrderSyncStatus status) => switch (status) {
    OrderSyncStatus.pending => 'Pendiente',
    OrderSyncStatus.sending => 'Enviando',
    OrderSyncStatus.confirmedSimulated => 'Confirmado simulado',
    OrderSyncStatus.error => 'Error',
    OrderSyncStatus.unknown => 'Resultado desconocido',
  };
}
