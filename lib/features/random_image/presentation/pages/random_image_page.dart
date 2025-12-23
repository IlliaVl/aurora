import 'dart:async';
import 'dart:ui';
import 'package:aurora/core/di/injection_container.dart';
import 'package:aurora/features/random_image/domain/entities/image_entity.dart';
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
class RandomImageView extends StatefulWidget {
  const RandomImageView({super.key});

  @override
  State<RandomImageView> createState() => _RandomImageViewState();
}

class _RandomImageViewState extends State<RandomImageView> {
  // Using the same duration for both creates a cohesive "scene change" effect.
  static const Duration _animDuration = Duration(milliseconds: 1500);

  // Tracks if the visual transition (AnimatedSwitcher) is still active
  // to keep the loading state on the button.
  bool _isVisualTransitioning = false;
  Timer? _transitionTimer;

  @override
  void dispose() {
    _transitionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RandomImageBloc>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocListener(
      listeners: [
        BlocListener<RandomImageBloc, RandomImageState>(
          listener: (context, state) {
            if (state is Error) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
        BlocListener<RandomImageBloc, RandomImageState>(
          listenWhen: (previous, current) {
            return previous is Loading && current is Loaded;
          },
          listener: (context, state) {
            setState(() {
              _isVisualTransitioning = true;
            });
            _transitionTimer?.cancel();
            _transitionTimer = Timer(_animDuration, () {
              if (mounted) {
                setState(() {
                  _isVisualTransitioning = false;
                });
              }
            });
          },
        ),
      ],
      child: Scaffold(
        // Allow the body to draw behind the app bar
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            "AURORA",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              // --- A11y & Theme: Ensure title contrast ---
              color: isDark ? Colors.white : Colors.black,
            ),
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
              duration: _animDuration,
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: _buildBackgroundImageWidget(context, state, isDark),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        // --- Foreground Image Stack ---
                        // --- A11y: Semantics for the main image content ---
                        child: Semantics(
                          label: "Randomly fetched image from Unsplash",
                          image: true,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 1. Underlay (Previous Image)
                              if (_getPreviousImage(state) case final prev?)
                                Image.memory(
                                  key: ValueKey(
                                    'fg_underlay_${prev.imageBytes.hashCode}',
                                  ),
                                  prev.imageBytes,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                ),

                              // 2. Animated Switcher
                              AnimatedSwitcher(
                                duration: _animDuration,
                                switchInCurve: Curves.easeInOut,
                                switchOutCurve: Curves.easeInOut,
                                child: _buildImageWidget(context, state),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- The "Another" Button ---
                    // --- Theme: Custom style based on mode ---
                    Theme(
                      data: Theme.of(context).copyWith(
                        elevatedButtonTheme: ElevatedButtonThemeData(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(
                                    0xFFD95A2B,
                                  ) // Aurora Orange (Dark Mode)
                                : Colors.black,
                            // Black (Light Mode)
                            foregroundColor: isDark
                                ? Colors.white
                                : const Color(0xFFD95A2B),
                            // Orange Text (Light Mode)
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      child: ElevatedButton(
                        // --- A11y: Descriptive label ---
                        // "Another" is visual text, semantics gives context.
                        onPressed: (_isLoading(state) || _isVisualTransitioning)
                            ? null
                            : () {
                                // Clear Semantics focus to avoid announcing old image?
                                // Standard practice is just to trigger the action.
                                context.read<RandomImageBloc>().add(
                                  const RandomImageEvent.fetchRequested(),
                                );
                              },
                        child: Semantics(
                          label: "Fetch another random image",
                          button: true,
                          enabled:
                              !(_isLoading(state) || _isVisualTransitioning),
                          child: SizedBox(
                            width: 120,
                            height: 24,
                            child: Center(
                              child:
                                  (_isLoading(state) || _isVisualTransitioning)
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        // Ensure spinner matches text color
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFFD95A2B),
                                      ),
                                    )
                                  : const Text("Another"),
                            ),
                          ),
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

  bool _isLoading(RandomImageState state) => state is Loading;

  ImageEntity? _getPreviousImage(RandomImageState state) {
    return switch (state) {
      Loaded(:final previousImage) => previousImage,
      Loading(:final previousImage) => previousImage,
      Error(:final previousImage) => previousImage,
      Initial() => null,
    };
  }

  Widget _buildBackgroundImageWidget(
    BuildContext context,
    RandomImageState state,
    bool isDark,
  ) {
    final ImageEntity? image = switch (state) {
      Loaded(:final image) => image,
      Loading(:final previousImage) => previousImage,
      Error(:final previousImage) => previousImage,
      Initial() => null,
    };

    if (image != null) {
      // --- Theme: Dynamic ColorFilter ---
      // Dark Mode: Darken (for immersion)
      // Light Mode: Lighten (for airy/light feel)
      final colorFilter = isDark
          ? const ColorFilter.mode(Colors.black38, BlendMode.darken)
          : const ColorFilter.mode(Colors.white38, BlendMode.lighten);

      return ImageFiltered(
        key: ValueKey('bg_${image.imageBytes.hashCode}'),
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: ColorFiltered(
          colorFilter: colorFilter,
          child: Image.memory(
            image.imageBytes,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.expand(),
          ),
        ),
      );
    }

    return SizedBox(
      key: const ValueKey('bg_initial'),
      width: double.infinity,
      height: double.infinity,
      // Default background color based on theme
      child: ColoredBox(color: isDark ? Colors.black : Colors.white),
    );
  }

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
        gaplessPlayback: true,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return switch (state) {
      Error() => const _ErrorIcon(key: ValueKey('error')),
      _ => const _LoadingShimmer(key: ValueKey('initial_loading')),
    };
  }
}

class _ErrorIcon extends StatelessWidget {
  const _ErrorIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: isDark ? Colors.white54 : Colors.black54,
          size: 40,
        ),
      ),
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
      child: Container(color: Colors.white),
    );
  }
}
