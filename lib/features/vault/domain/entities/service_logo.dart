import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Enum représentant les logos de services populaires
enum ServiceLogo {
  none,
  // Réseaux sociaux
  facebook,
  instagram,
  twitter,
  linkedin,
  tiktok,
  snapchat,
  pinterest,
  reddit,
  discord,
  telegram,
  whatsapp,
  // Tech & Dev
  google,
  github,
  gitlab,
  microsoft,
  apple,
  amazon,
  slack,
  // Streaming
  netflix,
  spotify,
  youtube,
  twitch,
  // E-commerce
  paypal,
  stripe,
  shopify,
  ebay,
  // Gaming
  steam,
  playstation,
  xbox,
  nintendo,
  epicGames,
  // Cloud & Outils
  dropbox,
  googleDrive,
  oneDrive,
  notion,
  trello,
  figma,
  // Banque
  visa,
  mastercard,
  // Email
  gmail,
  outlook,
  yahoo,
  // Autres
  wordpress,
  airbnb,
  uber,
  other,
}

extension ServiceLogoExtension on ServiceLogo {
  String get displayName {
    switch (this) {
      case ServiceLogo.none:
        return 'Aucun';
      case ServiceLogo.facebook:
        return 'Facebook';
      case ServiceLogo.instagram:
        return 'Instagram';
      case ServiceLogo.twitter:
        return 'X (Twitter)';
      case ServiceLogo.linkedin:
        return 'LinkedIn';
      case ServiceLogo.tiktok:
        return 'TikTok';
      case ServiceLogo.snapchat:
        return 'Snapchat';
      case ServiceLogo.pinterest:
        return 'Pinterest';
      case ServiceLogo.reddit:
        return 'Reddit';
      case ServiceLogo.discord:
        return 'Discord';
      case ServiceLogo.telegram:
        return 'Telegram';
      case ServiceLogo.whatsapp:
        return 'WhatsApp';
      case ServiceLogo.google:
        return 'Google';
      case ServiceLogo.github:
        return 'GitHub';
      case ServiceLogo.gitlab:
        return 'GitLab';
      case ServiceLogo.microsoft:
        return 'Microsoft';
      case ServiceLogo.apple:
        return 'Apple';
      case ServiceLogo.amazon:
        return 'Amazon';
      case ServiceLogo.slack:
        return 'Slack';
      case ServiceLogo.netflix:
        return 'Netflix';
      case ServiceLogo.spotify:
        return 'Spotify';
      case ServiceLogo.youtube:
        return 'YouTube';
      case ServiceLogo.twitch:
        return 'Twitch';
      case ServiceLogo.paypal:
        return 'PayPal';
      case ServiceLogo.stripe:
        return 'Stripe';
      case ServiceLogo.shopify:
        return 'Shopify';
      case ServiceLogo.ebay:
        return 'eBay';
      case ServiceLogo.steam:
        return 'Steam';
      case ServiceLogo.playstation:
        return 'PlayStation';
      case ServiceLogo.xbox:
        return 'Xbox';
      case ServiceLogo.nintendo:
        return 'Nintendo';
      case ServiceLogo.epicGames:
        return 'Epic Games';
      case ServiceLogo.dropbox:
        return 'Dropbox';
      case ServiceLogo.googleDrive:
        return 'Google Drive';
      case ServiceLogo.oneDrive:
        return 'OneDrive';
      case ServiceLogo.notion:
        return 'Notion';
      case ServiceLogo.trello:
        return 'Trello';
      case ServiceLogo.figma:
        return 'Figma';
      case ServiceLogo.visa:
        return 'Visa';
      case ServiceLogo.mastercard:
        return 'Mastercard';
      case ServiceLogo.gmail:
        return 'Gmail';
      case ServiceLogo.outlook:
        return 'Outlook';
      case ServiceLogo.yahoo:
        return 'Yahoo';
      case ServiceLogo.wordpress:
        return 'WordPress';
      case ServiceLogo.airbnb:
        return 'Airbnb';
      case ServiceLogo.uber:
        return 'Uber';
      case ServiceLogo.other:
        return 'Autre';
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceLogo.none:
        return FontAwesomeIcons.globe;
      case ServiceLogo.facebook:
        return FontAwesomeIcons.facebook;
      case ServiceLogo.instagram:
        return FontAwesomeIcons.instagram;
      case ServiceLogo.twitter:
        return FontAwesomeIcons.xTwitter;
      case ServiceLogo.linkedin:
        return FontAwesomeIcons.linkedin;
      case ServiceLogo.tiktok:
        return FontAwesomeIcons.tiktok;
      case ServiceLogo.snapchat:
        return FontAwesomeIcons.snapchat;
      case ServiceLogo.pinterest:
        return FontAwesomeIcons.pinterest;
      case ServiceLogo.reddit:
        return FontAwesomeIcons.reddit;
      case ServiceLogo.discord:
        return FontAwesomeIcons.discord;
      case ServiceLogo.telegram:
        return FontAwesomeIcons.telegram;
      case ServiceLogo.whatsapp:
        return FontAwesomeIcons.whatsapp;
      case ServiceLogo.google:
        return FontAwesomeIcons.google;
      case ServiceLogo.github:
        return FontAwesomeIcons.github;
      case ServiceLogo.gitlab:
        return FontAwesomeIcons.gitlab;
      case ServiceLogo.microsoft:
        return FontAwesomeIcons.microsoft;
      case ServiceLogo.apple:
        return FontAwesomeIcons.apple;
      case ServiceLogo.amazon:
        return FontAwesomeIcons.amazon;
      case ServiceLogo.slack:
        return FontAwesomeIcons.slack;
      case ServiceLogo.netflix:
        return FontAwesomeIcons.n; // Pas d'icône Netflix officielle
      case ServiceLogo.spotify:
        return FontAwesomeIcons.spotify;
      case ServiceLogo.youtube:
        return FontAwesomeIcons.youtube;
      case ServiceLogo.twitch:
        return FontAwesomeIcons.twitch;
      case ServiceLogo.paypal:
        return FontAwesomeIcons.paypal;
      case ServiceLogo.stripe:
        return FontAwesomeIcons.stripe;
      case ServiceLogo.shopify:
        return FontAwesomeIcons.shopify;
      case ServiceLogo.ebay:
        return FontAwesomeIcons.ebay;
      case ServiceLogo.steam:
        return FontAwesomeIcons.steam;
      case ServiceLogo.playstation:
        return FontAwesomeIcons.playstation;
      case ServiceLogo.xbox:
        return FontAwesomeIcons.xbox;
      case ServiceLogo.nintendo:
        return FontAwesomeIcons.gamepad;
      case ServiceLogo.epicGames:
        return FontAwesomeIcons.gamepad;
      case ServiceLogo.dropbox:
        return FontAwesomeIcons.dropbox;
      case ServiceLogo.googleDrive:
        return FontAwesomeIcons.googleDrive;
      case ServiceLogo.oneDrive:
        return FontAwesomeIcons.cloud;
      case ServiceLogo.notion:
        return FontAwesomeIcons.n;
      case ServiceLogo.trello:
        return FontAwesomeIcons.trello;
      case ServiceLogo.figma:
        return FontAwesomeIcons.figma;
      case ServiceLogo.visa:
        return FontAwesomeIcons.ccVisa;
      case ServiceLogo.mastercard:
        return FontAwesomeIcons.ccMastercard;
      case ServiceLogo.gmail:
        return FontAwesomeIcons.google;
      case ServiceLogo.outlook:
        return FontAwesomeIcons.microsoft;
      case ServiceLogo.yahoo:
        return FontAwesomeIcons.yahoo;
      case ServiceLogo.wordpress:
        return FontAwesomeIcons.wordpress;
      case ServiceLogo.airbnb:
        return FontAwesomeIcons.airbnb;
      case ServiceLogo.uber:
        return FontAwesomeIcons.uber;
      case ServiceLogo.other:
        return FontAwesomeIcons.globe;
    }
  }

