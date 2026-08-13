import 'package:flutter/material.dart';

import '../repositories/client_repository.dart';

class NewClientScreen extends StatefulWidget {
  const NewClientScreen({super.key});

  @override
  State<NewClientScreen> createState() => _NewClientScreenState();
}

class _NewClientScreenState extends State<NewClientScreen> {
  final formKey = GlobalKey<FormState>();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phone = TextEditingController();
  final whatsapp = TextEditingController();
  final repository = ClientRepository();

  bool saving = false;

  Future<void> _save() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => saving = true);
    await repository.create(
      firstName: firstName.text,
      lastName: lastName.text,
      phone: phone.text,
      whatsapp: whatsapp.text,
    );

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    phone.dispose();
    whatsapp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau client')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: firstName,
              decoration: const InputDecoration(labelText: 'Prénom'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: lastName,
              decoration: const InputDecoration(labelText: 'Nom'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Téléphone'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: whatsapp,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'WhatsApp'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(saving ? 'Enregistrement...' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
