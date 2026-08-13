class CoutureOrder {
  const CoutureOrder({
    required this.id,
    required this.clientId,
    required this.reference,
    required this.garmentType,
    this.description,
    required this.totalAmount,
    this.deliveryDate,
    this.fittingDate,
    this.status = 'registered',
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
  });

  final String id;
  final String clientId;
  final String reference;
  final String garmentType;
  final String? description;
  final double totalAmount;
  final DateTime? deliveryDate;
  final DateTime? fittingDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  Map<String, Object?> toLocalMap() => {
        'id': id,
        'client_id': clientId,
        'reference': reference,
        'garment_type': garmentType,
        'description': description,
        'total_amount': totalAmount,
        'delivery_date': deliveryDate?.toUtc().toIso8601String(),
        'fitting_date': fittingDate?.toUtc().toIso8601String(),
        'status': status,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'sync_status': syncStatus,
      };

  factory CoutureOrder.fromLocalMap(Map<String, Object?> map) => CoutureOrder(
        id: map['id']! as String,
        clientId: map['client_id']! as String,
        reference: map['reference']! as String,
        garmentType: map['garment_type']! as String,
        description: map['description'] as String?,
        totalAmount: (map['total_amount'] as num).toDouble(),
        deliveryDate: map['delivery_date'] == null
            ? null
            : DateTime.parse(map['delivery_date']! as String),
        fittingDate: map['fitting_date'] == null
            ? null
            : DateTime.parse(map['fitting_date']! as String),
        status: (map['status'] as String?) ?? 'registered',
        createdAt: DateTime.parse(map['created_at']! as String),
        updatedAt: DateTime.parse(map['updated_at']! as String),
        syncStatus: (map['sync_status'] as String?) ?? 'pending',
      );
}
