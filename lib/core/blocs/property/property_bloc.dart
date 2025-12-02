//lib/core/blocs/property/property_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel265/core/blocs/property/property_event.dart';
import 'package:travel265/core/blocs/property/property_state.dart';
import 'package:travel265/core/repositories/property_repository.dart';
import 'package:travel265/core/utils/logger.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final PropertyRepository _repository;

  PropertyBloc({PropertyRepository? repository})
      : _repository = repository ?? PropertyRepository(),
        super(PropertyState.initial()) {
    on<LoadProperties>(_onLoadProperties);
    on<LoadPropertyDetail>(_onLoadPropertyDetail);
  }

  Future<void> _onLoadProperties(
      LoadProperties event,
      Emitter<PropertyState> emit,
      ) async {
    emit(PropertyState.loading());

    try {
      final properties = await _repository.getProperties(
        city: event.city,
        type: event.type,
      );
      emit(PropertyState.loaded(properties));
    } catch (e) {
      logger.e('Load properties failed', error: e);
      emit(PropertyState.error('Failed to load properties: $e'));
    }
  }

  Future<void> _onLoadPropertyDetail(
      LoadPropertyDetail event,
      Emitter<PropertyState> emit,
      ) async {
    emit(PropertyState.loading());

    try {
      final property = await _repository.getPropertyById(event.propertyId);
      emit(PropertyState(
        status: PropertyStatus.loaded,
        selectedProperty: property,
        properties: state.properties,
      ));
    } catch (e) {
      logger.e('Load property detail failed', error: e);
      emit(PropertyState.error('Property not found: $e'));
    }
  }
}