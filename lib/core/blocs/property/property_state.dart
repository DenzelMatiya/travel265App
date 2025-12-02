//lib/core/blocs/property/property_state.dart
import 'package:equatable/equatable.dart';
import 'package:travel265/core/models/property_model.dart';

enum PropertyStatus { initial, loading, loaded, error }

class PropertyState extends Equatable {
  final PropertyStatus status;
  final List<PropertyModel> properties;
  final PropertyModel? selectedProperty;
  final String? errorMessage;

  const PropertyState({
    required this.status,
    this.properties = const [],
    this.selectedProperty,
    this.errorMessage,
  });

  factory PropertyState.initial() => const PropertyState(status: PropertyStatus.initial);

  factory PropertyState.loading() => const PropertyState(status: PropertyStatus.loading);

  factory PropertyState.loaded(List<PropertyModel> properties) =>
      PropertyState(status: PropertyStatus.loaded, properties: properties);

  factory PropertyState.error(String message) =>
      PropertyState(status: PropertyStatus.error, errorMessage: message);

  @override
  List<Object?> get props => [status, properties, selectedProperty, errorMessage];
}