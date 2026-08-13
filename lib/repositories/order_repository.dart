import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../core/database/local_database.dart';
import '../models/order.dart';

class OrderRepository {
  OrderRepository({LocalDatabase? localDatabase})
      : _localDatabase = localDatabase ?? LocalDatabase.instance;

  final LocalDatabase _localDatabase;
  final _uuid = const Uuid();

  Future<List<CoutureOrder>> listAll() async {
    final db = await _localDatabase.database;
    final rows = await db.query(
      'orders',
      where: 'deleted_at IS NULL',
      orderBy: 'created_at DESC',
    );
    return rows.map(CoutureOrder.fromLocalMap).toList();
  }

  Future<CoutureOrder> create({
    required String clientId,
    required String garmentType,
    required double totalAmount,
    DateTime? deliveryDate,
    String? description,
  }) async {
    final db = await _localDatabase.database;
    final now = DateTime.now().toUtc();
    final short = _uuid.v7().replaceAll('-', '').substring(0, 6).toUpperCase();

    final order = CoutureOrder(
      id: _uuid.v7(),
      clientId: clientId,
      reference: 'CMD-$short',
      garmentType: garmentType.trim(),
      description: description?.trim(),
      totalAmount: totalAmount,
      deliveryDate: deliveryDate,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert(
      'orders',
      order.toLocalMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return order;
  }

  Future<int> countByStatus(String status) async {
    final db = await _localDatabase.database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM orders
      WHERE deleted_at IS NULL AND status = ?
      ''',
      [status],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> countOpen() async {
    final db = await _localDatabase.database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM orders
      WHERE deleted_at IS NULL
        AND status NOT IN ('delivered', 'cancelled')
      ''',
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> countOverdue() async {
    final db = await _localDatabase.database;
    final now = DateTime.now().toUtc().toIso8601String();
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM orders
      WHERE deleted_at IS NULL
        AND delivery_date IS NOT NULL
        AND delivery_date < ?
        AND status NOT IN ('delivered', 'cancelled')
      ''',
      [now],
    );
    return (result.first['total'] as int?) ?? 0;
  }
}
