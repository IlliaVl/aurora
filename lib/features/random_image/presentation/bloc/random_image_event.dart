part of 'random_image_bloc.dart';

/// --- Sealed class for all Events ---
@freezed
sealed class RandomImageEvent with _$RandomImageEvent {
  /// Event dispatched to fetch a new image.
  const factory RandomImageEvent.fetchRequested() = _FetchRequested;
}