import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/password_entity.dart';
import '../../domain/entities/service_logo.dart';
import '../../../../core/theme/app_theme_dark.dart';

class PasswordListItem extends StatelessWidget {
  final PasswordEntity password;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;

  const PasswordListItem({
    super.key,
    required this.password,
    required this.onTap,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final lastUpdate = DateFormat('dd/MM/yyyy').format(password.updatedAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo catégorie
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: password.category.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Image.asset(
                  password.category.iconPath,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Logo service si présent
            if (password.serviceLogo != ServiceLogo.none) ...[
              const SizedBox(width: 6),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: password.serviceLogo.brandColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    password.serviceLogo.icon,
                    size: 20,
                    color: password.serviceLogo.brandColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        title: Text(
          password.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          password.username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onToggleFavorite != null)
              IconButton(
                icon: Icon(
                  password.isFavorite ? Icons.star : Icons.star_border,
                  color: password.isFavorite ? Colors.amber : Colors.grey[600],
                  size: 22,
                ),
                onPressed: onToggleFavorite,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[600],
                ),
                Text(
                  lastUpdate,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
