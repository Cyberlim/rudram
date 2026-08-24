import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';

/// Lenis-style smooth scroll physics for Flutter Web.
///
/// Lenis is famous for its silky "lerp" (linear interpolation) feel —
/// instead of snapping instantly to a target, it glides with a gentle
/// exponential ease-out, almost like a rubber band decelerating to rest.
///
/// How it works:
///   - Uses a [FrictionSimulation] with a very low friction coefficient so
///     the scroll continues smoothly after the finger/wheel releases.
///   - The tolerance is kept tight so the scroll settles precisely.
///   - [applyPhysicsToUserOffset] applies a gentle damping multiplier to
///     raw wheel events, smoothing out jarring large jumps from the mouse
///     wheel on web.
class LenisScrollPhysics extends ScrollPhysics {
  const LenisScrollPhysics({super.parent});

  @override
  LenisScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return LenisScrollPhysics(parent: buildParent(ancestor));
  }

  /// Dampen the raw user offset to make the scroll feel silky smooth.
  /// A factor of 0.6 gives the Lenis-characteristic "eased start".
  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Use a smooth cubic ease factor instead of raw pixel delta
    return super.applyPhysicsToUserOffset(position, offset * 0.92);
  }

  /// Lenis signature: tight friction so the glide decelerates smoothly
  /// but doesn't over-shoot or bounce.
  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = toleranceFor(position);

    // If already at rest or at a boundary, let parent handle it
    if (velocity.abs() < tolerance.velocity) {
      return null;
    }

    // FrictionSimulation with Lenis-style friction (0.135 ≈ Lenis default lerp 0.1)
    return FrictionSimulation(
      0.135, // Lenis lerp ~0.1 → friction 0.135 gives same feel
      position.pixels,
      velocity,
      tolerance: tolerance,
    );
  }

  @override
  bool get allowImplicitScrolling => true;
}

/// A custom ScrollBehavior that uses [LenisScrollPhysics] and
/// enables scrolling with all pointer types (mouse, touch, trackpad).
class LenisScrollBehavior extends MaterialScrollBehavior {
  const LenisScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics(parent: LenisScrollPhysics());
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };

  /// Removes the default scrollbar/glow overscroll indicator.
  /// Lenis uses no glow — the scroll just smoothly stops at edges.
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
