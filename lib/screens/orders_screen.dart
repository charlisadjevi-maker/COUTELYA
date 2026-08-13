import 'package:flutter/material.dart';

import '../models/order.dart';
import '../repositories/order_repository.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final repository = OrderRepository();
  late Future<List<CoutureOrder>> orders = repository.listAll();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commandes')),
      body: FutureBuilder<List<CoutureOrder>>(
        future: orders,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snapshot.data!;
          if (rows.isEmpty) {
            return const Center(
              child: Text(
                'Aucune commande.\nCréez d’abord un client, puis sa commande.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final order = rows[index];
              return Card(
                child: ListTile(
                  title: Text('${order.reference} • ${order.garmentType}'),
                  subtitle: Text(
                    '${order.totalAmount.toStringAsFixed(0)} FCFA'
                    '${order.deliveryDate == null ? '' : ' • livraison ${order.deliveryDate!.day}/${order.deliveryDate!.month}/${order.deliveryDate!.year}'}',
                  ),
                  trailing: Chip(label: Text(order.status)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
