import 'package:equatable/equatable.dart';

/// --- Business Entity ---
/// A simple Dart object representing the core data we need.
/// It is decoupled from any API response.
class ImageEntity extends Equatable {
  final String url;

  const ImageEntity({required this.url});

  @override
  List<Object> get props => [url];
}
