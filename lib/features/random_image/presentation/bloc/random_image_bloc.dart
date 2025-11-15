import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

// --- Use the new, better package ---
import 'package:palette_generator_master/palette_generator_master.dart';
import 'package:aurora/features/random_image/domain/entities/image_entity.dart';
import 'package:aurora/features/random_image/domain/usecases/get_random_image.dart';

part 'random_image_event.dart';

part 'random_image_state.dart';

part 'random_image_bloc.freezed.dart';

// --- A default color for fallbacks ---
const Color _kDefaultBackgroundColor = Color(0xFF1C1C1C);
const Brightness _kDefaultBrightness = Brightness.dark;

/// BLoC for managing the state of the random image feature.
@injectable
class RandomImageBloc extends Bloc<RandomImageEvent, RandomImageState> {
  final GetRandomImage _getRandomImage;

  RandomImageBloc(this._getRandomImage)
    : super(const RandomImageState.initial()) {
    on<_FetchRequested>(_onFetchRequested);
  }

  /// Handles the event to fetch a new image and its colors.
  Future<void> _onFetchRequested(
    _FetchRequested event,
    Emitter<RandomImageState> emit,
  ) async {
    // --- Get the current data to show while loading ---
    final (previousImage, previousColor, previousBrightness) = switch (state) {
      Loaded(
        :final image,
        :final backgroundColor,
        :final foregroundBrightness,
      ) =>
        (image, backgroundColor, foregroundBrightness),
      Loading(
        :final previousImage,
        :final previousBackgroundColor,
        :final previousForegroundBrightness,
      ) =>
        (previousImage, previousBackgroundColor, previousForegroundBrightness),
      _ => (null, null, null),
    };

    // --- Emit Loading state, preserving old data ---
    emit(
      RandomImageState.loading(
        previousImage: previousImage,
        previousBackgroundColor: previousColor,
        previousForegroundBrightness: previousBrightness,
      ),
    );

    final failureOrImage = await _getRandomImage();

    // The `fold` method forces us to handle both Failure and Success
    await failureOrImage.fold(
      // --- Failure Case ---
      (failure) async {
        emit(RandomImageState.error(message: failure.message));
      },
      // --- Success Case ---
      (image) async {
        try {
          // --- Color Extraction ---
          final palette = await _generatePalette(image.url);
          final (bgColor, brightness) = _extractColors(palette);

          emit(
            RandomImageState.loaded(
              image: image,
              backgroundColor: bgColor,
              foregroundBrightness: brightness,
            ),
          );
        } catch (e) {
          // Handle palette generation failure
          emit(
            RandomImageState.loaded(
              image: image,
              backgroundColor: _kDefaultBackgroundColor,
              foregroundBrightness: _kDefaultBrightness,
            ),
          );
        }
      },
    );
  }

  /// --- Helper Methods ---

  /// Generates the color palette from a network image
  Future<PaletteGeneratorMaster> _generatePalette(String imageUrl) {
    // We analyze a smaller version of the image for performance
    return PaletteGeneratorMaster.fromImageProvider(
      NetworkImage(imageUrl),
      size: const Size(100, 100),
      // Analyze a smaller, faster version
      // --- Use LAB color space for perceptually accurate colors ---
      // This will fix the "sickly green" bug
      targets: PaletteTargetMaster.baseTargets,
      // targets: [
      //   // PaletteTargetMaster.vibrant,
      //   // PaletteTargetMaster.muted,
      //   PaletteTargetMaster.lightMuted,
      //   // // Create custom target
      //   // PaletteTargetMaster(
      //   //   saturationWeight: 0.8,
      //   //   lightnessWeight: 0.6,
      //   //   populationWeight: 0.4,
      //   //   minimumSaturation: 0.3,
      //   //   maximumSaturation: 0.9,
      //   //   minimumLightness: 0.2,
      //   //   maximumLightness: 0.8,
      //   // ),
      // ],
      enableCaching: true,
      // generateHarmony: true,
      colorSpace: ColorSpace.lab,
      timeout: const Duration(seconds: 10),
    );
  }

  /// Extracts a usable background color and a contrasting foreground brightness
  (Color, Brightness) _extractColors(PaletteGeneratorMaster? palette) {
    if (palette == null) {
      return (_kDefaultBackgroundColor, _kDefaultBrightness);
    }

    // --- New, smarter logic to get the "aura" ---
    // We prioritize light, muted colors for the background,
    // which is what you'd expect from a light-themed image.
    final Color color =
        palette.lightMutedColor?.color ?? _kDefaultBackgroundColor;
    // final Color color =
    //     palette.lightMutedColor?.color ??
    //     palette.lightVibrantColor?.color ??
    //     palette.dominantColor?.color ??
    //     _kDefaultBackgroundColor;

    // Use the package's helper to get the *best* text color
    final Color bestTextColor = palette.getBestTextColorFor(
      color,
      minimumContrast: 4.5, // WCAG AA standard
    );

    // --- Determine brightness based on the best text color ---
    // If the best text is black, the background must be light.
    final Brightness brightness = bestTextColor == Colors.black
        ? Brightness.light
        : Brightness.dark;

    return (color, brightness);
  }
}
