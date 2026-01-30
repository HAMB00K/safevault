import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../providers.dart';

/// Écran d'animation de fermeture du coffre-fort
class VaultLockScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final bool isManualLock;

  const VaultLockScreen({
    super.key,
    required this.onComplete,
    this.isManualLock = false,
  });

  @override
  ConsumerState<VaultLockScreen> createState() => _VaultLockScreenState();
}

class _VaultLockScreenState extends ConsumerState<VaultLockScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_animationComplete) {
        _animationComplete = true;
        // Petit délai avant la transition vers l'écran de login
        Future.delayed(const Duration(milliseconds: 500), () {
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
            // Animation Lottie de fermeture - grande taille
            SizedBox(
              width: animationSize.clamp(200.0, 400.0),
              height: animationSize.clamp(200.0, 400.0),
              child: Lottie.asset(
                'assets/lottie/close.json',
                controller: _controller,
                fit: BoxFit.contain,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                },
              ),
            ),
            const SizedBox(height: 32),
            // Texte
            Text(
              widget.isManualLock 
                  ? 'Coffre-fort verrouillé'
                  : 'Verrouillage automatique',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: _animationComplete ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Text(
                widget.isManualLock
                    ? 'Vos données sont en sécurité'
                    : 'Session expirée par inactivité',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark 
                          ? AppThemeDark.textSecondary 
                          : Colors.black54,
                    ),
              ),
            ),
            const SizedBox(height: 48),
            // Indicateur de chargement pendant la transition
            if (_animationComplete)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppThemeDark.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
