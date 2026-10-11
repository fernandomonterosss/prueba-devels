import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:qr_app_devels/config/theme/app_theme.dart';

import 'package:qr_app_devels/presentation/providers/providers.dart';
import 'package:qr_app_devels/domain/entities/product.dart';
import 'package:qr_app_devels/presentation/widgets/widgets.dart';

class ProductListPage extends ConsumerStatefulWidget {
  static const String name = 'products';

  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  void _agregar(BuildContext context, Product producto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${producto.name} agregado'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final responseProvider = ref.watch(productsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              child: responseProvider.when(
                data: (productos) => ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return Column(
                      children: [
                        ProductoItem(
                          producto: producto,
                          onAdd: () => _agregar(context, producto),
                        ),
                        Gap(14),
                      ],
                    );
                  },
                ),
                error: (error, stackTrace) =>
                    Center(child: Text('Error: $error')),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductoItem extends StatelessWidget {
  final Product producto;
  final int? quantity;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  const ProductoItem({super.key, required this.producto, this.quantity, this.onAdd, this.onRemove });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.bordeSuave),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.azulClaro,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SmartImage(
                  path: producto.thumbnailUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.name,
                      maxLines: 3,
                      style: context.text.base.secondary.bold,
                    ),
                    Text(
                      '\$${producto.price.toStringAsFixed(2)}',
                      style: context.text.xs.medium.copyWith(
                        color: AppColors.grisAzulado,
                      ),
                    ),
                  ],
                ),
              ),
              if (onAdd != null && onRemove != null )
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Eliminar',
                      onPressed: onRemove,
                      icon: const Icon(Icons.remove),
                      color: AppColors.azulElectrico,
                    ),
                    Text('$quantity'),
                    IconButton(
                      tooltip: 'Agregar',
                      onPressed: onAdd,
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.azulElectrico,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
