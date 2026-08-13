import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'core/local_database.dart';
import 'models.dart';

const _uuid = Uuid();

class ClientRepository {
  final dbProvider = LocalDatabase.instance;

  Future<List<Client>> search([String query = '']) async {
    final db = await dbProvider.database;
    final q = query.trim();
    final rows = await db.query(
      'clients',
      where: q.isEmpty
          ? 'deleted_at IS NULL'
          : "deleted_at IS NULL AND (first_name LIKE ? OR last_name LIKE ? OR phone LIKE ?)",
      whereArgs: q.isEmpty ? null : ['%$q%', '%$q%', '%$q%'],
      orderBy: 'last_name COLLATE NOCASE, first_name COLLATE NOCASE',
    );
    return rows.map(Client.fromMap).toList();
  }

  Future<Client?> getById(String id) async {
    final db = await dbProvider.database;
    final rows = await db.query('clients', where: 'id = ? AND deleted_at IS NULL', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : Client.fromMap(rows.first);
  }

  Future<Client> save({
    String? id,
    required String firstName,
    required String lastName,
    String? phone,
    String? whatsapp,
    String? email,
    String? gender,
    String? address,
    String? notes,
  }) async {
    final db = await dbProvider.database;
    final now = DateTime.now().toIso8601String();
    final clientId = id ?? _uuid.v4();
    final data = <String, Object?>{
      'id': clientId,
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'phone': phone?.trim(),
      'whatsapp': whatsapp?.trim(),
      'email': email?.trim(),
      'gender': gender,
      'address': address?.trim(),
      'notes': notes?.trim(),
      'updated_at': now,
      'sync_status': 'pending',
    };
    if (id == null) {
      data['created_at'] = now;
      await db.insert('clients', data);
    } else {
      await db.update('clients', data, where: 'id = ?', whereArgs: [id]);
    }
    return (await getById(clientId))!;
  }
}

class MeasurementRepository {
  final dbProvider = LocalDatabase.instance;

  Future<Measurement?> latestForClient(String clientId) async {
    final db = await dbProvider.database;
    final rows = await db.query(
      'measurements',
      where: 'client_id = ? AND deleted_at IS NULL',
      whereArgs: [clientId],
      orderBy: 'taken_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final raw = jsonDecode((row['values_json'] as String?) ?? '{}') as Map<String, dynamic>;
    return Measurement(
      id: row['id'] as String,
      clientId: row['client_id'] as String,
      category: (row['category'] as String?) ?? 'female',
      takenAt: DateTime.tryParse((row['taken_at'] as String?) ?? '') ?? DateTime.now(),
      values: Map<String, double?>.fromEntries(
        raw.entries.where((e) => e.key != 'notes').map(
          (e) => MapEntry(e.key, e.value == null ? null : (e.value as num).toDouble()),
        ),
      ),
      notes: raw['notes'] as String?,
    );
  }

  Future<void> save({
    required String clientId,
    required String category,
    required Map<String, double?> values,
    String? notes,
  }) async {
    final db = await dbProvider.database;
    final now = DateTime.now().toIso8601String();
    final json = <String, Object?>{...values, 'notes': notes};
    await db.insert('measurements', {
      'id': _uuid.v4(),
      'client_id': clientId,
      'category': category,
      'values_json': jsonEncode(json),
      'taken_at': now,
      'created_at': now,
      'updated_at': now,
      'sync_status': 'pending',
    });
  }
}

class PaymentRepository {
  final dbProvider = LocalDatabase.instance;

  Future<List<Payment>> forOrder(String orderId) async {
    final db = await dbProvider.database;
    final rows = await db.query(
      'payments',
      where: 'order_id = ? AND deleted_at IS NULL',
      whereArgs: [orderId],
      orderBy: 'paid_at DESC',
    );
    return rows.map(Payment.fromMap).toList();
  }

  Future<double> totalForOrder(String orderId) async {
    final db = await dbProvider.database;
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM payments WHERE order_id = ? AND deleted_at IS NULL',
      [orderId],
    );
    return (rows.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<void> add({required String orderId, required double amount, required String method, String? note}) async {
    if (amount <= 0) return;
    final db = await dbProvider.database;
    final now = DateTime.now().toIso8601String();
    await db.insert('payments', {
      'id': _uuid.v4(),
      'order_id': orderId,
      'amount': amount,
      'payment_method': method,
      'paid_at': now,
      'note': note,
      'created_at': now,
      'updated_at': now,
      'sync_status': 'pending',
    });
  }

  Future<List<Map<String, Object?>>> forClient(String clientId) async {
    final db = await dbProvider.database;
    return db.rawQuery('''
      SELECT p.*, o.reference
      FROM payments p
      JOIN orders o ON o.id = p.order_id
      WHERE o.client_id = ? AND p.deleted_at IS NULL AND o.deleted_at IS NULL
      ORDER BY p.paid_at DESC
    ''', [clientId]);
  }
}

class OrderRepository {
  final dbProvider = LocalDatabase.instance;
  final payments = PaymentRepository();

