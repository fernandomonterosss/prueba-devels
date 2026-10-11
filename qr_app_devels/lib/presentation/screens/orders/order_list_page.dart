import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_app_devels/config/theme/app_theme.dart';
import 'package:qr_app_devels/presentation/providers/providers.dart';
import 'package:qr_app_devels/presentation/widgets/pedido_card.dart';

class OrderListPage extends ConsumerWidget {
  static const String name = 'orders';

  const OrderListPage({super.key});

  void _nuevoPedido(BuildContext context) {
    context.push('/order/new');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pedidos recientes', style: context.text.base.bold),
                  FilledButton(
                    onPressed: () => _nuevoPedido(context),
                    child: const Text('Nuevo pedido'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: orders.when(
                data: (data) {
                  if (data.isEmpty) {
                    return const Center(child: Text('Aún no hay pedidos'));
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(ordersProvider.future),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: data.length,
                      separatorBuilder: (context, index) => const Gap(14),
                      itemBuilder: (context, index) => PedidoCard(
                        order: data[index],
                        onTap: () {},
                      ),
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
            ),
          ],
        ),
      ),
    );
  }
}
