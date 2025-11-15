import 'dart:ui';
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
    // We get the image URL from the state
    final imageUrl = switch (context.watch<RandomImageBloc>().state) {
      Loaded(:final image) => image.url,
      Loading(previousImage: final pImage) when pImage != null => pImage.url,
      _ => null,
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- LAYER 1: The Blurred Background Image ---
          if (imageUrl != null)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                // Fade in the blur
                fadeInDuration: const Duration(milliseconds: 700),
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
                  // --- This is the "Not Squared" fix ---
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
                    onPressed: switch (context.watch<RandomImageBloc>().state) {
                      // Only enable button if not loading
                      Loading() => null,
                      _ => () => context.read<RandomImageBloc>().add(
                        const RandomImageEvent.fetchRequested(),
                      ),
                    },
                    // We use the button's theme from main.dart
                    child: SizedBox(
                      width: 120,
                      height: 24,
                      child: Center(
                        child: switch (context.watch<RandomImageBloc>().state) {
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
        // Key for AnimatedSwitcher
        imageUrl: image.url,
        fit: BoxFit.cover,
        placeholder: (context, url) => const _LoadingShimmer(),
        errorWidget: (context, url, error) => Center(
          child: Icon(
            Icons.broken_image,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
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
