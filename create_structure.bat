@echo off
echo Creation de l'architecture SafeVault...

REM Core - Errors
mkdir lib\core\errors 2>nul
type nul > lib\core\errors\failures.dart

REM Core - Constants
mkdir lib\core\constants 2>nul
type nul > lib\core\constants\app_constants.dart

REM Core - Theme
mkdir lib\core\theme 2>nul
type nul > lib\core\theme\app_theme_dark.dart
type nul > lib\core\theme\app_theme_light.dart

REM Core - Utils
mkdir lib\core\utils 2>nul
type nul > lib\core\utils\encryption_service.dart
type nul > lib\core\utils\password_validator.dart
type nul > lib\core\utils\password_generator.dart

REM Features - Auth - Domain
mkdir lib\features\auth\domain\entities 2>nul
mkdir lib\features\auth\domain\repositories 2>nul
mkdir lib\features\auth\domain\usecases 2>nul
type nul > lib\features\auth\domain\entities\user_entity.dart
type nul > lib\features\auth\domain\repositories\auth_repository.dart
type nul > lib\features\auth\domain\usecases\verify_master_password.dart
type nul > lib\features\auth\domain\usecases\create_master_password.dart
type nul > lib\features\auth\domain\usecases\verify_biometric.dart

REM Features - Auth - Data
mkdir lib\features\auth\data\models 2>nul
mkdir lib\features\auth\data\datasources 2>nul
mkdir lib\features\auth\data\repositories 2>nul
type nul > lib\features\auth\data\models\user_model.dart
type nul > lib\features\auth\data\datasources\auth_local_datasource.dart
type nul > lib\features\auth\data\repositories\auth_repository_impl.dart

REM Features - Auth - Presentation
mkdir lib\features\auth\presentation\providers 2>nul
mkdir lib\features\auth\presentation\screens 2>nul
mkdir lib\features\auth\presentation\widgets 2>nul
type nul > lib\features\auth\presentation\providers\auth_provider.dart
type nul > lib\features\auth\presentation\screens\splash_screen.dart
type nul > lib\features\auth\presentation\screens\onboarding_screen.dart
type nul > lib\features\auth\presentation\screens\setup_master_password_screen.dart
type nul > lib\features\auth\presentation\screens\login_screen.dart
type nul > lib\features\auth\presentation\widgets\password_strength_indicator.dart

REM Features - Vault - Domain
mkdir lib\features\vault\domain\entities 2>nul
mkdir lib\features\vault\domain\repositories 2>nul
mkdir lib\features\vault\domain\usecases 2>nul
type nul > lib\features\vault\domain\entities\password_entity.dart
type nul > lib\features\vault\domain\repositories\vault_repository.dart
type nul > lib\features\vault\domain\usecases\get_all_passwords.dart
type nul > lib\features\vault\domain\usecases\add_password.dart
type nul > lib\features\vault\domain\usecases\update_password.dart
type nul > lib\features\vault\domain\usecases\delete_password.dart
type nul > lib\features\vault\domain\usecases\search_passwords.dart

REM Features - Vault - Data
mkdir lib\features\vault\data\models 2>nul
mkdir lib\features\vault\data\datasources 2>nul
mkdir lib\features\vault\data\repositories 2>nul
type nul > lib\features\vault\data\models\password_model.dart
type nul > lib\features\vault\data\datasources\vault_local_datasource.dart
type nul > lib\features\vault\data\repositories\vault_repository_impl.dart

REM Features - Vault - Presentation
mkdir lib\features\vault\presentation\providers 2>nul
mkdir lib\features\vault\presentation\screens 2>nul
mkdir lib\features\vault\presentation\widgets 2>nul
type nul > lib\features\vault\presentation\providers\vault_provider.dart
type nul > lib\features\vault\presentation\screens\home_screen.dart
type nul > lib\features\vault\presentation\screens\password_detail_screen.dart
type nul > lib\features\vault\presentation\screens\add_edit_password_screen.dart
type nul > lib\features\vault\presentation\widgets\password_list_item.dart
type nul > lib\features\vault\presentation\widgets\category_card.dart

REM Features - Password Generator
mkdir lib\features\password_generator\presentation\screens 2>nul
mkdir lib\features\password_generator\presentation\widgets 2>nul
type nul > lib\features\password_generator\presentation\screens\password_generator_screen.dart
type nul > lib\features\password_generator\presentation\widgets\generator_options.dart

REM Features - Settings
mkdir lib\features\settings\presentation\screens 2>nul
mkdir lib\features\settings\presentation\widgets 2>nul
type nul > lib\features\settings\presentation\screens\settings_screen.dart
type nul > lib\features\settings\presentation\widgets\settings_tile.dart

REM Shared - Widgets
mkdir lib\shared\widgets 2>nul
type nul > lib\shared\widgets\custom_text_field.dart
type nul > lib\shared\widgets\primary_button.dart
type nul > lib\shared\widgets\secure_dialog.dart
type nul > lib\shared\widgets\loading_overlay.dart

REM App Router
type nul > lib\app_router.dart

REM Providers
type nul > lib\providers.dart

echo.
echo ✓ Architecture creee avec succes!
echo ✓ Tous les fichiers sont prets a etre remplis.
echo.
pause