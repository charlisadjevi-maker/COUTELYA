class Client {
  const Client({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.whatsapp,
    this.email,
    this.gender,
    this.address,
    this.notes,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? gender;
  final String? address;
  final String? notes;

  String get fullName => '$firstName $lastName'.trim();

  factory Client.fromMap(Map<String, Object?> map) => Client(
        id: map['id'] as String,
        firstName: (map['first_name'] as String?) ?? '',
        lastName: (map['last_name'] as String?) ?? '',
        phone: map['phone'] as String?,
        whatsapp: map['whatsapp'] as String?,
        email: map['email'] as String?,
        gender: map['gender'] as String?,
        address: map['address'] as String?,
        notes: map['notes'] as String?,
      );
}

class Measurement {
  const Measurement({
    required this.id,
    required this.clientId,
    required this.category,
    required this.takenAt,
    required this.values,
    this.notes,
  });

  final String id;
  final String clientId;
  final String category;
  final DateTime takenAt;
  final Map<String, double?> values;
  final String? notes;
}

class CoutureOrder {
  const CoutureOrder({
    required this.id,
    required this.clientId,
    required this.reference,
    required this.garmentType,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.description,
    this.fabric,
    this.color,
    this.fittingDate,
    this.deliveryDate,
    this.notes,
  });

  final String id;
  final String clientId;
  final String reference;
  final String garmentType;
  final String? description;
  final String? fabric;
  final String? color;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final DateTime? fittingDate;
  final DateTime? deliveryDate;
  final String? notes;

  factory CoutureOrder.fromMap(Map<String, Object?> map) => CoutureOrder(
        id: map['id'] as String,
        clientId: map['client_id'] as String,
        reference: (map['reference'] as String?) ?? '',
        garmentType: (map['garment_type'] as String?) ?? '',
        description: map['description'] as String?,
        fabric: map['fabric'] as String?,
        color: map['color'] as String?,
        totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0,
        status: (map['status'] as String?) ?? 'registered',
        orderDate: DateTime.tryParse((map['order_date'] as String?) ?? '') ??
            DateTime.tryParse((map['created_at'] as String?) ?? '') ??
            DateTime.now(),
        fittingDate: DateTime.tryParse((map['fitting_date'] as String?) ?? ''),
        deliveryDate: DateTime.tryParse((map['delivery_date'] as String?) ?? ''),
        notes: map['notes'] as String?,
      );
}

class Payment {
  const Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.paidAt,
    this.note,
  });

  final String id;
  final String orderId;
  final double amount;
  final String method;
  final DateTime paidAt;
  final String? note;

  factory Payment.fromMap(Map<String, Object?> map) => Payment(
        id: map['id'] as String,
        orderId: map['order_id'] as String,
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        method: (map['payment_method'] as String?) ?? 'cash',
        paidAt: DateTime.tryParse((map['paid_at'] as String?) ?? '') ?? DateTime.now(),
        note: map['note'] as String?,
      );
}

class Expense {
  const Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.expenseDate,
    this.note,
  });

  final String id;
  final String category;
  final double amount;
  final DateTime expenseDate;
  final String? note;

  factory Expense.fromMap(Map<String, Object?> map) => Expense(
        id: map['id'] as String,
        category: (map['category'] as String?) ?? 'Autre',
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        expenseDate: DateTime.tryParse((map['expense_date'] as String?) ?? '') ?? DateTime.now(),
        note: map['note'] as String?,
      );
}

class DashboardStats {
  const DashboardStats({
    required this.inProgress,
    required this.ready,
    required this.delivered,
    required this.late,
    required this.received,
    required this.receivable,
  });

  final int inProgress;
  final int ready;
  final int delivered;
  final int late;
  final double received;
  final double receivable;
}
