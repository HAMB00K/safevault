import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/utils/password_validator.dart';

/// Indicateur animé de la force d'un mot de passe
class AnimatedPasswordStrengthIndicator extends StatefulWidget {
  final String password;
  final bool showLabel;
  final double height;

  const AnimatedPasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showLabel = true,
    this.height = 8,
  });

  @override
  State<AnimatedPasswordStrengthIndicator> createState() =>
      _AnimatedPasswordStrengthIndicatorState();
}

class _AnimatedPasswordStrengthIndicatorState
    extends State<AnimatedPasswordStrengthIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  PasswordStrength _currentStrength = PasswordStrength.veryWeak;
  PasswordStrength _previousStrength = PasswordStrength.veryWeak;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _updateStrength();
  }

  @override
  void didUpdateWidget(AnimatedPasswordStrengthIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.password != widget.password) {
      _updateStrength();
    }
  }

  void _updateStrength() {
    final newStrength = PasswordValidator.calculateStrength(widget.password);
    if (newStrength != _currentStrength) {
      setState(() {
        _previousStrength = _currentStrength;
        _currentStrength = newStrength;
      });
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStrengthColor(PasswordStrength strength) {
    return Color(PasswordValidator.getStrengthColor(strength));
  }

  double _getStrengthProgress(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return 0.2;
      case PasswordStrength.weak:
        return 0.4;
      case PasswordStrength.medium:
        return 0.6;
      case PasswordStrength.strong:
        return 0.8;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strengthText = PasswordValidator.getStrengthText(_currentStrength);
    final strengthColor = _getStrengthColor(_currentStrength);
    final progress = _getStrengthProgress(_currentStrength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barre de progression
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final animatedProgress = Tween<double>(
                begin: _getStrengthProgress(_previousStrength),
                end: progress,
              ).animate(CurvedAnimation(
                parent: _controller,
                curve: Curves.easeInOut,
              ));

              return Stack(
                children: [
                  // Barre de fond animée
                  FractionallySizedBox(
                    widthFactor: animatedProgress.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            strengthColor.withOpacity(0.7),
                            strengthColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(widget.height / 2),
                        boxShadow: [
                          BoxShadow(
                            color: strengthColor.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Effet de brillance
                  if (animatedProgress.value > 0.1)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: FractionallySizedBox(
                        widthFactor: animatedProgress.value,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(widget.height / 2),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),

        // Label avec le texte de force
        if (widget.showLabel) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              // Icône animée
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Icon(
                      _getStrengthIcon(_currentStrength),
                      size: 16,
                      color: strengthColor,
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              
              // Texte de force
              Text(
                'Force: $strengthText',
                style: TextStyle(
                  color: strengthColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              )
                  .animate(target: _controller.isAnimating ? 1 : 0)
                  .shimmer(
                    duration: 600.ms,
                    color: Colors.white.withOpacity(0.3),
                  ),
            ],
          ),
        ],
        
        // Suggestions si mot de passe faible
        if (widget.password.isNotEmpty &&
            (_currentStrength == PasswordStrength.veryWeak ||
                _currentStrength == PasswordStrength.weak)) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getStrengthTip(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2, end: 0),
        ],
      ],
    );
  }

  IconData _getStrengthIcon(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return Icons.error_outline;
      case PasswordStrength.weak:
        return Icons.warning_amber_outlined;
      case PasswordStrength.medium:
        return Icons.info_outline;
      case PasswordStrength.strong:
        return Icons.check_circle_outline;
      case PasswordStrength.veryStrong:
        return Icons.verified_outlined;
    }
  }

  String _getStrengthTip() {
    final password = widget.password;
    
    if (password.length < 12) {
      return 'Utilisez au moins 12 caractères';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Ajoutez des majuscules';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Ajoutez des minuscules';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Ajoutez des chiffres';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Ajoutez des caractères spéciaux';
    }
    
    return 'Améliorez la complexité du mot de passe';
  }
}
