import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_app_devels/infrastructure/infrastructure.dart';
import 'package:qr_app_devels/presentation/providers/providers.dart';

final orderRepoProvider = Provider((ref) {
  final database = MyDatabase();
  return OrderRepositoryImpl(
    orderDatasource: OrderDatasourceImpl(),
    localDatasource: OrderLocalDatasourceImpl(database),
    networkInfo: ref.watch(networkInfoProvider),
  );
});