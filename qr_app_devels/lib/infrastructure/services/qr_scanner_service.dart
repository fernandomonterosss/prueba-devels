import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum QrScanError {
  permissionDenied,
  canceled,
  emptyCode,
  unsupported,
  badFormat,
  unknown;

  String get message => switch (this) {
        permissionDenied => 'Se requieren permisos de cámara para escanear.',
        canceled => 'Cancelaste el escaneo.',
        emptyCode => 'El código QR está vacío.',
        unsupported => 'El escáner no está disponible en este dispositivo.',
        badFormat => 'Formato inválido.',
        unknown => 'Ocurrió un error inesperado en el escáner.',
      };
}

sealed class QrScanResult {
  const QrScanResult();
}

class QrScanSuccess extends QrScanResult {
  final String rawCode;
  const QrScanSuccess({required this.rawCode });
}

class QrScanFailure extends QrScanResult {
  final QrScanError error;
  const QrScanFailure(this.error);

  String get message => error.message;
}

class QrScannerService {
  const QrScannerService();

  static const _channel = MethodChannel('com.devels.qr/scanner_bridge');

  Future<QrScanResult> scan() async {
    try {
      final raw = await _channel.invokeMethod<String>('triggerNativeScan');
      if (raw == null || raw.trim().isEmpty) {
        return const QrScanFailure(QrScanError.emptyCode);
      }
       return QrScanSuccess(rawCode: raw);

    } on PlatformException catch (e) {
      return QrScanFailure(_mapError(e.code));
    } on MissingPluginException {
      return const QrScanFailure(QrScanError.unsupported);
    } catch (_) {
      return const QrScanFailure(QrScanError.unknown);
    }
  }

  QrScanError _mapError(String code) => switch (code) {
        'PERMISSION_DENIED' => QrScanError.permissionDenied,
        'SCANNER_CANCELED' => QrScanError.canceled,
        'BAD_FORMAT' => QrScanError.badFormat,
        _ => QrScanError.unknown,
      };
}

final qrScannerServiceProvider = Provider<QrScannerService>((ref) => const QrScannerService());