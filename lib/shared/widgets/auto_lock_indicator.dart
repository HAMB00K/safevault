import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auto_lock_service.dart';
import '../../core/theme/app_theme_dark.dart';

/// Widget qui affiche le compteur de verrouillage automatique
class AutoLockIndicator extends ConsumerWidget {
  final bool showLabel;
  final bool compact;

  const AutoLockIndicator({
    super.key,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoLockState = ref.watch(autoLockProvider);

    if (!autoLockState.isActive || autoLockState.isLocked) {
      return const SizedBox.shrink();
    }

    final progress = autoLockState.remainingSeconds / autoLockState.timeoutSeconds;
    final isWarning = autoLockState.remainingSeconds <= 30;
    final isCritical = autoLockState.remainingSeconds <= 10;

    final color = isCritical
        ? Colors.red
        : isWarning
            ? Colors.orange
            : AppThemeDark.primary;

    if (compact) {
      // Version ultra-compacte pour l'AppBar - juste le temps
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            autoLockState.formattedRemaining,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicateur circulaire
          SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Center(
                  child: Icon(
                    isCritical ? Icons.lock : Icons.lock_open,
                    size: 16,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Verrouillage auto',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  autoLockState.formattedRemaining,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Bouton de verrouillage manuel
class ManualLockButton extends ConsumerWidget {
  final VoidCallback onLock;
  final bool showLabel;

  const ManualLockButton({
    super.key,
    required this.onLock,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showLockConfirmation(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppThemeDark.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppThemeDark.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 18,
                color: AppThemeDark.primary,
              ),
              if (showLabel) ...[
                const SizedBox(width: 8),
                Text(
                  'Verrouiller',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppThemeDark.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showLockConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: AppThemeDark.primary),
            SizedBox(width: 12),
            Text('Verrouiller'),
          ],
        ),
        content: const Text(
          'Voulez-vous verrouiller le coffre-fort maintenant ?\n\nVous devrez entrer votre master password pour y accéder à nouveau.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onLock();
            },
            icon: const Icon(Icons.lock, size: 18),
            label: const Text('Verrouiller'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeDark.primary,
            ),
          ),
        ],
      ),
    );
  }
}
