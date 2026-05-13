# 📱 Padel Display - Application Mobile iOS

Application Flutter pour contrôler votre tableau d'affichage de padel via Bluetooth.

## ✨ Fonctionnalités

- 🔵 **Connexion Bluetooth** - Connexion automatique à l'ESP32
- 👥 **Gestion des joueurs** - Enregistrez et gérez vos joueurs
- 🏆 **Contrôle du score** - Gérez le score en temps réel
- 📊 **Historique** - Consultez l'historique de vos matchs
- 💾 **Sauvegarde locale** - Base de données SQLite intégrée

## 🚀 Démarrage Rapide

### Sur Mac (pour compiler pour iPhone)

```bash
# Rendre le script exécutable
chmod +x build_ios.sh

# Lancer le script de build
./build_ios.sh
```

Le script vous guidera à travers toutes les étapes nécessaires.

### Sur Windows

Consultez le fichier [BUILD_IOS.md](../BUILD_IOS.md) pour les options de compilation.

## 📂 Structure du Projet

```
lib/
├── main.dart              # Point d'entrée de l'application
├── models/                # Modèles de données
│   ├── match.dart         # Modèle de match
│   └── player.dart        # Modèle de joueur
├── screens/               # Écrans de l'application
│   ├── player_setup_screen.dart      # Configuration des joueurs
│   ├── match_control_screen.dart     # Contrôle du match
│   └── history_screen.dart           # Historique
└── services/              # Services
    └── ble_service.dart   # Service Bluetooth Low Energy
```

## 🔧 Configuration

### Permissions Bluetooth

Les permissions Bluetooth sont déjà configurées dans `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Cette application utilise Bluetooth pour se connecter au tableau d'affichage Padel</string>
```

### Bundle Identifier

Par défaut: Configuré dans Xcode
Pour changer: Ouvrez `ios/Runner.xcworkspace` dans Xcode

## 📱 Compatibilité

- **iOS**: 12.0 et supérieur
- **iPhone**: Tous les modèles avec Bluetooth 4.0+
- **iPad**: Support complet

## 🛠 Développement

### Installer les dépendances

```bash
flutter pub get
```

### Lancer en mode développement

```bash
# Sur simulateur
flutter run

# Sur iPhone réel
flutter run --release
```

### Tests

```bash
flutter test
```

## 📦 Dépendances Principales

- `flutter_blue_plus: ^1.14.0` - Bluetooth Low Energy
- `provider: ^6.1.1` - Gestion d'état
- `sqflite: ^2.3.0` - Base de données locale
- `google_fonts: ^6.1.0` - Polices Google

## 🐛 Dépannage

### Le Bluetooth ne fonctionne pas
- ⚠️ Le simulateur iOS ne supporte PAS le Bluetooth
- Testez uniquement sur un iPhone réel
- Vérifiez que les permissions sont acceptées

### Erreur de build
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ios
```

## 📖 Documentation

- [Guide de Build iOS](../BUILD_IOS.md) - Instructions détaillées
- [Documentation Flutter](https://docs.flutter.dev)
- [Flutter Blue Plus](https://pub.dev/packages/flutter_blue_plus)

## 🔗 Liens Utiles

- [Wiring du matériel](../WIRING.md)
- [Configuration ESP32](../CONFIG.md)
- [Dépannage général](../TROUBLESHOOTING.md)

---

**Version**: 1.0.0+1  
**Dernière mise à jour**: Mai 2026