  Color get brandColor {
    switch (this) {
      case ServiceLogo.none:
        return Colors.grey;
      case ServiceLogo.facebook:
        return const Color(0xFF1877F2);
      case ServiceLogo.instagram:
        return const Color(0xFFE4405F);
      case ServiceLogo.twitter:
        return const Color(0xFF000000);
      case ServiceLogo.linkedin:
        return const Color(0xFF0A66C2);
      case ServiceLogo.tiktok:
        return const Color(0xFF000000);
      case ServiceLogo.snapchat:
        return const Color(0xFFFFFC00);
      case ServiceLogo.pinterest:
        return const Color(0xFFBD081C);
      case ServiceLogo.reddit:
        return const Color(0xFFFF4500);
      case ServiceLogo.discord:
        return const Color(0xFF5865F2);
      case ServiceLogo.telegram:
        return const Color(0xFF26A5E4);
      case ServiceLogo.whatsapp:
        return const Color(0xFF25D366);
      case ServiceLogo.google:
        return const Color(0xFF4285F4);
      case ServiceLogo.github:
        return const Color(0xFF181717);
      case ServiceLogo.gitlab:
        return const Color(0xFFFC6D26);
      case ServiceLogo.microsoft:
        return const Color(0xFF00A4EF);
      case ServiceLogo.apple:
        return const Color(0xFF000000);
      case ServiceLogo.amazon:
        return const Color(0xFFFF9900);
      case ServiceLogo.slack:
        return const Color(0xFF4A154B);
      case ServiceLogo.netflix:
        return const Color(0xFFE50914);
      case ServiceLogo.spotify:
        return const Color(0xFF1DB954);
      case ServiceLogo.youtube:
        return const Color(0xFFFF0000);
      case ServiceLogo.twitch:
        return const Color(0xFF9146FF);
      case ServiceLogo.paypal:
        return const Color(0xFF003087);
      case ServiceLogo.stripe:
        return const Color(0xFF635BFF);
      case ServiceLogo.shopify:
        return const Color(0xFF96BF48);
      case ServiceLogo.ebay:
        return const Color(0xFFE53238);
      case ServiceLogo.steam:
        return const Color(0xFF171A21);
      case ServiceLogo.playstation:
        return const Color(0xFF003791);
      case ServiceLogo.xbox:
        return const Color(0xFF107C10);
      case ServiceLogo.nintendo:
        return const Color(0xFFE60012);
      case ServiceLogo.epicGames:
        return const Color(0xFF313131);
      case ServiceLogo.dropbox:
        return const Color(0xFF0061FF);
      case ServiceLogo.googleDrive:
        return const Color(0xFF4285F4);
      case ServiceLogo.oneDrive:
        return const Color(0xFF0078D4);
      case ServiceLogo.notion:
        return const Color(0xFF000000);
      case ServiceLogo.trello:
        return const Color(0xFF0052CC);
      case ServiceLogo.figma:
        return const Color(0xFFF24E1E);
      case ServiceLogo.visa:
        return const Color(0xFF1A1F71);
      case ServiceLogo.mastercard:
        return const Color(0xFFEB001B);
      case ServiceLogo.gmail:
        return const Color(0xFFEA4335);
      case ServiceLogo.outlook:
        return const Color(0xFF0078D4);
      case ServiceLogo.yahoo:
        return const Color(0xFF6001D2);
      case ServiceLogo.wordpress:
        return const Color(0xFF21759B);
      case ServiceLogo.airbnb:
        return const Color(0xFFFF5A5F);
      case ServiceLogo.uber:
        return const Color(0xFF000000);
      case ServiceLogo.other:
        return Colors.grey;
    }
  }

