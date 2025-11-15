part of 'random_image_bloc.dart';

/// --- Sealed class for all States ---
@freezed
sealed class RandomImageState with _$RandomImageState {
  /// Initial state, before anything is loaded.
  const factory RandomImageState.initial() = Initial;

  /// Loading state, while fetching image.
  const factory RandomImageState.loading({ImageEntity? previousImage}) =
      Loading;

  /// Success state, holds the new image and the previous one for transition.
  const factory RandomImageState.loaded({
    required ImageEntity image,
    ImageEntity? previousImage, // <-- ADDED
  }) = Loaded;

  /// Error state, holds the failure message and the previous image.
  const factory RandomImageState.error({
    required String message,
    ImageEntity? previousImage,
  }) = Error;
}
