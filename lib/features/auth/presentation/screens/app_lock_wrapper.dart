import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auto_lock_service.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'vault_lock_screen.dart';
import 'vault_unlock_screen.dart';

/// État de l'écran affiché
enum AppLockState {
  locked,      // Écran de login
  unlocking,   // Animation d'ouverture
  unlocked,    // App principale
  locking,     // Animation de fermeture
}

/// Wrapper qui gère le verrouillage de l'application
class AppLockWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AppLockWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppLockWrapper> createState() => AppLockWrapperState();
}

class AppLockWrapperState extends ConsumerState<AppLockWrapper> with WidgetsBindingObserver {
  AppLockState _currentState = AppLockState.locked;
  bool _isManualLock = false;
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused) {
      // L'app est mise en arrière-plan - sauvegarder le temps
      _pausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      // L'app revient au premier plan
      if (_pausedTime != null && _currentState == AppLockState.unlocked) {
        final elapsed = DateTime.now().difference(_pausedTime!).inSeconds;
        final autoLockState = ref.read(autoLockProvider);
        final newRemaining = autoLockState.remainingSeconds - elapsed;
        
        // Si le temps restant est négatif ou nul, verrouiller
        if (newRemaining <= 0) {
          _triggerLock(isManual: false);
        }
        // Sinon le timer continue normalement (il a continué en background)
      }
      _pausedTime = null;
    }
  }

  /// Appelé après une authentification réussie
  void onAuthSuccess() {
    setState(() {
      _currentState = AppLockState.unlocking;
    });
  }

  /// Appelé à la fin de l'animation de déverrouillage
  void _onUnlockComplete() {
    ref.read(autoLockProvider.notifier).unlock();
    setState(() {
      _currentState = AppLockState.unlocked;
    });
  }

  /// Verrouiller l'application (manuel ou auto)
  void _triggerLock({required bool isManual}) {
    if (_currentState != AppLockState.unlocked) return;
    
    _isManualLock = isManual;
    ref.read(autoLockProvider.notifier).lock();
    ref.read(authProvider.notifier).logout();
    
    setState(() {
      _currentState = AppLockState.locking;
    });
  }

  /// Verrouillage manuel accessible de l'extérieur
  void manualLock() {
    _triggerLock(isManual: true);
  }

  /// Appelé à la fin de l'animation de verrouillage
  void _onLockComplete() {
    setState(() {
      _currentState = AppLockState.locked;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Écouter les changements d'état du verrouillage automatique
    ref.listen<AutoLockState>(autoLockProvider, (previous, next) {
      if (next.isLocked && _currentState == AppLockState.unlocked) {
        _triggerLock(isManual: false);
      }
    });

    switch (_currentState) {
      case AppLockState.locked:
        return LoginScreen(
          onLoginSuccess: onAuthSuccess,
        );
      
      case AppLockState.unlocking:
        return VaultUnlockScreen(
          onComplete: _onUnlockComplete,
        );
      
      case AppLockState.unlocked:
        // Le timer s'écoule sans interruption
        // Il ne se reset que lors du retour du background
        return widget.child;
      
      case AppLockState.locking:
        return VaultLockScreen(
          onComplete: _onLockComplete,
          isManualLock: _isManualLock,
        );
    }
  }
}

/// GlobalKey pour accéder au state depuis n'importe où
final appLockWrapperKey = GlobalKey<AppLockWrapperState>();