  /// Retourne un widget avec l'icône stylée
  Widget buildIcon({double size = 24, Color? color}) {
    return FaIcon(
      icon,
      size: size,
      color: color ?? brandColor,
    );
  }

  /// Liste des logos par catégorie pour l'affichage dans le picker
  static List<ServiceLogo> get socialLogos => [
        ServiceLogo.facebook,
        ServiceLogo.instagram,
        ServiceLogo.twitter,
        ServiceLogo.linkedin,
        ServiceLogo.tiktok,
        ServiceLogo.snapchat,
        ServiceLogo.pinterest,
        ServiceLogo.reddit,
        ServiceLogo.discord,
        ServiceLogo.telegram,
        ServiceLogo.whatsapp,
      ];

  static List<ServiceLogo> get techLogos => [
        ServiceLogo.google,
        ServiceLogo.github,
        ServiceLogo.gitlab,
        ServiceLogo.microsoft,
        ServiceLogo.apple,
        ServiceLogo.amazon,
        ServiceLogo.slack,
      ];

  static List<ServiceLogo> get streamingLogos => [
        ServiceLogo.netflix,
        ServiceLogo.spotify,
        ServiceLogo.youtube,
        ServiceLogo.twitch,
      ];

  static List<ServiceLogo> get ecommerceLogos => [
        ServiceLogo.paypal,
        ServiceLogo.stripe,
        ServiceLogo.shopify,
        ServiceLogo.ebay,
      ];

  static List<ServiceLogo> get gamingLogos => [
        ServiceLogo.steam,
        ServiceLogo.playstation,
        ServiceLogo.xbox,
        ServiceLogo.nintendo,
        ServiceLogo.epicGames,
      ];

  static List<ServiceLogo> get cloudLogos => [
        ServiceLogo.dropbox,
        ServiceLogo.googleDrive,
        ServiceLogo.oneDrive,
        ServiceLogo.notion,
        ServiceLogo.trello,
        ServiceLogo.figma,
      ];

  static List<ServiceLogo> get financeLogos => [
        ServiceLogo.visa,
        ServiceLogo.mastercard,
      ];

  static List<ServiceLogo> get emailLogos => [
        ServiceLogo.gmail,
        ServiceLogo.outlook,
        ServiceLogo.yahoo,
      ];

  static List<ServiceLogo> get otherLogos => [
        ServiceLogo.wordpress,
        ServiceLogo.airbnb,
        ServiceLogo.uber,
        ServiceLogo.other,
      ];

  /// Tous les logos sauf 'none'
  static List<ServiceLogo> get allLogos => ServiceLogo.values
      .where((logo) => logo != ServiceLogo.none)
      .toList();
}
