//lib/core/blocs/booking/booking_event.dart
import 'package:equatable/equatable.dart';
import 'package:travel265/core/models/booking_model.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserBookings extends BookingEvent {
  final String userId;

  const LoadUserBookings(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateBooking extends BookingEvent {
  final BookingModel booking;

  const CreateBooking(this.booking);

  @override
  List<Object?> get props => [booking];
}

class UpdateBookingStatus extends BookingEvent {
  final String bookingId;
  final String status;

  const UpdateBookingStatus(this.bookingId, this.status);

  @override
  List<Object?> get props => [bookingId, status];
}