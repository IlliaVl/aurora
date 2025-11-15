part of 'random_image_bloc.dart';

/// --- Sealed class for all States ---
@freezed
sealed class RandomImageState with _$RandomImageState {
  /// Initial state, before anything is loaded.
  const factory RandomImageState.initial() = Initial;

  /// Loading state, while fetching image.
  ///
  /// It can optionally hold the previous image
  /// to prevent the UI from "blinking" back to a shimmer.
  const factory RandomImageState.loading({ImageEntity? previousImage}) =
      Loading;

  /// Success state, holds the image.
  const factory RandomImageState.loaded({required ImageEntity image}) = Loaded;

  /// Error state, holds the failure message.
  const factory RandomImageState.error({required String message}) = Error;
}
