import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget d'animation pour l'ouverture du coffre-fort
class VaultUnlockAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final Duration duration;

  const VaultUnlockAnimation({
    super.key,
    this.onComplete,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<VaultUnlockAnimation> createState() => _VaultUnlockAnimationState();
}

class _VaultUnlockAnimationState extends State<VaultUnlockAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _doorRotation;
  late Animation<double> _lockScale;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Animation de rotation de la porte du coffre
    _doorRotation = Tween<double>(
      begin: 0.0,
      end: -math.pi / 2.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOutBack),
    ));

    // Animation d'échelle du cadenas
    _lockScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 70,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    // Animation de lueur
    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Lueur de fond
            Opacity(
              opacity: _glowOpacity.value,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7C183C).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Coffre-fort
            SizedBox(
              width: 150,
              height: 150,
              child: CustomPaint(
                painter: VaultDoorPainter(
                  rotation: _doorRotation.value,
                  lockScale: _lockScale.value,
                ),
              ),
            ),

            // Particules de succès
            if (_controller.value > 0.5)
              ...List.generate(8, (index) {
                final angle = (index * math.pi * 2) / 8;
                final distance = 80 * (_controller.value - 0.5) * 2;
                return Positioned(
                  left: 75 + math.cos(angle) * distance,
                  top: 75 + math.sin(angle) * distance,
                  child: Opacity(
                    opacity: 1.0 - ((_controller.value - 0.5) * 2),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF51CF66),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

class VaultDoorPainter extends CustomPainter {
  final double rotation;
  final double lockScale;

  VaultDoorPainter({
    required this.rotation,
    required this.lockScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Sauvegarder l'état du canvas
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Dessiner la porte du coffre
    canvas.save();
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    // Corps du coffre (cercle)
    final bodyPaint = Paint()
      ..color = const Color(0xFF460E2B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bodyPaint);

    // Bordure
    final borderPaint = Paint()
      ..color = const Color(0xFF7C183C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, borderPaint);

    // Lignes de la porte
    final linePaint = Paint()
      ..color = const Color(0xFF7C183C).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final startRadius = radius * 0.3;
      final endRadius = radius * 0.8;
      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * startRadius,
          center.dy + math.sin(angle) * startRadius,
        ),
        Offset(
          center.dx + math.cos(angle) * endRadius,
          center.dy + math.sin(angle) * endRadius,
        ),
        linePaint,
      );
    }

    canvas.restore();

    // Dessiner le cadenas (si visible)
    if (lockScale > 0) {
      canvas.save();
      canvas.scale(lockScale);

      // Corps du cadenas
      final lockBodyPaint = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.fill;
      
      final lockRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, 10),
          width: 30,
          height: 25,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(lockRect, lockBodyPaint);

      // Anse du cadenas
      final shacklePaint = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      
      final shacklePath = Path()
        ..moveTo(-10, 5)
        ..quadraticBezierTo(-10, -15, 0, -15)
        ..quadraticBezierTo(10, -15, 10, 5);
      
      canvas.drawPath(shacklePath, shacklePaint);

      // Trou de serrure
      final keyholePaint = Paint()
        ..color = const Color(0xFF460E2B)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(0, 8), 3, keyholePaint);
      canvas.drawRect(
        const Rect.fromLTWH(-1.5, 8, 3, 8),
        keyholePaint,
      );

      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(VaultDoorPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.lockScale != lockScale;
  }
}
