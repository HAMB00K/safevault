import '../constants/app_constants.dart';

enum PasswordStrength { veryWeak, weak, medium, strong, veryStrong }

class PasswordValidator {
  // Calcul de la force du mot de passe
  static PasswordStrength calculateStrength(String password) {
    int score = 0;
    
    if (password.isEmpty) return PasswordStrength.veryWeak;
    
    // Longueur
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;
    if (password.length >= 20) score++;
    
    // Complexité
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    
    // Diversité des caractères
    final uniqueChars = password.split('').toSet().length;
    if (uniqueChars >= password.length * 0.6) score++;
    
    // Score final
    if (score <= 2) return PasswordStrength.veryWeak;
    if (score <= 4) return PasswordStrength.weak;
    if (score <= 6) return PasswordStrength.medium;
    if (score <= 8) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  // Validation du master password
  static bool isValidMasterPassword(String password) {
    if (password.length < SecurityConstants.minPasswordLength) {
      return false;
    }
    
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUppercase && hasLowercase && hasDigit && hasSpecialChar;
  }

  // Message d'erreur pour le master password
  static String? getMasterPasswordError(String password) {
    if (password.isEmpty) {
      return 'Le mot de passe ne peut pas être vide';
    }
    
    if (password.length < SecurityConstants.minPasswordLength) {
      return 'Minimum ${SecurityConstants.minPasswordLength} caractères requis';
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Au moins une majuscule requise';
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Au moins une minuscule requise';
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Au moins un chiffre requis';
    }
    
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Au moins un caractère spécial requis';
    }
    
    return null;
  }

  // Calcul du pourcentage de force (0-100)
  static int getStrengthPercentage(String password) {
    final strength = calculateStrength(password);
    switch (strength) {
      case PasswordStrength.veryWeak:
        return 20;
      case PasswordStrength.weak:
        return 40;
      case PasswordStrength.medium:
        return 60;
      case PasswordStrength.strong:
        return 80;
      case PasswordStrength.veryStrong:
        return 100;
    }
  }

  // Couleur selon la force
  static int getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return 0xFFE63946; // Rouge
      case PasswordStrength.weak:
        return 0xFFFF6B6B; // Rouge clair
      case PasswordStrength.medium:
        return 0xFFFFB703; // Orange
      case PasswordStrength.strong:
        return 0xFF51CF66; // Vert clair
      case PasswordStrength.veryStrong:
        return 0xFF06D6A0; // Vert
    }
  }

  // Texte selon la force
  static String getStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return 'Très faible';
      case PasswordStrength.weak:
        return 'Faible';
      case PasswordStrength.medium:
        return 'Moyen';
      case PasswordStrength.strong:
        return 'Fort';
      case PasswordStrength.veryStrong:
        return 'Très fort';
    }
  }
}
