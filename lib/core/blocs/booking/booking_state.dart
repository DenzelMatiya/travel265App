//lib/core/blocs/booking/booking_state.dart
import 'package:equatable/equatable.dart';
import 'package:travel265/core/models/booking_model.dart';

enum BookingStatus { initial, loading, loaded, error }

class BookingState extends Equatable {
  final BookingStatus status;
  final List<BookingModel> bookings;
  final String? errorMessage;

  const BookingState({
    required this.status,
    this.bookings = const [],
    this.errorMessage,
  });

  factory BookingState.initial() => const BookingState(status: BookingStatus.initial);

  factory BookingState.loading() => const BookingState(status: BookingStatus.loading);

  factory BookingState.loaded(List<BookingModel> bookings) => BookingState(
    status: BookingStatus.loaded,
    bookings: bookings,
  );

  factory BookingState.error(String message) => BookingState(
    status: BookingStatus.error,
    errorMessage: message,
  );

  @override
  List<Object?> get props => [status, bookings, errorMessage];
}