import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:qr_app_devels/config/theme/app_theme.dart';
import 'package:qr_app_devels/presentation/providers/providers.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider).value ?? true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: online ? AppColors.azulClaro :Colors.orange,
        borderRadius: BorderRadius.circular(24),
      ),
      child:  Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(online ? Icons.wifi : Icons.wifi_off, size: 18, color: AppColors.azulOscuro ),
          Gap(6),
          Text(
            online ? 'En línea' : 'Sin conexión',
            style: context.text.sm.secondary,
          ),
        ],
      ),
    );
  }
}