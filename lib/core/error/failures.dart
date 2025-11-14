import 'package:equatable/equatable.dart';

/// --- Abstract Failure Class ---

/// All Failures in the app will extend this class
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// --- General Failures ---

/// Failure for server-side errors (e.g., 404, 500)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Failure for network connection issues (e.g., no internet)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}