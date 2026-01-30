import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/password_validator.dart';
import '../widgets/password_strength_indicator.dart';
import '../providers/auth_provider.dart';
import 'app_lock_wrapper.dart';
import '../../../vault/presentation/screens/main_shell.dart';

class SetupMasterPasswordScreen extends ConsumerStatefulWidget {
  const SetupMasterPasswordScreen({super.key});

  @override
  ConsumerState<SetupMasterPasswordScreen> createState() => _SetupMasterPasswordScreenState();
}

class _SetupMasterPasswordScreenState extends ConsumerState<SetupMasterPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createMasterPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref
        .read(authProvider.notifier)
        .createMasterPassword(_passwordController.text);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AppLockWrapper(
            key: appLockWrapperKey,
            child: const MainShell(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la création du master password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: Stack(
        children: [
          Positioned(
            top: -height * 0.2,
            right: -width * 0.2,
            child: Container(
              width: width * 0.9,
              height: width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7c183c).withOpacity(0.3),
                    const Color(0xFF7c183c).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -height * 0.15,
            left: -width * 0.25,
            child: Container(
              width: width * 0.6,
              height: width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF4A1830).withOpacity(0.25),
                    const Color(0xFF4A1830).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Créez votre\nMaster Password',
                      style: GoogleFonts.exo2(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                    const SizedBox(height: 16),
                    Text(
                      'Ce mot de passe sera la clé de voûte de votre coffre-fort. Choisissez-le robuste et mémorable.',
                      style: GoogleFonts.exo2(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Master Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      validator: (value) {
                        return PasswordValidator.getMasterPasswordError(value ?? '');
                      },
                      onChanged: (value) => setState(() {}),
                    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideX(),
                    const SizedBox(height: 16),
                    if (_passwordController.text.isNotEmpty)
                      PasswordStrengthIndicator(
                        password: _passwordController.text,
                      ).animate().fadeIn(duration: 400.ms).scale(),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirmer le mot de passe',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _obscureConfirm = !_obscureConfirm);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _createMasterPassword(),
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(),
                    const SizedBox(height: 40),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createMasterPassword,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Créer mon coffre-fort'),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 500.ms).scale(),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Important : Si vous oubliez ce mot de passe, vous perdrez accès à toutes vos données.',
                              style: GoogleFonts.exo2(
                                color: Colors.orange.shade800,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
