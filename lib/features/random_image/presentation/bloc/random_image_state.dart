part of 'random_image_bloc.dart';

/// --- Sealed class for all States ---
@freezed
sealed class RandomImageState with _$RandomImageState {
  /// Initial state, before anything is loaded.
  const factory RandomImageState.initial() = Initial;

  /// Loading state, while fetching image.
  ///
  /// It can optionally hold the previous image and scheme
  /// to prevent the UI from "blinking" back to a shimmer.
  const factory RandomImageState.loading({
    ImageEntity? previousImage,
    Color? previousBackgroundColor,
    Brightness? previousForegroundBrightness,
  }) = Loading;

  /// Success state, holds the image and the *full color scheme*.
  const factory RandomImageState.loaded({
    required ImageEntity image,
    required Color backgroundColor,
    required Brightness foregroundBrightness,
  }) = Loaded;

  /// Error state, holds the failure message.
  const factory RandomImageState.error({required String message}) = Error;
}
