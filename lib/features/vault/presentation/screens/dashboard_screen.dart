import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../providers.dart';
import '../../../../shared/widgets/auto_lock_indicator.dart';
import '../../domain/entities/password_entity.dart';
import '../providers/vault_provider.dart';
import '../../../auth/presentation/screens/app_lock_wrapper.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../password_generator/presentation/screens/password_generator_screen.dart';
import 'add_edit_password_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordsState = ref.watch(passwordsProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final passwords = passwordsState.passwords;

    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF1a1625) 
          : const Color(0xFFFAF9F7),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              child: Image.asset(
                'assets/images/logo.png',
                width: 56,
                height: 56,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'SafeVault',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          // Compteur de verrouillage compact
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: AutoLockIndicator(compact: true),
          ),
          // Bouton de verrouillage manuel
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Verrouiller',
            onPressed: () {
              appLockWrapperKey.currentState?.manualLock();
            },
          ),
          IconButton(
            icon: const Icon(Icons.password),
            tooltip: 'Générateur',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PasswordGeneratorScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditPasswordScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau'),
        backgroundColor: AppThemeDark.primary,
      ).animate().scale(delay: 500.ms, duration: 300.ms),
      body: passwordsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(passwordsProvider.notifier).loadPasswords(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Widget 1: Score de sécurité
                    _buildSecurityScoreCard(context, passwords, isDark)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.2),
                    
                    const SizedBox(height: 16),

                    // Widget 2: Distribution par catégorie (Pie Chart)
                    _buildCategoryDistributionCard(context, passwords, isDark)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms)
                        .slideY(begin: 0.2),

                    const SizedBox(height: 16),

                    // Widget 3: Force des mots de passe (Bar Chart)
                    _buildPasswordStrengthCard(context, passwords, isDark)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.2),

                    const SizedBox(height: 16),

                    // Activité récente
                    _buildRecentActivityCard(context, passwords, isDark)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 300.ms)
                        .slideY(begin: 0.2),

                    const SizedBox(height: 100), // Espace pour la navbar
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSecurityScoreCard(
    BuildContext context,
    List<PasswordEntity> passwords,
    bool isDark,
  ) {
    final score = _calculateSecurityScore(passwords);
    final color = _getScoreColor(score);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? AppThemeDark.surface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.shield, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Score de sécurité',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Jauge circulaire
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Détails
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildScoreDetail(
                        'Total mots de passe',
                        '${passwords.length}',
                        Icons.key,
                      ),
                      const SizedBox(height: 8),
                      _buildScoreDetail(
                        'Favoris',
                        '${passwords.where((p) => p.isFavorite).length}',
                        Icons.star,
                      ),
                      const SizedBox(height: 8),
                      _buildScoreDetail(
                        'Catégories utilisées',
                        '${_getUsedCategories(passwords)}',
                        Icons.category,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCategoryDistributionCard(
    BuildContext context,
    List<PasswordEntity> passwords,
    bool isDark,
  ) {
    final categoryData = _getCategoryData(passwords);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? AppThemeDark.surface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: AppThemeDark.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Répartition par catégorie',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: passwords.isEmpty
                  ? const Center(child: Text('Aucune donnée'))
                  : Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: categoryData,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: PasswordCategory.values
                              .where((c) => passwords.any((p) => p.category == c))
                              .map((category) {
                            final count = passwords
                                .where((p) => p.category == category)
                                .length;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: category.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Image.asset(
                                    category.iconPath,
                                    width: 14,
                                    height: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '${category.displayName} ($count)',
                                      style: const TextStyle(fontSize: 11),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthCard(
    BuildContext context,
    List<PasswordEntity> passwords,
    bool isDark,
  ) {
    final strengthData = _getStrengthData(passwords);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? AppThemeDark.surface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Force des mots de passe',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: passwords.isEmpty
                  ? const Center(child: Text('Aucune donnée'))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: passwords.length.toDouble() + 1,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const titles = ['Faible', 'Moyen', 'Fort'];
                                if (value.toInt() < titles.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      titles[value.toInt()],
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        barGroups: strengthData,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard(
    BuildContext context,
    List<PasswordEntity> passwords,
    bool isDark,
  ) {
    final recentPasswords = passwords
        .where((p) => !p.isTemporary)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final recent = recentPasswords.take(3).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? AppThemeDark.surface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Activité récente',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recent.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Aucune activité récente'),
                ),
              )
            else
              ...recent.map((password) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: password.category.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            password.category.iconPath,
                            width: 28,
                            height: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                password.title,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                password.username,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatDate(password.updatedAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  // Helpers
  int _calculateSecurityScore(List<PasswordEntity> passwords) {
    if (passwords.isEmpty) return 0;

    int score = 0;
    for (final pwd in passwords) {
      final length = pwd.encryptedPassword.length;
      if (length >= 16) {
        score += 100;
      } else if (length >= 12) {
        score += 75;
      } else if (length >= 8) {
        score += 50;
      } else {
        score += 25;
      }
    }
    return (score / passwords.length).round();
  }

  Color _getScoreColor(int score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  int _getUsedCategories(List<PasswordEntity> passwords) {
    return passwords.map((p) => p.category).toSet().length;
  }

  List<PieChartSectionData> _getCategoryData(List<PasswordEntity> passwords) {
    final Map<PasswordCategory, int> counts = {};
    for (final pwd in passwords) {
      counts[pwd.category] = (counts[pwd.category] ?? 0) + 1;
    }

    return counts.entries.map((entry) {
      final percentage = (entry.value / passwords.length * 100).round();
      return PieChartSectionData(
        color: entry.key.color,
        value: entry.value.toDouble(),
        title: '$percentage%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _getStrengthData(List<PasswordEntity> passwords) {
    int weak = 0, medium = 0, strong = 0;

    for (final pwd in passwords) {
      final length = pwd.encryptedPassword.length;
      if (length >= 16) {
        strong++;
      } else if (length >= 10) {
        medium++;
      } else {
        weak++;
      }
    }

    return [
      BarChartGroupData(x: 0, barRods: [
        BarChartRodData(
          toY: weak.toDouble(),
          color: Colors.red,
          width: 30,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ]),
      BarChartGroupData(x: 1, barRods: [
        BarChartRodData(
          toY: medium.toDouble(),
          color: Colors.orange,
          width: 30,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ]),
      BarChartGroupData(x: 2, barRods: [
        BarChartRodData(
          toY: strong.toDouble(),
          color: Colors.green,
          width: 30,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ]),
    ];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes}min';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays}j';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