  Future<List<CoutureOrder>> listAll() async {
    final db = await dbProvider.database;
    final rows = await db.query('orders', where: 'deleted_at IS NULL', orderBy: 'created_at DESC');
    return rows.map(CoutureOrder.fromMap).toList();
  }

  Future<List<CoutureOrder>> forClient(String clientId) async {
    final db = await dbProvider.database;
    final rows = await db.query(
      'orders',
      where: 'client_id = ? AND deleted_at IS NULL',
      whereArgs: [clientId],
      orderBy: 'created_at DESC',
    );
    return rows.map(CoutureOrder.fromMap).toList();
  }

  Future<CoutureOrder?> getById(String id) async {
    final db = await dbProvider.database;
    final rows = await db.query('orders', where: 'id = ? AND deleted_at IS NULL', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : CoutureOrder.fromMap(rows.first);
  }

  Future<CoutureOrder> create({
    required String clientId,
    required String garmentType,
    String? description,
    String? fabric,
    String? color,
    required double totalAmount,
    double advance = 0,
    DateTime? fittingDate,
    DateTime? deliveryDate,
    String? notes,
  }) async {
    final db = await dbProvider.database;
    final now = DateTime.now();
    final id = _uuid.v4();
    final countRows = await db.rawQuery('SELECT COUNT(*) AS c FROM orders');
    final count = ((countRows.first['c'] as num?)?.toInt() ?? 0) + 1;
    final reference = 'CMD-${now.year}-${count.toString().padLeft(4, '0')}';
    await db.insert('orders', {
      'id': id,
      'client_id': clientId,
      'reference': reference,
      'garment_type': garmentType.trim(),
      'description': description?.trim(),
      'fabric': fabric?.trim(),
      'color': color?.trim(),
      'total_amount': totalAmount,
      'order_date': now.toIso8601String(),
      'fitting_date': fittingDate?.toIso8601String(),
      'delivery_date': deliveryDate?.toIso8601String(),
      'status': 'registered',
      'notes': notes?.trim(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'sync_status': 'pending',
    });
    if (advance > 0) {
      await payments.add(orderId: id, amount: advance, method: 'cash', note: 'Avance à la commande');
    }
    return (await getById(id))!;
  }

  Future<void> updateStatus(String id, String status) async {
    final db = await dbProvider.database;
    await db.update(
      'orders',
      {'status': status, 'updated_at': DateTime.now().toIso8601String(), 'sync_status': 'pending'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CoutureOrder>> deliveries() async {
    final db = await dbProvider.database;
    final rows = await db.query(
      'orders',
      where: "deleted_at IS NULL AND delivery_date IS NOT NULL AND status != 'delivered' AND status != 'cancelled'",
      orderBy: 'delivery_date ASC',
    );
    return rows.map(CoutureOrder.fromMap).toList();
  }

  Future<DashboardStats> stats() async {
    final db = await dbProvider.database;
    final all = await listAll();
    final now = DateTime.now();
    bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
    final inProgress = all.where((o) => !['ready', 'delivered', 'cancelled'].contains(o.status)).length;
    final ready = all.where((o) => o.status == 'ready').length;
    final delivered = all.where((o) => o.status == 'delivered').length;
    final late = all.where((o) {
      final d = o.deliveryDate;
      if (d == null || ['delivered', 'cancelled'].contains(o.status)) return false;
      final day = DateTime(d.year, d.month, d.day);
      final today = DateTime(now.year, now.month, now.day);
      return day.isBefore(today) && !sameDay(day, today);
    }).length;
    final paymentRows = await db.rawQuery('SELECT COALESCE(SUM(amount), 0) AS total FROM payments WHERE deleted_at IS NULL');
    final received = (paymentRows.first['total'] as num?)?.toDouble() ?? 0;
    final orderRows = await db.rawQuery("SELECT COALESCE(SUM(total_amount), 0) AS total FROM orders WHERE deleted_at IS NULL AND status != 'cancelled'");
    final ordered = (orderRows.first['total'] as num?)?.toDouble() ?? 0;
    return DashboardStats(
      inProgress: inProgress,
      ready: ready,
      delivered: delivered,
      late: late,
      received: received,
      receivable: (ordered - received).clamp(0, double.infinity).toDouble(),
    );
  }
}
