import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../database/local_database.dart';

class SyncService {
  SyncService({LocalDatabase? localDatabase})
      : _localDatabase = localDatabase ?? LocalDatabase.instance;

  final LocalDatabase _localDatabase;

  Future<void> pushPendingClients() async {
    if (!Env.supabaseEnabled) return;

    final client = Supabase.instance.client;
    if (client.auth.currentUser == null) return;

    final db = await _localDatabase.database;
    final rows = await db.query(
      'clients',
      where: "sync_status = 'pending' AND deleted_at IS NULL",
    );

    for (final row in rows) {
      try {
        await client.from('clients').upsert({
          'id': row['id'],
          'workshop_id': row['workshop_id'],
          'first_name': row['first_name'],
          'last_name': row['last_name'],
          'phone': row['phone'],
          'whatsapp': row['whatsapp'],
          'gender': row['gender'],
          'address': row['address'],
          'notes': row['notes'],
          'created_at': row['created_at'],
          'updated_at': row['updated_at'],
        });

        await db.update(
          'clients',
          {'sync_status': 'synced'},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      } catch (_) {
        await db.update(
          'clients',
          {'sync_status': 'error'},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
    }
  }

  Future<void> resetErrorsToPending() async {
    final db = await _localDatabase.database;
    await db.update(
      'clients',
      {'sync_status': 'pending'},
      where: "sync_status = 'error'",
    );
  }
}
