class Seat {
  final String id;
  final String showtimeId;
  final String seatNumber;
  final String row;
  final String type; // regular, vip, couple
  final String status; // available, reserved, booked
  final String? reservedBy;
  final DateTime? reservedUntil;

  Seat({
    required this.id,
    required this.showtimeId,
    required this.seatNumber,
    required this.row,
    required this.type,
    required this.status,
    this.reservedBy,
    this.reservedUntil,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['_id'] ?? '',
      showtimeId: json['showtimeId'] ?? '',
      seatNumber: json['seatNumber'] ?? '',
      row: json['row'] ?? '',
      type: json['type'] ?? 'regular',
      status: json['status'] ?? 'available',
      reservedBy: json['reservedBy'],
      reservedUntil: json['reservedUntil'] != null
          ? DateTime.parse(json['reservedUntil'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'showtimeId': showtimeId,
      'seatNumber': seatNumber,
      'row': row,
      'type': type,
      'status': status,
      'reservedBy': reservedBy,
      'reservedUntil': reservedUntil?.toIso8601String(),
    };
  }

  bool get isAvailable => status == 'available';
  bool get isReserved => status == 'reserved';
  bool get isBooked => status == 'booked';
}
