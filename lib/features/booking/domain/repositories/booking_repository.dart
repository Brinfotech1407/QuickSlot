import '../../data/models/booking_models.dart';

abstract class BookingRepository {
  Future<List<QuickSlotUser>> getUsers();

  Future<List<Venue>> getVenues();

  Future<List<VenueSlot>> getSlots({
    required int venueId,
    required DateTime date,
  });

  Future<void> bookSlot({
    required int slotId,
    required DateTime date,
  });

  Future<List<UserBooking>> getUserBookings(int userId);

  Future<void> cancelBooking(int bookingId);
}
