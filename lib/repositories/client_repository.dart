import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../core/database/local_database.dart';
import '../models/client.dart';

class ClientRepository {
  ClientRepository({LocalDatabase? localDatabase})
      : _localDatabase = localDatabase ?? LocalDatabase.instance;

  final LocalDatabase _localDatabase;
  final _uuid = const Uuid();

  Future<List<Client>> search(String query) async {
    final db = await _localDatabase.database;
    final trimmed = query.trim();

    final List<Map<String, Object?>> rows;
    if (trimmed.isEmpty) {
      rows = await db.query(
        'clients',
        where: 'deleted_at IS NULL',
        orderBy: 'last_name COLLATE NOCASE, first_name COLLATE NOCASE',
      );
    } else {
      final like = '%$trimmed%';
      rows = await db.query(
        'clients',
        where: '''
          deleted_at IS NULL AND (
            first_name LIKE ? OR
            last_name LIKE ? OR
            phone LIKE ? OR
            whatsapp LIKE ?
          )
        ''',
        whereArgs: [like, like, like, like],
        orderBy: 'last_name COLLATE NOCASE, first_name COLLATE NOCASE',
      );
    }

    return rows.map(Client.fromLocalMap).toList();
  }

  Future<Client> create({
    required String firstName,
    required String lastName,
    String? phone,
    String? whatsapp,
  }) async {
    final db = await _localDatabase.database;
    final now = DateTime.now().toUtc();
    final client = Client(
      id: _uuid.v7(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phone: phone?.trim(),
      whatsapp: whatsapp?.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await db.insert(
      'clients',
      client.toLocalMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return client;
  }

  Future<int> count() async {
    final db = await _localDatabase.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM clients WHERE deleted_at IS NULL',
    );
    return (result.first['total'] as int?) ?? 0;
  }
}
