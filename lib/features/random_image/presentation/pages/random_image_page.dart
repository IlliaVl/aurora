import 'package:aurora/core/di/injection_container.dart';
import 'package:aurora/features/random_image/presentation/bloc/random_image_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
/// It uses a [BlocBuilder] to rebuild the UI accordingly,
/// handling loading, success, and error states.
class RandomImageView extends StatelessWidget {
  const RandomImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RandomImageBloc, RandomImageState>(
      builder: (context, state) {
        // --- Get the current background color, or default ---
        // This pattern allows us to keep the old color while loading
        final (Color glowColor, Brightness brightness) = switch (state) {
          Loaded(:final backgroundColor, :final foregroundBrightness) => (
            backgroundColor,
            foregroundBrightness,
          ),
          Loading(
            previousBackgroundColor: final bgColor,
            previousForegroundBrightness: final bBrightness,
          )
              when bgColor != null && bBrightness != null =>
            (bgColor, bBrightness),
          _ => (const Color(0xFF1C1C1C), Brightness.dark),
        };

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "AURORA",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          // --- Use an AnimatedContainer to smoothly change the gradient ---
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            // --- THIS IS THE SOLID COLOR BACKGROUND ---
            // This matches your screenshot of the red road.
            color: glowColor,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                // --- THIS IS THE LAYOUT FIX ---
                // The Column is no longer inside the AspectRatio
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- 1:1 Aspect Ratio Box ---
                    // This forces its child to be a square.
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            // border: Border.all(
                            //   color: Theme.of(
                            //     context,
                            //   ).colorScheme.onSurface.withValues(alpha: 0.1),
                            //   width: 1,
                            // ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _buildImageWidget(context, state),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- The "Another" Button ---
                    ElevatedButton(
                      onPressed: switch (state) {
                        // Only enable button if not loading
                        Loading() => null,
                        _ => () => context.read<RandomImageBloc>().add(
                          const RandomImageEvent.fetchRequested(),
                        ),
                      },
                      // --- Dynamically style the button ---
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brightness == Brightness.dark
                            ? const Color(0xFFD95A2B) // Aurora Orange
                            : const Color(0xFFF5F5F7), // Aurora White
                        foregroundColor: const Color(
                          0xFF1C1C1C,
                        ), // Aurora Black
                      ),
                      child: switch (state) {
                        Loading() => const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1C1C1C),
                          ),
                        ),
                        _ => const Text("Another"),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Helper widget to decide what to show in the image area
  Widget _buildImageWidget(BuildContext context, RandomImageState state) {
    // --- Use Dart 3 switch for pattern matching ---
    return switch (state) {
      // --- Initial State (also loading) ---
      Initial() => const _LoadingShimmer(key: ValueKey('initial')),

      // --- Loading State ---
      // Show the *previous* image if we have one
      Loading(previousImage: final previousImage) when previousImage != null =>
        CachedNetworkImage(
          key: ValueKey(previousImage.url),
          imageUrl: previousImage.url,
          fit: BoxFit.cover,
        ),
      // Otherwise, show the shimmer
      Loading() => const _LoadingShimmer(key: ValueKey('loading')),

      // --- Error State ---
      Error(:final message) => Padding(
        key: const ValueKey('error'),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),

      // --- Loaded State ---
      Loaded(:final image) => CachedNetworkImage(
        key: ValueKey(image.url),
        // width: 200,
        // height: 200,
        // Key for AnimatedSwitcher
        imageUrl: image.url,
        fit: BoxFit.cover,
        placeholder: (context, url) => const _LoadingShimmer(),
        errorWidget: (context, url, error) => Center(
          child: Icon(
            Icons.broken_image,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            size: 40,
          ),
        ),
      ),
    };
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
