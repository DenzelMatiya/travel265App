//lib/core/blocs/booking/booking_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel265/core/blocs/booking/booking_event.dart';
import 'package:travel265/core/blocs/booking/booking_state.dart';
import 'package:travel265/core/repositories/booking_repository.dart';
import 'package:travel265/core/utils/logger.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _repository;

  BookingBloc({BookingRepository? repository})
      : _repository = repository ?? BookingRepository(),
        super(BookingState.initial()) {
    on<LoadUserBookings>(_onLoadUserBookings);
    on<CreateBooking>(_onCreateBooking);
    on<UpdateBookingStatus>(_onUpdateBookingStatus);
  }

  Future<void> _onLoadUserBookings(
      LoadUserBookings event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingState.loading());

    try {
      final bookings = await _repository.getUserBookings(event.userId);
      emit(BookingState.loaded(bookings));
    } catch (e, stackTrace) {
      logger.e('Load user bookings failed', error: e, stackTrace: stackTrace);
      emit(BookingState.error('Failed to load bookings: $e'));
    }
  }

  Future<void> _onCreateBooking(
      CreateBooking event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingState.loading());

    try {
      final booking = await _repository.createBooking(event.booking);
      emit(BookingState.loaded([booking]));
    } catch (e, stackTrace) {
      logger.e('Create booking failed', error: e, stackTrace: stackTrace);
      emit(BookingState.error('Failed to create booking: $e'));
    }
  }

  Future<void> _onUpdateBookingStatus(
      UpdateBookingStatus event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingState.loading());

    try {
      final booking = await _repository.updateBookingStatus(event.bookingId, event.status);
      emit(BookingState.loaded([booking]));
    } catch (e, stackTrace) {
      logger.e('Update booking status failed', error: e, stackTrace: stackTrace);
      emit(BookingState.error('Failed to update booking: $e'));
    }
  }
}