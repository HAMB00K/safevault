import 'package:flutter/material.dart';
import '../../../../core/utils/password_validator.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final strength = PasswordValidator.calculateStrength(password);
    final percentage = PasswordValidator.getStrengthPercentage(password);
    final color = Color(PasswordValidator.getStrengthColor(strength));
    final text = PasswordValidator.getStrengthText(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _getAdvice(strength),
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getAdvice(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return 'Ajoutez des chiffres, majuscules et caractères spéciaux';
      case PasswordStrength.weak:
        return 'Augmentez la longueur et la complexité';
      case PasswordStrength.medium:
        return 'Presque parfait ! Ajoutez quelques caractères';
      case PasswordStrength.strong:
        return 'Excellent mot de passe !';
      case PasswordStrength.veryStrong:
        return 'Parfait ! Votre mot de passe est très sécurisé !';
    }
  }
}
