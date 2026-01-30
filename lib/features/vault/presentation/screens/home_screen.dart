import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../domain/entities/password_entity.dart';
import '../widgets/category_card.dart';
import '../widgets/password_list_item.dart';
import '../providers/vault_provider.dart';
import 'add_edit_password_screen.dart';
import 'password_detail_screen.dart';
import '../../../password_generator/presentation/screens/password_generator_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddPassword() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditPasswordScreen(),
      ),
    );
  }

  void _navigateToGenerator() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PasswordGeneratorScreen(),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  Widget _buildCategoryCard({
    required PasswordCategory category,
    required int count,
    required int index,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    
    return InkWell(
      onTap: () => _showCategoryPasswords(category),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark 
              ? AppThemeDark.surface
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.grey.shade800
                : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                category.iconPath,
                width: 45,
                height: 45,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                category.displayName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 200 + (index * 50)))
        .slideX(begin: 0.2, end: 0);
  }

  double _calculatePasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 25;
    if (password.length >= 12) strength += 15;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 15;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 15;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 15;
    if (RegExp(r'[!@#%^&*(),.?":{}|<>]').hasMatch(password)) strength += 15;
    return strength.clamp(0, 100);
  }

  Widget _buildSecurityScoreCard(List<PasswordEntity> passwords) {
    if (passwords.isEmpty) return const SizedBox.shrink();

    double totalStrength = 0;
    int weakCount = 0;
    int strongCount = 0;

    for (final password in passwords) {
      final strength = _calculatePasswordStrength(password.encryptedPassword);
      totalStrength += strength;
      if (strength < 50) weakCount++;
      if (strength >= 75) strongCount++;
    }

    final avgScore = totalStrength / passwords.length;
    final scoreColor = avgScore < 40 ? Colors.red : avgScore < 60 ? Colors.orange : avgScore < 80 ? Colors.blue : Colors.green;
    final scoreLabel = avgScore < 40 ? 'Faible' : avgScore < 60 ? 'Moyen' : avgScore < 80 ? 'Bon' : 'Excellent';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text('Score de sécurité', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: avgScore / 100,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        ),
                      ),
                      Column(
                        children: [
                          Text(avgScore.toStringAsFixed(0), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: scoreColor)),
                          Text(scoreLabel, style: TextStyle(fontSize: 12, color: scoreColor, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Faibles', style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
                          Text(weakCount.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Forts', style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
                          Text(strongCount.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.password, color: Theme.of(context).primaryColor, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
                          Text(passwords.length.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).scale();
  }

  Widget _buildCategoryPieChart(Map<PasswordCategory, int> categoryCounts) {
    final hasData = categoryCounts.values.any((count) => count > 0);
    if (!hasData) return const SizedBox.shrink();

    final total = categoryCounts.values.reduce((a, b) => a + b);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text('Répartition par catégorie', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 35,
                        sections: categoryCounts.entries.where((e) => e.value > 0).map((entry) {
                          final percentage = (entry.value / total * 100);
                          return PieChartSectionData(
                            color: entry.key.color,
                            value: entry.value.toDouble(),
                            title: '${percentage.toStringAsFixed(0)}%',
                            radius: 45,
                            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: categoryCounts.entries.where((e) => e.value > 0).map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(color: entry.key.color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Expanded(child: Text(entry.key.displayName, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis)),
                              Text('${entry.value}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 250.ms).scale();
  }

  Widget _buildStrengthBarChart(List<PasswordEntity> passwords) {
    if (passwords.isEmpty) return const SizedBox.shrink();

    final distribution = {'Faible': 0, 'Moyen': 0, 'Fort': 0, 'Très fort': 0};
    for (final password in passwords) {
      final strength = _calculatePasswordStrength(password.encryptedPassword);
      if (strength < 25) {
        distribution['Faible'] = distribution['Faible']! + 1;
      } else if (strength < 50) {
        distribution['Moyen'] = distribution['Moyen']! + 1;
      } else if (strength < 75) {
        distribution['Fort'] = distribution['Fort']! + 1;
      } else {
        distribution['Très fort'] = distribution['Très fort']! + 1;
      }
    }

    final maxValue = distribution.values.reduce((a, b) => a > b ? a : b).toDouble();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text('Force des mots de passe', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue + 2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = ['Faible', 'Moyen', 'Fort', 'Très fort'];
                          if (value.toInt() >= 0 && value.toInt() < labels.length) {
                            return Padding(padding: const EdgeInsets.only(top: 8), child: Text(labels[value.toInt()], style: const TextStyle(fontSize: 9)));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 25,
                        getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 9)),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: distribution['Faible']!.toDouble(), color: Colors.red, width: 18, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: distribution['Moyen']!.toDouble(), color: Colors.orange, width: 18, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: distribution['Fort']!.toDouble(), color: Colors.blue, width: 18, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: distribution['Très fort']!.toDouble(), color: Colors.green, width: 18, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).scale();
  }

  void _showCategoryPasswords(PasswordCategory category) {
    final categoryPasswords = ref
        .read(passwordsProvider.notifier)
        .getPasswordsByCategory(category);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeDark.surface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Image.asset(
                          category.iconPath,
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${categoryPasswords.length} mot(s) de passe',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // List
              Expanded(
                child: categoryPasswords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              category.iconPath,
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun mot de passe',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: categoryPasswords.length,
                        itemBuilder: (context, index) {
                          final password = categoryPasswords[index];
                          return PasswordListItem(
                            password: password,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PasswordDetailScreen(password: password),
                                ),
                              );
                            },
                            onToggleFavorite: () {
                              ref.read(passwordsProvider.notifier).toggleFavorite(password.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passwordsState = ref.watch(passwordsProvider);
    final passwords = _searchQuery.isEmpty
        ? passwordsState.passwords
        : ref.read(passwordsProvider.notifier).searchPasswords(_searchQuery);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF1a1625) // Fond sombre violet foncé
          : const Color(0xFFFAF9F7), // Fond beige clair
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppThemeDark.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 10),
            const Text('SafeVault'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key),
            onPressed: _navigateToGenerator,
            tooltip: 'Générateur',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
            tooltip: 'Paramètres',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Recharger les données
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          slivers: [
            // Recherche
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ).animate().fadeIn(duration: 400.ms).slideY(),
              ),
            ),

            // Carte résumé
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppThemeDark.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 40,
                                height: 40,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Coffre-fort',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: AppThemeDark.textSecondary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${passwords.length} mots de passe',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppThemeDark.success.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppThemeDark.success,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Sécurisé',
                                    style: TextStyle(
                                      color: AppThemeDark.success,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 100.ms)
                    .slideY(),
              ),
            ),

            // Section Statistiques
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Text(
                  'Statistiques',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 150.ms),
            ),

            // Graphiques
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildSecurityScoreCard(passwords),
                    const SizedBox(height: 16),
                    _buildCategoryPieChart(
                      Map.fromEntries(
                        PasswordCategory.values.map((cat) => MapEntry(
                              cat,
                              ref.read(passwordsProvider.notifier).getCategoryCount(cat),
                            )),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStrengthBarChart(passwords),
                  ],
                ),
              ),
            ),

            // Catégories - Liste verticale
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Text(
                      'Catégories',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${PasswordCategory.values.length} types',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 150.ms),
            ),

            // Liste des catégories
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = PasswordCategory.values[index];
                    final count = ref
                        .read(passwordsProvider.notifier)
                        .getCategoryCount(category);
                    
                    return _buildCategoryCard(
                      category: category,
                      count: count,
                      index: index,
                    );
                  },
                  childCount: PasswordCategory.values.length,
                ),
              ),
            ),

            // Liste des mots de passe
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Récents',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),

            // Affichage quand vide
            if (passwords.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_open_rounded,
                        size: 80,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun mot de passe',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajoutez votre premier mot de passe',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final password = passwords[index];
                    return Dismissible(
                      key: Key(password.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        ref
                            .read(passwordsProvider.notifier)
                            .deletePassword(password.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${password.title} supprimé'),
                          ),
                        );
                      },
                      child: PasswordListItem(
                        password: password,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PasswordDetailScreen(password: password),
                            ),
                          );
                        },
                        onToggleFavorite: () {
                          ref.read(passwordsProvider.notifier).toggleFavorite(password.id);
                        },
                      )
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: 100 * index))
                          .slideX(),
                    );
                  },
                  childCount: passwords.length,
                ),
              ),

            // Espacement pour le FAB
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddPassword,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ).animate().fadeIn(duration: 600.ms, delay: 500.ms).scale(),
    );
  }
}
