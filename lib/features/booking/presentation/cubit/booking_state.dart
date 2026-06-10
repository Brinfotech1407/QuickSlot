import 'package:equatable/equatable.dart';

import '../../data/models/booking_models.dart';

enum BookingLoadStatus { initial, loading, success, error }

enum BookingActionStatus { idle, loading, success, conflict, error }

enum BookingTab { venues, myBookings }

class BookingState extends Equatable {
  const BookingState({
    this.loadStatus = BookingLoadStatus.initial,
    this.actionStatus = BookingActionStatus.idle,
    this.tab = BookingTab.venues,
    this.users = const [],
    this.venues = const [],
    this.slots = const [],
    this.bookings = const [],
    this.selectedUser,
    this.selectedVenue,
    this.selectedDate,
    this.errorMessage,
    this.actionMessage,
  });

  final BookingLoadStatus loadStatus;
  final BookingActionStatus actionStatus;
  final BookingTab tab;
  final List<QuickSlotUser> users;
  final List<Venue> venues;
  final List<VenueSlot> slots;
  final List<UserBooking> bookings;
  final QuickSlotUser? selectedUser;
  final Venue? selectedVenue;
  final DateTime? selectedDate;
  final String? errorMessage;
  final String? actionMessage;

  BookingState copyWith({
    BookingLoadStatus? loadStatus,
    BookingActionStatus? actionStatus,
    BookingTab? tab,
    List<QuickSlotUser>? users,
    List<Venue>? venues,
    List<VenueSlot>? slots,
    List<UserBooking>? bookings,
    QuickSlotUser? selectedUser,
    Venue? selectedVenue,
    DateTime? selectedDate,
    String? errorMessage,
    String? actionMessage,
  }) {
    return BookingState(
      loadStatus: loadStatus ?? this.loadStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      tab: tab ?? this.tab,
      users: users ?? this.users,
      venues: venues ?? this.venues,
      slots: slots ?? this.slots,
      bookings: bookings ?? this.bookings,
      selectedUser: selectedUser ?? this.selectedUser,
      selectedVenue: selectedVenue ?? this.selectedVenue,
      selectedDate: selectedDate ?? this.selectedDate,
      errorMessage: errorMessage,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        actionStatus,
        tab,
        users,
        venues,
        slots,
        bookings,
        selectedUser,
        selectedVenue,
        selectedDate,
        errorMessage,
        actionMessage,
      ];
}
