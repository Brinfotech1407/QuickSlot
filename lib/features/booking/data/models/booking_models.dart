import 'package:equatable/equatable.dart';

class QuickSlotUser extends Equatable {
  const QuickSlotUser({
    required this.id,
    required this.name,
  });

  factory QuickSlotUser.fromJson(Map<String, dynamic> json) {
    return QuickSlotUser(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

class Venue extends Equatable {
  const Venue({
    required this.id,
    required this.name,
    required this.sport,
    required this.area,
    required this.address,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as int,
      name: json['name'] as String,
      sport: json['sport'] as String,
      area: json['area'] as String,
      address: json['address'] as String,
    );
  }

  final int id;
  final String name;
  final String sport;
  final String area;
  final String address;

  @override
  List<Object?> get props => [id, name, sport, area, address];
}

class VenueSlot extends Equatable {
  const VenueSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory VenueSlot.fromJson(Map<String, dynamic> json) {
    return VenueSlot(
      id: json['id'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: json['status'] as String,
    );
  }

  final int id;
  final String startTime;
  final String endTime;
  final String status;

  bool get isAvailable => status == 'available';

  String get label {
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  static String _formatTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour $suffix';
  }

  @override
  List<Object?> get props => [id, startTime, endTime, status];
}

class UserBooking extends Equatable {
  const UserBooking({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.venueName,
    required this.sport,
    required this.area,
    required this.slotId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory UserBooking.fromJson(Map<String, dynamic> json) {
    return UserBooking(
      id: json['id'] as int,
      userId: json['userId'] as int,
      venueId: json['venueId'] as int,
      venueName: json['venueName'] as String,
      sport: json['sport'] as String,
      area: json['area'] as String,
      slotId: json['slotId'] as int,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: json['status'] as String,
    );
  }

  final int id;
  final int userId;
  final int venueId;
  final String venueName;
  final String sport;
  final String area;
  final int slotId;
  final String date;
  final String startTime;
  final String endTime;
  final String status;

  bool get isActive => status == 'booked';

  String get slotLabel {
    return '${VenueSlot._formatTime(startTime)} - ${VenueSlot._formatTime(endTime)}';
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        venueId,
        venueName,
        sport,
        area,
        slotId,
        date,
        startTime,
        endTime,
        status,
      ];
}
