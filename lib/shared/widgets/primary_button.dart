import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Widget de fond avec formes organiques bordeaux
class OrganicBackground extends StatelessWidget {
  final Widget child;
  final Color? organicColor;
  final Color? backgroundColor;

  const OrganicBackground({
    super.key,
    required this.child,
    this.organicColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final organic = organicColor ?? const Color(0xFF5C1F3A);
    final bg = backgroundColor ?? const Color(0xFFFAF9F7);

    return Stack(
      children: [
        // Fond de base
        Container(color: bg),

        // Forme organique principale en haut à gauche
        Positioned(
          top: -100,
          left: -50,
          child: CustomPaint(
            size: const Size(300, 250),
            painter: OrganicShapePainter(color: organic),
          ),
        ),

        // Forme organique en haut à droite
        Positioned(
          top: -80,
          right: -80,
          child: CustomPaint(
            size: const Size(250, 200),
            painter: OrganicShapePainter(
              color: organic.withOpacity(0.8),
              variation: 1,
            ),
          ),
        ),

        // Forme organique en bas (optionnelle)
        Positioned(
          bottom: -60,
          right: -100,
          child: CustomPaint(
            size: const Size(280, 220),
            painter: OrganicShapePainter(
              color: const Color(0xFFE94B5A).withOpacity(0.6),
              variation: 2,
            ),
          ),
        ),

        // Contenu par-dessus
        child,
      ],
    );
  }
}

/// Painter pour dessiner les formes organiques
class OrganicShapePainter extends CustomPainter {
  final Color color;
  final int variation;

  OrganicShapePainter({
    required this.color,
    this.variation = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Différentes variations de formes organiques
    switch (variation) {
      case 1:
        // Forme organique version 2
        path.moveTo(size.width * 0.3, 0);
        path.cubicTo(
          size.width * 0.6, size.height * 0.1,
          size.width * 0.8, size.height * 0.3,
          size.width, size.height * 0.5,
        );
        path.lineTo(size.width, 0);
        path.close();
        break;
      case 2:
        // Forme organique version 3 (rose)
        path.moveTo(size.width, size.height * 0.4);
        path.cubicTo(
          size.width * 0.7, size.height * 0.3,
          size.width * 0.5, size.height * 0.6,
          size.width * 0.2, size.height,
        );
        path.lineTo(size.width, size.height);
        path.close();
        break;
      default:
        // Forme organique par défaut
        path.moveTo(0, size.height * 0.3);
        path.cubicTo(
          size.width * 0.2, size.height * 0.1,
          size.width * 0.4, size.height * 0.2,
          size.width * 0.6, 0,
        );
        path.lineTo(0, 0);
        path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
