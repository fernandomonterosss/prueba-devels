import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_response.freezed.dart';
part 'product_response.g.dart';

@freezed
sealed class ProductResponse with _$ProductResponse {

  const factory ProductResponse({
    required List<ProductDummy> products,
    required int total,
    required int skip,
    required int limit
  }) = _ProductResponse;

  factory ProductResponse.fromJson(Map<String, dynamic> json) => _$ProductResponseFromJson(json);
}

@freezed
sealed class ProductDummy with _$ProductDummy {

  const factory ProductDummy({
    required int id,
    required String title,
    required double price,
    required String? thumbnail
  }) = _ProductDummy;
  
  factory ProductDummy.fromJson(Map<String, dynamic> json) => _$ProductDummyFromJson(json);
}
