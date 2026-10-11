import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:qr_app_devels/config/theme/app_theme.dart';
import 'package:qr_app_devels/domain/entities/order.dart';

class PedidoCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const PedidoCard({super.key, required this.order, required this.onTap});

  String get _statusLabel => switch (order.status) {
    OrderSyncStatus.pending => 'Pendiente',
    OrderSyncStatus.sending => 'Enviando',
    OrderSyncStatus.confirmedSimulated => 'Confirmado simulado',
    OrderSyncStatus.error => 'Error',
    OrderSyncStatus.unknown => 'Resultado desconocido',
  };

  Color get _statusColor => switch (order.status) {
    OrderSyncStatus.pending => const Color(0xFF3358E0),
    OrderSyncStatus.sending => const Color(0xFF1F5F8B),
    OrderSyncStatus.confirmedSimulated => const Color(0xFF24834A),
    OrderSyncStatus.error => const Color(0xFFB54708),
    OrderSyncStatus.unknown => const Color(0xFFB42318),
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.bordeSuave),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.azulClaro,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.view_in_ar_outlined,
                  size: 28,
                  color: AppColors.azulElectrico,
                ),
              ),
              Gap(18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${order.id}',
                          style: context.text.base,
                        ),
                        _EstadoChip(label: _statusLabel, color: _statusColor),
                      ],
                    ),
                    Gap(2),
                    Text(
                      'Usuario ${order.userId}',
                      style: context.text.base.medium,
                    ),
                    Gap(4),
                    Text(
                      '${order.items.length} productos · \$${order.total.toStringAsFixed(2)}',
                      style: context.text.sm,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _EstadoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}