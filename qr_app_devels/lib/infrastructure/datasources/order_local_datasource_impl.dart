import 'package:qr_app_devels/domain/entities/order.dart';
import 'package:qr_app_devels/domain/entities/product.dart';
import 'package:qr_app_devels/infrastructure/datasources/my_database.dart';

class OrderLocalDatasourceImpl {
  final MyDatabase _database;

  OrderLocalDatasourceImpl(this._database);

  Future<Order> createOrder(Order order) async {
    final db = await _database.db;
    late int orderId;

    await db.transaction((txn) async {
      orderId = await txn.insert('orders', {
        'user_id': order.userId,
        'total': order.total,
        'status': OrderSyncStatus.pending.name,
        'retryable': 1,
      });

      for (final item in order.items) {
        await txn.insert('order_items', {
          'order_id': orderId,
          'product_id': item.product.id,
          'title': item.product.name,
          'unit_price': item.product.price,
          'quantity': item.quantity,
          'thumbnail': item.product.thumbnailUrl,
        });
      }
    });

    return order.copyWith(id: orderId);
  }

  Future<List<Order>> getOrders() async {
    final db = await _database.db;
    final rows = await db.query('orders', orderBy: 'id DESC');
    final orders = <Order>[];

    for (final row in rows) {
      final itemRows = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [row['id']],
        orderBy: 'id',
      );
      orders.add(_orderFromRows(row, itemRows));
    }

    return orders;
  }

  Future<Order?> getOrder(int id) async {
    final db = await _database.db;
    final rows = await db.query('orders', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;

    final itemRows = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [id],
      orderBy: 'id',
    );
    return _orderFromRows(rows.first, itemRows);
  }

  Future<bool> markSending(int id) async {
    final db = await _database.db;
    final updated = await db.update(
      'orders',
      {
        'status': OrderSyncStatus.sending.name,
        'error_message': null,
        'retryable': 0,
      },
      where:
          'id = ? AND (status = ? OR (status = ? AND retryable = 1))',
      whereArgs: [
        id,
        OrderSyncStatus.pending.name,
        OrderSyncStatus.error.name,
      ],
    );
    return updated == 1;
  }

  Future<void> markPending(int id, String message) async {
    final db = await _database.db;
    await db.update(
      'orders',
      {
        'status': OrderSyncStatus.pending.name,
        'error_message': message,
        'retryable': 1,
      },
      where: 'id = ? AND status = ?',
      whereArgs: [id, OrderSyncStatus.sending.name],
    );
  }

  Future<void> markError(
    int id, {
    required String message,
    required bool retryable,
  }) async {
    final db = await _database.db;
    await db.update(
      'orders',
      {
        'status': OrderSyncStatus.error.name,
        'error_message': message,
        'retryable': retryable ? 1 : 0,
      },
      where: 'id = ? AND status = ?',
      whereArgs: [id, OrderSyncStatus.sending.name],
    );
  }

  Future<void> markUnknown(int id, String message) async {
    final db = await _database.db;
    await db.update(
      'orders',
      {
        'status': OrderSyncStatus.unknown.name,
        'error_message': message,
        'retryable': 0,
      },
      where: 'id = ? AND status = ?',
      whereArgs: [id, OrderSyncStatus.sending.name],
    );
  }

  Future<void> markConfirmed(int id, Order response) async {
    final db = await _database.db;
    await db.update(
      'orders',
      {
        'status': OrderSyncStatus.confirmedSimulated.name,
        'remote_id': response.remoteId,
        'total': response.total,
        'synced': 1,
        'error_message': null,
        'retryable': 0,
      },
      where: 'id = ? AND status = ?',
      whereArgs: [id, OrderSyncStatus.sending.name],
    );
  }

  Order _orderFromRows(
    Map<String, Object?> row,
    List<Map<String, Object?>> itemRows,
  ) {
    return Order(
      id: row['id'] as int,
      remoteId: row['remote_id'] as int?,
      userId: row['user_id'] as int,
      total: (row['total'] as num).toDouble(),
      status: OrderSyncStatus.values.byName(row['status'] as String),
      errorMessage: row['error_message'] as String?,
      retryable: row['retryable'] == 1,
      items: itemRows.map((item) {
        final thumbnail =
            item['thumbnail'] as String? ?? 'assets/images/no-image.png';
        return OrderItem(
          product: Product(
            id: item['product_id'] as int,
            name: item['title'] as String,
            price: (item['unit_price'] as num).toDouble(),
            thumbnailUrl: thumbnail,
          ),
          quantity: item['quantity'] as int,
        );
      }).toList(),
    );
  }
}
