import 'package:equatable/equatable.dart';
import 'package:travel265/core/models/property_model.dart';

abstract class PropertyEvent extends Equatable {
  const PropertyEvent();

  @override
  List<Object?> get props => [];
}
class CreateProperty extends PropertyEvent {
  final Map<String, dynamic> propertyData;
  final List<File> imageFiles;

  const CreateProperty({
    required this.propertyData,
    required this.imageFiles,
  });

  @override
  List<Object?> get props => [propertyData, imageFiles];
}

class LoadProperties extends PropertyEvent {
  final String? city;
  final PropertyType? type;

  const LoadProperties({this.city, this.type});

  @override
  List<Object?> get props => [city, type];
}

class LoadPropertyDetail extends PropertyEvent {
  final String propertyId;

  const LoadPropertyDetail(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}