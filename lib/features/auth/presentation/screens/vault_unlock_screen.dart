import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../providers.dart';

/// Écran d'animation d'ouverture du coffre-fort
class VaultUnlockScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const VaultUnlockScreen({
    super.key,
    required this.onComplete,
  });

  @override
  ConsumerState<VaultUnlockScreen> createState() => _VaultUnlockScreenState();
}

class _VaultUnlockScreenState extends ConsumerState<VaultUnlockScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_animationComplete) {
        _animationComplete = true;
        // Petit délai avant la transition
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            widget.onComplete();
          }
        });
      }
    });

    // Démarrer l'animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final size = MediaQuery.of(context).size;
    final animationSize = size.width * 0.8; // 80% de la largeur

    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF1a1625) 
          : const Color(0xFFFAF9F7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation Lottie d'ouverture - grande taille
            SizedBox(
              width: animationSize.clamp(200.0, 400.0),
              height: animationSize.clamp(200.0, 400.0),
              child: Lottie.asset(
                'assets/lottie/open.json',
                controller: _controller,
                fit: BoxFit.contain,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                },
              ),
            ),
            const SizedBox(height: 32),
            // Texte
            AnimatedOpacity(
              opacity: _animationComplete ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 300),
              child: Text(
                'Coffre-fort déverrouillé',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: _animationComplete ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Text(
                'Bienvenue !',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark 
                          ? AppThemeDark.textSecondary 
                          : Colors.black54,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
