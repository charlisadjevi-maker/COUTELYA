import 'package:flutter/material.dart';

import '../core/config/env.dart';
import '../core/sync/sync_service.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plus')),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.straighten),
            title: Text('Mesures'),
            subtitle: Text('Lot suivant'),
          ),
          const ListTile(
            leading: Icon(Icons.payments_outlined),
            title: Text('Paiements'),
            subtitle: Text('Lot suivant'),
          ),
          const ListTile(
            leading: Icon(Icons.workspace_premium_outlined),
            title: Text('Coutelya Pro'),
            subtitle: Text('Catalogue, Cloud, statistiques, reçus...'),
          ),
          ListTile(
            leading: Icon(
              Env.supabaseEnabled ? Icons.cloud_done : Icons.cloud_off,
            ),
            title: Text(
              Env.supabaseEnabled
                  ? 'Cloud configuré'
                  : 'Mode local uniquement',
            ),
            subtitle: Text(
              Env.supabaseEnabled
                  ? 'Supabase est initialisé.'
                  : 'Ajoutez les dart-defines Supabase pour activer le Cloud.',
            ),
          ),
          if (Env.supabaseEnabled)
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Synchroniser maintenant'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                await SyncService().resetErrorsToPending();
                await SyncService().pushPendingClients();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Synchronisation terminée.')),
                );
              },
            ),
          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: 'COUTELYA',
            applicationVersion: '0.1.0',
            applicationLegalese: 'Votre atelier, simplement.',
          ),
        ],
      ),
    );
  }
}
