class Client {
  const Client({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.whatsapp,
    this.gender,
    this.address,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? whatsapp;
  final String? gender;
  final String? address;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  String get fullName => '$firstName $lastName'.trim();

  Map<String, Object?> toLocalMap() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'whatsapp': whatsapp,
        'gender': gender,
        'address': address,
        'notes': notes,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'sync_status': syncStatus,
      };

  factory Client.fromLocalMap(Map<String, Object?> map) => Client(
        id: map['id']! as String,
        firstName: map['first_name']! as String,
        lastName: map['last_name']! as String,
        phone: map['phone'] as String?,
        whatsapp: map['whatsapp'] as String?,
        gender: map['gender'] as String?,
        address: map['address'] as String?,
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map['created_at']! as String),
        updatedAt: DateTime.parse(map['updated_at']! as String),
        syncStatus: (map['sync_status'] as String?) ?? 'pending',
      );
}
