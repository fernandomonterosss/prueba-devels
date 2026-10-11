import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:qr_app_devels/infrastructure/infrastructure.dart';

final networkInfoProvider = Provider<NetworkInfo>(
  (_) => NetworkInfoImpl(InternetConnection()),
);

final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final net = ref.watch(networkInfoProvider);
  yield await net.isConnected;
  yield* net.onStatusChange;
});