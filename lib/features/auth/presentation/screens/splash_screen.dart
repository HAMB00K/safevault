import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../providers/auth_provider.dart';
import 'setup_master_password_screen.dart';
import 'app_lock_wrapper.dart';
import '../../../vault/presentation/screens/main_shell.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _waitForAuth();
  }

  Future<void> _waitForAuth() async {
    // Attendre que l'auth provider soit initialisé
    await ref.read(authProvider.notifier).waitForInitialization();
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  void _onLogoTap() {
    // Relancer l'animation au clic
    _lottieController.reset();
    _lottieController.forward();
  }

  Future<void> _navigateToNext() async {
    // Attendre l'initialisation si pas encore fait
    if (!_isInitialized) {
      await ref.read(authProvider.notifier).waitForInitialization();
    }
    
    if (!mounted) return;
    
    // Vérifier si un master password existe
    final hasMasterPassword = ref.read(authProvider).hasMasterPassword;
    
    if (hasMasterPassword) {
      // Rediriger vers l'AppLockWrapper qui gère tout le flux d'auth
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AppLockWrapper(
            key: appLockWrapperKey,
            child: const MainShell(),
          ),
        ),
      );
    } else {
      // Rediriger vers le setup
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SetupMasterPasswordScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    
    // Calcul des tailles responsives - Logo plus grand
    final logoSize = width * 0.55; // 55% de la largeur
    final titleFontSize = width * 0.11;
    final subtitleFontSize = width * 0.038;
    final buttonFontSize = width * 0.043;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7), // Fond beige clair
      body: Stack(
        children: [
          // Bulle organique en haut à droite
          Positioned(
            top: -height * 0.2,
            right: -width * 0.2,
            child: CustomPaint(
              size: Size(width * 0.9, width * 0.7),
              painter: OrganicBubblePainter(
                color: const Color(0xFF7c183c),
              ),
            ),
          ),
          
          // Bulle organique en haut à gauche
          Positioned(
            top: -height * 0.2,
            left: -width * 0.25,
            child: CustomPaint(
              size: Size(width * 0.6, width * 0.6),
              painter: OrganicBubblePainter(
                color: const Color(0xFF4A1830),
              ),
            ),
          ),
          
          // Petite bulle décorative en bas à gauche
          Positioned(
            bottom: height * 0.1,
            left: -width * 0.15,
            child: Container(
              width: width * 0.45,
              height: width * 0.45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE94B5A).withOpacity(0.15),
                    const Color(0xFFE94B5A).withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Petite bulle décorative en bas à droite
          Positioned(
            bottom: height * 0.15,
            right: -width * 0.1,
            child: Container(
              width: width * 0.35,
              height: width * 0.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF7B6D).withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Contenu principal
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: Column(
                children: [
                  SizedBox(height: height * 0.08),
                  
                  // Logo Lottie animé - centré et agrandi
                  GestureDetector(
                    onTap: _onLogoTap,
                    child: Container(
                      width: logoSize.clamp(180.0, 280.0),
                      height: logoSize.clamp(180.0, 280.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 25,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Lottie.asset(
                            'assets/lottie/animation.json',
                            controller: _lottieController,
                            fit: BoxFit.contain,
                            onLoaded: (composition) {
                              _lottieController.duration = composition.duration;
                              _lottieController.forward();
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(delay: 100.ms, duration: 500.ms),
                  
                  SizedBox(height: height * 0.05),
                  
                  // Titre SafeVault
                  Text(
                    'SafeVault',
                    style: GoogleFonts.exo2(
                      fontSize: titleFontSize.clamp(40.0, 56.0),
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: -1,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),
                  
                  SizedBox(height: height * 0.015),
                  
                  // Sous-titre rose
                  Text(
                    'Vos mots de passe, en sécurité',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.exo2(
                      fontSize: subtitleFontSize.clamp(14.0, 18.0),
                      color: const Color(0xFFE94B5A), // Rose
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 600.ms),
                  
                  const Spacer(),
                  
                  // Bouton Commençons
                  SizedBox(
                    width: double.infinity,
                    height: (height * 0.065).clamp(52.0, 64.0),
                    child: ElevatedButton(
                      onPressed: _isInitialized ? _navigateToNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C1F3A), // Bordeaux
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF5C1F3A).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isInitialized
                          ? Text(
                              'Commençons !',
                              style: GoogleFonts.exo2(
                                fontSize: buttonFontSize.clamp(16.0, 20.0),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            )
                          : SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  SizedBox(height: height * 0.04),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Painter pour la forme organique bordeaux principale
class OrganicShapePainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  
  const OrganicShapePainter({
    required this.primaryColor,
    required this.secondaryColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Créer une forme organique arrondie
    path.moveTo(size.width * 0.3, 0);
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.1,
      size.width * 0.7, size.height * 0.2,
    );
    path.quadraticBezierTo(
      size.width * 0.9, size.height * 0.3,
      size.width, size.height * 0.5,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
    
    // Ajouter une deuxième couche plus foncée
    final darkPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;
    
    final darkPath = Path();
    darkPath.moveTo(size.width * 0.5, 0);
    darkPath.quadraticBezierTo(
      size.width * 0.7, size.height * 0.15,
      size.width * 0.85, size.height * 0.35,
    );
    darkPath.quadraticBezierTo(
      size.width * 0.95, size.height * 0.45,
      size.width, size.height * 0.6,
    );
    darkPath.lineTo(size.width, 0);
    darkPath.close();
    
    canvas.drawPath(darkPath, darkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter pour les bulles organiques dans les coins
class OrganicBubblePainter extends CustomPainter {
  final Color color;
  
  const OrganicBubblePainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Forme organique irrégulière
    path.moveTo(size.width * 0.2, size.height * 0.3);
    path.cubicTo(
      size.width * 0.1, size.height * 0.5,
      size.width * 0.15, size.height * 0.8,
      size.width * 0.4, size.height * 0.9,
    );
    path.cubicTo(
      size.width * 0.6, size.height,
      size.width * 0.85, size.height * 0.85,
      size.width * 0.95, size.height * 0.6,
    );
    path.cubicTo(
      size.width, size.height * 0.4,
      size.width * 0.8, size.height * 0.15,
      size.width * 0.5, size.height * 0.1,
    );
    path.cubicTo(
      size.width * 0.3, size.height * 0.05,
      size.width * 0.25, size.height * 0.2,
      size.width * 0.2, size.height * 0.3,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
