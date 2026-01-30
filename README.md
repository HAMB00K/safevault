# SafeVault Password Manager

Gestionnaire de mots de passe sécurisé avec Flutter.

##  Fonctionnalités
- Chiffrement AES-256-GCM
- Authentification biométrique
- Générateur de mots de passe
- Dashboard avec graphiques
- Auto-lock 120s

##  Technos utilisées
- Flutter 3.10+ + Riverpod
- flutter_secure_storage + SQLCipher
- Clean Architecture

##  Écrans principaux
- Setup/Login
- Dashboard
- Liste des mots de passe
- Générateur
- Settings

##  Sécurité
- Master password avec PBKDF2
- Min 12 caractères
- Max 5 tentatives

##  Lancement
```bash
flutter pub get && flutter run
