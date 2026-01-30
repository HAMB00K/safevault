import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../shared/widgets/rive_icon.dart';
import '../../../settings/presentation/screens/import_export_screen.dart';
import 'dashboard_screen.dart';
import 'passwords_list_screen.dart';
import 'secure_notes_screen.dart';
import 'temporary_vault_screen.dart';

/// Écran principal avec navigation bottom bar
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final PageController _pageController;

  // Définition des onglets
  static const List<NavItem> _navItems = [
    NavItem(
      label: 'Accueil',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      riveAsset: 'assets/rive/icons.riv',
      riveArtboard: 'HOME',
    ),
    NavItem(
      label: 'Mots de passe',
      icon: Icons.lock_outline,
      activeIcon: Icons.lock_rounded,
      riveAsset: 'assets/rive/icons.riv',
      riveArtboard: 'LOCK',
    ),
    NavItem(
      label: 'Notes',
      icon: Icons.note_alt_outlined,
      activeIcon: Icons.note_alt_rounded,
      riveAsset: 'assets/rive/icons.riv',
      riveArtboard: 'EDIT',
    ),
    NavItem(
      label: 'Temporaire',
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer,
      riveAsset: 'assets/rive/icons.riv',
      riveArtboard: 'TIMER',
    ),
    NavItem(
      label: 'Transfert',
      icon: Icons.import_export_outlined,
      activeIcon: Icons.import_export,
      riveAsset: 'assets/rive/icons.riv',
      riveArtboard: 'REFRESH',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        physics: const NeverScrollableScrollPhysics(), // Désactiver le swipe
        children: const [
          DashboardScreen(),
          PasswordsListScreen(),
          SecureNotesScreen(),
          TemporaryVaultScreen(),
          ImportExportScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1a1625) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _navItems.length,
                (index) => _buildNavItem(index, isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, bool isDark) {
    final item = _navItems[index];
    final isActive = _selectedIndex == index;
    final primaryColor = AppThemeDark.primary;
    final inactiveColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? primaryColor.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône animée
              AnimatedNavIcon(
                icon: item.icon,
                activeIcon: item.activeIcon,
                isActive: isActive,
                size: 26,
                activeColor: primaryColor,
                inactiveColor: inactiveColor,
              ),
              const SizedBox(height: 4),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isActive ? 11 : 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? primaryColor : inactiveColor,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Indicateur actif
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                width: isActive ? 20 : 0,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modèle pour les éléments de navigation
class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String? riveAsset;
  final String? riveArtboard;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.riveAsset,
    this.riveArtboard,
  });
}
