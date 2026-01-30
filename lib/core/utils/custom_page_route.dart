import 'package:flutter/material.dart';

/// Route avec transition de slide depuis la droite
class SlideRightRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideRightRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

/// Route avec transition de fade et scale
class FadeScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeScaleRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOutCubic;

            var fadeTween = Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: curve));
            var scaleTween = Tween<double>(begin: 0.8, end: 1.0)
                .chain(CurveTween(curve: curve));

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: ScaleTransition(
                scale: animation.drive(scaleTween),
                child: child,
              ),
            );
          },
        );
}

/// Route avec transition de rotation
class RotationRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  RotationRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOutBack;

            var rotationTween = Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: curve));
            var scaleTween = Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: curve));

            return RotationTransition(
              turns: animation.drive(rotationTween),
              child: ScaleTransition(
                scale: animation.drive(scaleTween),
                child: child,
              ),
            );
          },
        );
}

/// Route avec transition de slide depuis le bas
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

/// Route avec effet de "porte" qui s'ouvre (pour le coffre-fort)
class VaultDoorRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  VaultDoorRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                // Transition en 3 phases
                if (animation.value < 0.3) {
                  // Phase 1: Fade in
                  return Opacity(
                    opacity: animation.value / 0.3,
                    child: child,
                  );
                } else if (animation.value < 0.6) {
                  // Phase 2: Scale et rotation
                  final progress = (animation.value - 0.3) / 0.3;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(progress * 0.3)
                      ..scale(0.9 + (progress * 0.1)),
                    child: child,
                  );
                } else {
                  // Phase 3: Slide final
                  final progress = (animation.value - 0.6) / 0.4;
                  return Transform.translate(
                    offset: Offset(0, (1 - progress) * -20),
                    child: child,
                  );
                }
              },
              child: child,
            );
          },
        );
}

/// Route avec effet de "carte qui se retourne"
class FlipRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final AxisDirection direction;

  FlipRoute({
    required this.page,
    this.direction = AxisDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final isUnder = (animation.value > 0.5);
                final value = isUnder
                    ? animation.value - 1.0
                    : animation.value;
                final tilt = ((value - 0.5).abs() - 0.5) * 0.003;
                
                var transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.001);

                if (direction == AxisDirection.up || direction == AxisDirection.down) {
                  transform.rotateX(value * 3.1416);
                } else {
                  transform.rotateY(value * 3.1416);
                }

                return Transform(
                  transform: transform,
                  alignment: Alignment.center,
                  child: child,
                );
              },
              child: child,
            );
          },
        );
}

/// Helper pour créer des transitions personnalisées facilement
class CustomRoutes {
  /// Navigation avec slide depuis la droite
  static Future<T?> slideRight<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(SlideRightRoute(page: page));
  }

  /// Navigation avec fade et scale
  static Future<T?> fadeScale<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(FadeScaleRoute(page: page));
  }

  /// Navigation avec slide depuis le bas
  static Future<T?> slideUp<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(SlideUpRoute(page: page));
  }

  /// Navigation avec effet porte de coffre
  static Future<T?> vaultDoor<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(VaultDoorRoute(page: page));
  }

  /// Navigation avec flip
  static Future<T?> flip<T>(
    BuildContext context,
    Widget page, {
    AxisDirection direction = AxisDirection.right,
  }) {
    return Navigator.of(context).push<T>(
      FlipRoute(page: page, direction: direction),
    );
  }
}
