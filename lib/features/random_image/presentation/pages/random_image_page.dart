import 'dart:ui';
import 'package:aurora/core/di/injection_container.dart';
import 'package:aurora/features/random_image/domain/entities/image_entity.dart'; // <-- ADDED
import 'package:aurora/features/random_image/presentation/bloc/random_image_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';


/// The root widget for the Random Image feature.
///
/// This widget is responsible for creating and providing the
/// [RandomImageBloc] to its descendant, [RandomImageView].
class RandomImagePage extends StatelessWidget {
  const RandomImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Create and provide the BLoC, and auto-fetch the first image
      create: (context) =>
          sl<RandomImageBloc>()..add(const RandomImageEvent.fetchRequested()),
      child: const RandomImageView(),
    );
  }
}

/// The main view widget that rebuilds based on [RandomImageState].
///
/// It uses a [BlocListener] to show errors and a [BlocBuilder]
/// to rebuild the UI.
class RandomImageView extends StatelessWidget {
  const RandomImageView({super.key});

  @override
  Widget build(BuildContext context) {

    return BlocListener<RandomImageBloc, RandomImageState>(
      listener: (context, state) {
        if (state is Error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              // The theme is applied from main.dart
            ),
          );
        }
      },
      child: Scaffold(
        // Allow the body to draw behind the app bar
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            "AURORA",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildBackgroundImageWidget(
                context,
                context.watch<RandomImageBloc>().state,
              ),
            ),

            // --- LAYER 2: A dark gradient overlay to ensure text is readable ---
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    // Center is lighter
                    const Color(0xFF1C1C1C).withValues(alpha: 0.8),
                    // Edges are darker
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),

            // --- LAYER 3: The UI Content ---
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _buildImageWidget(
                            context,
                            context.watch<RandomImageBloc>().state,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- The "Another" Button ---
                    ElevatedButton(
                      onPressed: switch (context
                          .watch<RandomImageBloc>()
                          .state) {
                        // Only enable button if not loading
                        Loading() => null,
                        _ => () => context.read<RandomImageBloc>().add(
                          const RandomImageEvent.fetchRequested(),
                        ),
                      },
                      // We use the button's theme from main.dart
                      child: SizedBox(
                        // --- "Fixed Size Button" Fix ---
                        width: 120,
                        height: 24,
                        child: Center(
                          child: switch (context
                              .watch<RandomImageBloc>()
                              .state) {
                            Loading() => const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Color(0xFF1C1C1C), // auroraBlack
                              ),
                            ),
                            _ => const Text("Another"),
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// --- HELPER WIDGETS ---
  /// These helpers now build the image widget based on the
  /// *entire state*, which is the key to fixing the transition.

  /// Builds the main (foreground) image widget.
  Widget _buildImageWidget(BuildContext context, RandomImageState state) {
    final ImageEntity? image = switch (state) {
      Loaded(:final image) => image,
      Loading(:final previousImage) => previousImage,
      Error(:final previousImage) => previousImage,
      Initial() => null,
    };

    if (image != null) {
      return Image.memory(
        key: ValueKey(image.imageBytes.hashCode),
        image.imageBytes,
        fit: BoxFit.cover,
      );
    }

    // Show shimmer on initial load, or error icon if error on first load
    return switch (state) {
      Error() => const _ErrorIcon(key: ValueKey('error')),
      _ => const _LoadingShimmer(key: ValueKey('initial_loading')),
    };
  }

  /// Builds the blurred (background) image widget.
  Widget _buildBackgroundImageWidget(
    BuildContext context,
    RandomImageState state,
  ) {
    final ImageEntity? image = switch (state) {
      Loaded(:final image) => image,
      Loading(:final previousImage) => previousImage,
      Error(:final previousImage) => previousImage,
      Initial() => null,
    };

    if (image != null) {
      return ImageFiltered(
        key: ValueKey('bg_${image.imageBytes.hashCode}'),
        imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Image.memory(
          image.imageBytes,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    // Fallback for initial load
    return const SizedBox(key: ValueKey('bg_initial'));
  }
}

/// --- A Reusable Error Icon Widget ---
class _ErrorIcon extends StatelessWidget {
  const _ErrorIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          size: 40,
        ),
      ),
    );
  }
}

/// --- A Reusable Loading Shimmer Widget ---
class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // A shimmer effect is a more "premium" loading state
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[800]!,
      child: Container(color: Colors.white),
    );
  }
}
