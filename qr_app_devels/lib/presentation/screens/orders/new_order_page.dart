import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:qr_app_devels/config/theme/app_theme.dart';

import 'package:qr_app_devels/domain/domain.dart';
import 'package:qr_app_devels/infrastructure/infrastructure.dart';
import 'package:qr_app_devels/presentation/providers/providers.dart';
import 'package:qr_app_devels/presentation/screens/screen.dart';

class NewOrderPage extends ConsumerStatefulWidget {
  const NewOrderPage({super.key});

  @override
  ConsumerState<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends ConsumerState<NewOrderPage> {
  int _tab = 0;
  final Map<int, OrderItem> _items = {};
  bool _isSubmitting = false;

  int _quantityOf(int productId) => _items[productId]?.quantity ?? 0;

  int get _totalUnits =>
    _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get _total =>
    _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  Future<void> _scanQr() async {
    final result = await ref.read(qrScannerServiceProvider).scan();
    if (!mounted) return;

    switch (result) {
      case QrScanSuccess(:final rawCode ):
        try {
          final productRes = await ref.read( productIdProvider( int.parse(rawCode) ).future );
          _addProduct(productRes);
        } catch (e) {
          if( mounted ) {
            ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }
        
      break;

      case QrScanFailure(error: QrScanError.canceled):
        break;

      case QrScanFailure(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _addProduct(Product product) {
    
    final next = _quantityOf(product.id) + 1;
    _items[product.id] = OrderItem(product: product, quantity: next);
    
    setState(() {});
  }

  void _removeProduct(Product product ) {
    final next = _quantityOf(product.id) - 1;
    if( next <= 0 ) {
      _items.remove( product.id );
    }else{
      _items[product.id] = OrderItem(product: product, quantity: next);
    }
    
    setState(() {});
  }

  Future<void> _submit() async {
    if (_items.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final order = Order(
        items: _items.values.toList(),
        userId: 1,
        total: _total,
      );
      final createdOrder = await ref
          .read(orderRepoProvider)
          .createOrder(order: order);

      if (!mounted) return;
      ref.invalidate(ordersProvider);
      final message = switch (createdOrder.status) {
        OrderSyncStatus.pending =>
          'Pedido #${createdOrder.id} guardado localmente, pendiente de envío',
        OrderSyncStatus.confirmedSimulated =>
          'Pedido #${createdOrder.id} confirmado por el servicio',
        OrderSyncStatus.error =>
          'Pedido #${createdOrder.id} guardado con error: ${createdOrder.errorMessage}',
        OrderSyncStatus.unknown =>
          'Pedido #${createdOrder.id}: resultado del envío desconocido',
        OrderSyncStatus.sending => 'Pedido #${createdOrder.id} en proceso de envío',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('No se pudo crear el pedido: $error')),
        );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Productos')),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.superficie,
          borderRadius: BorderRadius.circular(32),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _tabsRow(),
                    Gap(12),
                    Expanded(child: _content()),
                  ],
                ),
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _tabsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.grey[200],
            ),
            child: Row(
              children: [_tabButton('Productos', 1), _tabButton('En el Pedido', 0)],
            ),
          ),
        ),
        Gap(12),
        FilledButton(
          onPressed: _scanQr,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 20,
                ),
                const Gap(8),
                Text('Leer QR', style: context.text.sm.bold),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabButton(String label, int index) {
    final selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.grey[200],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: context.text.sm.medium.copyWith(
              color: selected ? AppColors.azulOscuro : Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _content() {
    if (_tab == 0) {
      final orderItems = _items.values.toList();

      if (orderItems.isEmpty) {
        return const Center(
          child: Text('Agrega productos para crear el pedido'),
        );
      }

      return ListView.separated(
        itemCount: orderItems.length,
        separatorBuilder: (context, index) => const Gap(10),
        itemBuilder: (_, i){
          final product = orderItems[i].product;
          return ProductoItem(
            producto: product,
            quantity: orderItems[i].quantity,
            onAdd: (){
              _addProduct(product);
            },
            onRemove: () => {
              _removeProduct(product)
            },
          );
        }
      );
    }

    if (_tab == 1) {
      final productsProv = ref.watch(productsProvider);
      return productsProv.when(
        data: (data) {
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: data.length,
            separatorBuilder: (context, index) => const Gap(10),
            itemBuilder: (_, i) {
              final product = data[i];
              return ProductoItem(
                producto: product,
                quantity: _quantityOf(product.id),
                onAdd: () => _addProduct(product),
                onRemove: () => {
                  _removeProduct(product)
                },
              );
            },
          );
        },
        error: (err, stack) => Text(err.toString()),
        loading: () => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator()],
        ),
      );
    }

    return Text('No hay tab seleccionado');
  }

  Widget _footer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.azulClaro)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_totalUnits unidades',
                  style: context.text.xs.medium.copyWith(
                    color: Colors.grey[400]
                  ),
                ),
                Gap(2),
                Text('Q${_total.toStringAsFixed(2)}', style: context.text.base.bold.secondary),
              ],
            ),
          ),
          SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: _items.isEmpty || _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.azulElectrico,
                disabledBackgroundColor: AppColors.superficie,
                disabledForegroundColor: const Color(0xFFA3ACBF),
                padding: const EdgeInsets.symmetric(horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Crear pedido',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}