import 'package:flutter/material.dart';

import '../models/client.dart';
import '../repositories/client_repository.dart';
import 'new_client_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final repository = ClientRepository();
  final searchController = TextEditingController();
  late Future<List<Client>> clients = repository.search('');

  void _search(String value) {
    setState(() => clients = repository.search(value));
  }

  Future<void> _newClient() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const NewClientScreen()),
    );
    if (created == true && mounted) {
      _search(searchController.text);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newClient,
        icon: const Icon(Icons.person_add),
        label: const Text('Nouveau'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: _search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Rechercher nom ou téléphone',
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Client>>(
                future: clients,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final rows = snapshot.data!;
                  if (rows.isEmpty) {
                    return const Center(
                      child: Text('Aucun client enregistré.'),
                    );
                  }
                  return ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final client = rows[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              client.fullName.isEmpty
                                  ? '?'
                                  : client.fullName[0].toUpperCase(),
                            ),
                          ),
                          title: Text(client.fullName),
                          subtitle: Text(client.phone ?? 'Sans téléphone'),
                          trailing: client.syncStatus == 'synced'
                              ? const Icon(Icons.cloud_done_outlined)
                              : const Icon(Icons.cloud_upload_outlined),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
