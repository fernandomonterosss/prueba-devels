import 'package:riverpod/riverpod.dart';

import 'package:qr_app_devels/infrastructure/infrastructure.dart';
import 'package:qr_app_devels/presentation/providers/providers.dart';

final productRepoProvider = Provider((ref) {
  final database = MyDatabase();
  return ProductRepositoryImpl(
    productDatasource:  ProductDatasourceImpl(),
    localDatasource:  ProductLocalDatasourceImpl(database),
    networkInfo: ref.watch(networkInfoProvider),
  );
});