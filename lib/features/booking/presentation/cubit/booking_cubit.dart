import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../data/models/booking_models.dart';
import '../../domain/repositories/booking_repository.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit(
    this._bookingRepository,
    this._localStorageService,
  ) : super(const BookingState());

  final BookingRepository _bookingRepository;
  final LocalStorageService _localStorageService;

  Future<void> initialize() async {
    emit(state.copyWith(loadStatus: BookingLoadStatus.loading));

    try {
      final users = await _bookingRepository.getUsers();
      final venues = await _bookingRepository.getVenues();
      final storedUserId =
          _localStorageService.getInt(LocalStorageService.selectedUserIdKey);
      final selectedUser = users.firstWhere(
        (user) => user.id == storedUserId,
        orElse: () => users.isNotEmpty
            ? users.first
            : const QuickSlotUser(id: 0, name: 'Guest'),
      );
      final selectedVenue = venues.isNotEmpty ? venues.first : null;
      final selectedDate = DateTime.now();

      if (selectedUser.id != 0) {
        await _localStorageService.setInt(
          LocalStorageService.selectedUserIdKey,
          selectedUser.id,
        );
      }

      final slots = selectedVenue == null
          ? <VenueSlot>[]
          : await _bookingRepository.getSlots(
              venueId: selectedVenue.id,
              date: selectedDate,
            );
      final bookings = selectedUser.id == 0
          ? <UserBooking>[]
          : await _bookingRepository.getUserBookings(selectedUser.id);

      emit(
        state.copyWith(
          loadStatus: BookingLoadStatus.success,
          users: users,
          venues: venues,
          slots: slots,
          bookings: bookings,
          selectedUser: selectedUser,
          selectedVenue: selectedVenue,
          selectedDate: selectedDate,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          loadStatus: BookingLoadStatus.error,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loadStatus: BookingLoadStatus.error,
          errorMessage: 'Unable to load QuickSlot. Please try again.',
        ),
      );
    }
  }

  Future<void> selectUser(QuickSlotUser user) async {
    await _localStorageService.setInt(
      LocalStorageService.selectedUserIdKey,
      user.id,
    );

    emit(state.copyWith(selectedUser: user));
    await refreshBookings();
  }

  Future<void> selectVenue(Venue venue) async {
    emit(state.copyWith(selectedVenue: venue));
    await refreshSlots();
  }

  Future<void> selectDate(DateTime date) async {
    emit(state.copyWith(selectedDate: date));
    await refreshSlots();
  }

  void selectTab(BookingTab tab) {
    emit(state.copyWith(tab: tab, actionStatus: BookingActionStatus.idle));
  }

  Future<void> refreshSlots() async {
    final venue = state.selectedVenue;
    final date = state.selectedDate;
    if (venue == null || date == null) {
      return;
    }

    try {
      final slots = await _bookingRepository.getSlots(
        venueId: venue.id,
        date: date,
      );
      emit(state.copyWith(slots: slots));
    } on AppException catch (error) {
      emit(
        state.copyWith(
          actionStatus: BookingActionStatus.error,
          actionMessage: error.message,
        ),
      );
    }
  }

  Future<void> refreshBookings() async {
    final user = state.selectedUser;
    if (user == null) {
      return;
    }

    try {
      final bookings = await _bookingRepository.getUserBookings(user.id);
      emit(state.copyWith(bookings: bookings));
    } on AppException catch (error) {
      emit(
        state.copyWith(
          actionStatus: BookingActionStatus.error,
          actionMessage: error.message,
        ),
      );
    }
  }

  Future<void> bookSlot(VenueSlot slot) async {
    if (!slot.isAvailable || state.selectedDate == null) {
      return;
    }

    emit(
      state.copyWith(
        actionStatus: BookingActionStatus.loading,
        actionMessage: null,
      ),
    );

    try {
      await _bookingRepository.bookSlot(
        slotId: slot.id,
        date: state.selectedDate!,
      );
      await _refreshAfterAction(
        status: BookingActionStatus.success,
        message: 'Slot booked successfully',
      );
    } on AppException catch (error) {
      await refreshSlots();
      final isConflict = error.statusCode == 409;
      emit(
        state.copyWith(
          actionStatus:
              isConflict ? BookingActionStatus.conflict : BookingActionStatus.error,
          actionMessage: isConflict
              ? 'That slot was just booked. Please choose another time.'
              : error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionStatus: BookingActionStatus.error,
          actionMessage: 'Unable to book this slot. Please try again.',
        ),
      );
    }
  }

  Future<void> cancelBooking(UserBooking booking) async {
    if (!booking.isActive) {
      return;
    }

    emit(
      state.copyWith(
        actionStatus: BookingActionStatus.loading,
        actionMessage: null,
      ),
    );

    try {
      await _bookingRepository.cancelBooking(booking.id);
      await _refreshAfterAction(
        status: BookingActionStatus.success,
        message: 'Booking cancelled',
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          actionStatus: BookingActionStatus.error,
          actionMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionStatus: BookingActionStatus.error,
          actionMessage: 'Unable to cancel this booking. Please try again.',
        ),
      );
    }
  }

  Future<void> _refreshAfterAction({
    required BookingActionStatus status,
    required String message,
  }) async {
    final slots = state.selectedVenue == null || state.selectedDate == null
        ? state.slots
        : await _bookingRepository.getSlots(
            venueId: state.selectedVenue!.id,
            date: state.selectedDate!,
          );
    final bookings = state.selectedUser == null
        ? state.bookings
        : await _bookingRepository.getUserBookings(state.selectedUser!.id);

    emit(
      state.copyWith(
        actionStatus: status,
        actionMessage: message,
        slots: slots,
        bookings: bookings,
      ),
    );
  }
}
