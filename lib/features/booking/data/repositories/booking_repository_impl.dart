import 'package:intl/intl.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_models.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._dioClient);

  final DioClient _dioClient;
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<List<QuickSlotUser>> getUsers() async {
    final response = await _dioClient.get('/users');
    final data = response.data as Map<String, dynamic>;
    final users = data['users'] as List<dynamic>;

    return users
        .map((item) => QuickSlotUser.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Venue>> getVenues() async {
    final response = await _dioClient.get('/venues');
    final data = response.data as Map<String, dynamic>;
    final venues = data['venues'] as List<dynamic>;

    return venues
        .map((item) => Venue.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<VenueSlot>> getSlots({
    required int venueId,
    required DateTime date,
  }) async {
    final response = await _dioClient.get(
      '/venues/$venueId/slots',
      queryParameters: {'date': _apiDateFormat.format(date)},
    );
    final data = response.data as Map<String, dynamic>;
    final slots = data['slots'] as List<dynamic>;

    return slots
        .map((item) => VenueSlot.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> bookSlot({
    required int slotId,
    required DateTime date,
  }) async {
    await _dioClient.post(
      '/bookings',
      data: {
        'slotId': slotId,
        'date': _apiDateFormat.format(date),
      },
    );
  }

  @override
  Future<List<UserBooking>> getUserBookings(int userId) async {
    final response = await _dioClient.get('/users/$userId/bookings');
    final data = response.data as Map<String, dynamic>;
    final bookings = data['bookings'] as List<dynamic>;

    return bookings
        .map((item) => UserBooking.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cancelBooking(int bookingId) async {
    await _dioClient.delete('/bookings/$bookingId');
  }
}
