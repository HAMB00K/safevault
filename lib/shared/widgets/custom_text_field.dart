import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget de fond avec formes géométriques pour dynamiser l'UI
class GeometricBackground extends StatelessWidget {
  final Widget child;
  final Color? primaryColor;
  final Color? secondaryColor;

  const GeometricBackground({
    super.key,
    required this.child,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = primaryColor ?? const Color(0xFF7C3AED);
    final secondary = secondaryColor ?? const Color(0xFFEC4899);

    return Stack(
      children: [
        // Fond de base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F0B1F),
                Color(0xFF1A1333),
              ],
            ),
          ),
        ),

        // Cercle violet en haut à droite
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primary.withOpacity(0.2),
                  primary.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Cercle rose en bas à gauche
        Positioned(
          bottom: -80,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  secondary.withOpacity(0.15),
                  secondary.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Rectangle arrondi au milieu
        Positioned(
          top: 200,
          left: -50,
          child: Transform.rotate(
            angle: -math.pi / 6,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                  colors: [
                    primary.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Rectangle arrondi en bas à droite
        Positioned(
          bottom: 100,
          right: -60,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    secondary.withOpacity(0.1),
                    primary.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Petit cercle d'accent
        Positioned(
          top: 150,
          right: 80,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.1),
            ),
          ),
        ),

        // Contenu par-dessus
        child,
      ],
    );
  }
}

/// Variante avec effet glassmorphism pour les cards
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(borderRadius ?? 24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
