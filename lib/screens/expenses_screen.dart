import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models.dart';
import '../repositories.dart';
import '../widgets.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final repo = ExpenseRepository();
  late Future<List<Expense>> expenses = repo.listAll();

  void reload() => setState(() => expenses = repo.listAll());

  Future<void> addExpense() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ExpenseForm(),
    );
    if (created == true && mounted) reload();
  }

  Future<void> remove(Expense expense) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer la dépense ?'),
        content: Text('${expense.category} • ${formatMoney(expense.amount)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true) {
      await repo.delete(expense.id);
      if (mounted) reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dépenses de l’atelier')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addExpense,
        backgroundColor: CoutelyaColors.purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle dépense'),
      ),
      body: FutureBuilder<List<Expense>>(
        future: expenses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final rows = snapshot.data ?? const <Expense>[];
          final total = rows.fold<double>(0, (sum, e) => sum + e.amount);
          if (rows.isEmpty) {
            return const EmptyState(icon: Icons.account_balance_wallet_outlined, title: 'Aucune dépense', subtitle: 'Enregistrez les achats et charges de l’atelier pour calculer votre résultat réel.');
          }
          return RefreshIndicator(
            onRefresh: () async => reload(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Container(width: 46, height: 46, decoration: const BoxDecoration(color: CoutelyaColors.redSoft, shape: BoxShape.circle), child: const Icon(Icons.trending_down_rounded, color: CoutelyaColors.red)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Total des dépenses', style: TextStyle(color: CoutelyaColors.muted, fontSize: 12)), const SizedBox(height: 4), Text(formatMoney(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))])),
                    ]),
                  ),
                ),
                const SizedBox(height: 14),
                ...rows.map((expense) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: CoutelyaColors.redSoft, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.receipt_long_outlined, color: CoutelyaColors.red)),
                        title: Text(expense.category, style: const TextStyle(fontWeight: FontWeight.w900)),
                        subtitle: Text('${formatDate(expense.expenseDate)}${expense.note?.trim().isNotEmpty == true ? ' • ${expense.note}' : ''}'),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(formatMoney(expense.amount), style: const TextStyle(fontWeight: FontWeight.w900)), PopupMenuButton<String>(onSelected: (v) { if (v == 'delete') remove(expense); }, itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Supprimer'))])]),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ExpenseForm extends StatefulWidget {
  const _ExpenseForm();

  @override
  State<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<_ExpenseForm> {
  final repo = ExpenseRepository();
  final formKey = GlobalKey<FormState>();
  final amount = TextEditingController();
  final note = TextEditingController();
  String category = 'Tissu';
  bool saving = false;

  static const categories = ['Tissu', 'Fil et accessoires', 'Transport', 'Électricité', 'Loyer', 'Salaires', 'Entretien', 'Autre'];

  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() => saving = true);
    await repo.add(category: category, amount: double.parse(amount.text.replaceAll(',', '.')), note: note.text);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, bottom + 18),
      child: Form(
        key: formKey,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Nouvelle dépense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(value: category, decoration: const InputDecoration(labelText: 'Catégorie'), items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => category = v ?? category)),
          const SizedBox(height: 12),
          TextFormField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Montant (FCFA)'), validator: (v) { final n = double.tryParse((v ?? '').replaceAll(',', '.')); return n == null || n <= 0 ? 'Montant invalide' : null; }),
          const SizedBox(height: 12),
          TextFormField(controller: note, maxLines: 2, decoration: const InputDecoration(labelText: 'Note (facultatif)')),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: saving ? null : save, icon: const Icon(Icons.save_outlined), label: Text(saving ? 'Enregistrement...' : 'Enregistrer'))),
        ]),
      ),
    );
  }
}
