import 'package:flutter/material.dart';

class SmartImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SmartImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  bool get _isNetwork =>
      path.startsWith('http://') || path.startsWith('https://');

  static const _fallback = 'assets/images/no-image.png';

  @override
  Widget build(BuildContext context) {
    if (_isNetwork) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, error, stackTrace) => Image.asset(
          _fallback,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }

    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, error, stackTrace) => Image.asset(
        _fallback,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }
}