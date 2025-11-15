import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:aurora/features/random_image/domain/entities/image_entity.dart';
import 'package:aurora/features/random_image/domain/usecases/get_random_image.dart';

part 'random_image_event.dart';
part 'random_image_state.dart';
part 'random_image_bloc.freezed.dart';

/// BLoC for managing the state of the random image feature.
@injectable
class RandomImageBloc extends Bloc<RandomImageEvent, RandomImageState> {
  final GetRandomImage _getRandomImage;

  RandomImageBloc(
      this._getRandomImage,
      ) : super(const RandomImageState.initial()) {
    on<_FetchRequested>(_onFetchRequested);
  }

  /// Handles the event to fetch a new image.
  Future<void> _onFetchRequested(
      _FetchRequested event,
      Emitter<RandomImageState> emit,
      ) async {
    // --- Get the current image to show while loading ---
    final previousImage = switch (state) {
      Loaded(:final image) => image,
      Loading(:final previousImage) => previousImage,
      Error(:final previousImage) => previousImage,
      _ => null,
    };

    // --- Emit Loading state, preserving old data ---
    emit(RandomImageState.loading(
      previousImage: previousImage,
    ));

    final failureOrImage = await _getRandomImage();

    // The `fold` method forces us to handle both Failure and Success
    await failureOrImage.fold(
      // --- Failure Case ---
          (failure) async {
        // --- THIS IS THE FIX ---
        // Emit an error state, but pass in the previous image
        // so the UI can keep displaying it.
        emit(RandomImageState.error(
          message: failure.message,
          previousImage: previousImage,
        ));
      },
      // --- Success Case ---
          (image) async {
        // --- Emit success, just with the image ---
        emit(RandomImageState.loaded(
          image: image,
        ));
      },
    );
  }
}