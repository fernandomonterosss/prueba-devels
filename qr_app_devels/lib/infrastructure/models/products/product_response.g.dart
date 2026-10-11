// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductResponse _$ProductResponseFromJson(Map<String, dynamic> json) =>
    _ProductResponse(
      products: (json['products'] as List<dynamic>)
          .map((e) => ProductDummy.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      skip: (json['skip'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
    );

Map<String, dynamic> _$ProductResponseToJson(_ProductResponse instance) =>
    <String, dynamic>{
      'products': instance.products,
      'total': instance.total,
      'skip': instance.skip,
      'limit': instance.limit,
    };

_ProductDummy _$ProductDummyFromJson(Map<String, dynamic> json) =>
    _ProductDummy(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      thumbnail: json['thumbnail'] as String?,
    );

Map<String, dynamic> _$ProductDummyToJson(_ProductDummy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'price': instance.price,
      'thumbnail': instance.thumbnail,
    };
