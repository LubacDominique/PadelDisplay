# Guide de Génération de l'Application iPhone

## 📱 Application Padel Display pour iOS

Votre projet Flutter est prêt pour iOS avec:
- ✅ Configuration Bluetooth complète
- ✅ Permissions iOS configurées dans Info.plist
- ✅ Support iPhone et iPad
- ✅ Toutes les dépendances installées

## 🚨 Prérequis

Pour compiler l'application iOS, vous avez besoin de:
- Un Mac avec macOS 12.0 ou supérieur
- Xcode 14.0 ou supérieur (gratuit sur l'App Store)
- CocoaPods installé (`sudo gem install cocoapods`)
- Un compte Apple Developer (gratuit pour tester sur votre appareil)

## 🔧 Options depuis Windows

### Option 1: Utiliser un Mac (Recommandé)
1. Copiez le dossier `padel_mobile_app` sur un Mac
2. Suivez les étapes de compilation ci-dessous

### Option 2: Services Cloud
- **Codemagic** (https://codemagic.io) - Build iOS depuis le cloud
- **GitHub Actions** - CI/CD gratuit avec runners macOS
- **Bitrise** - Plateforme de build mobile

### Option 3: Machine Virtuelle macOS
- Utiliser VMware ou VirtualBox (complexe et non officiel)

## 📦 Étapes de Compilation sur Mac

### 1. Préparation de l'Environnement

```bash
# Vérifier que Flutter est installé
flutter doctor

# Si Flutter n'est pas installé:
# brew install --cask flutter
```

### 2. Configuration du Projet

```bash
# Aller dans le dossier du projet
cd padel_mobile_app

# Installer les dépendances Flutter
flutter pub get

# Installer les dépendances iOS (CocoaPods)
cd ios
pod install
cd ..
```

### 3. Ouvrir dans Xcode

```bash
# Ouvrir le projet dans Xcode
open ios/Runner.xcworkspace
```

Dans Xcode:
1. Sélectionnez "Runner" dans le navigateur de projet
2. Allez dans "Signing & Capabilities"
3. Sélectionnez votre équipe (Team)
4. Changez le Bundle Identifier si nécessaire (ex: com.votreentreprise.padeldisplay)

### 4. Compiler l'Application

#### Pour le Simulateur iOS:

```bash
# Lister les simulateurs disponibles
flutter emulators

# Démarrer un simulateur
flutter emulators --launch apple_ios_simulator

# Compiler et lancer l'app
flutter run
```

#### Pour un iPhone Réel:

```bash
# Connecter votre iPhone via USB
# Activer le "Mode Développeur" sur l'iPhone (Réglages > Confidentialité et sécurité)

# Compiler et installer sur l'appareil
flutter run --release
```

### 5. Générer un Fichier .ipa (pour distribution)

```bash
# Créer un build de release
flutter build ios --release

# Pour TestFlight ou App Store:
flutter build ipa --release
```

Le fichier .ipa sera dans: `build/ios/ipa/padel_mobile_app.ipa`

## 🎨 Personnalisation de l'App

### Changer le Nom de l'Application

Éditez `ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>Votre Nom d'App</string>
```

### Changer l'Icône de l'App

1. Préparez une icône 1024x1024 pixels
2. Utilisez https://appicon.co pour générer toutes les tailles
3. Remplacez les images dans `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Changer le Bundle Identifier

Dans Xcode:
- Runner > General > Bundle Identifier
- Ou éditez `ios/Runner.xcodeproj/project.pbxproj`

## 📋 Configuration Actuelle

Votre application est déjà configurée avec:

### Permissions Bluetooth
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Cette application utilise Bluetooth pour se connecter au tableau d'affichage Padel</string>
```

### Orientations Supportées
- Portrait
- Paysage (gauche et droite)
- iPad: toutes orientations

### Fonctionnalités
- Communication BLE avec l'ESP32
- Gestion des joueurs
- Contrôle du score
- Historique des matchs
- Base de données locale (SQLite)

## 🐛 Dépannage

### Erreur "Pod install"
```bash
cd ios
pod deintegrate
pod install
```

### Erreur de Signature
1. Ouvrez Xcode
2. Sélectionnez votre équipe dans Signing & Capabilities
3. Si nécessaire, créez un certificat de développement gratuit

### Erreur "Flutter not found"
```bash
export PATH="$PATH:`pwd`/flutter/bin"
```

### L'app ne se connecte pas au Bluetooth
1. Vérifiez que les permissions sont acceptées sur l'iPhone
2. Redémarrez le Bluetooth sur l'iPhone
3. Vérifiez que l'ESP32 est allumé et en mode publicité

## 📱 Test sur Simulateur vs iPhone Réel

⚠️ **Important**: Le simulateur iOS ne supporte PAS le Bluetooth!

Pour tester la fonctionnalité Bluetooth, vous DEVEZ utiliser un iPhone réel.

## 🚀 Distribution

### TestFlight (Beta Testing)
1. Créez un compte Apple Developer (99€/an)
2. Configurez App Store Connect
3. Uploadez le .ipa via Xcode ou Transporter
4. Invitez des testeurs beta

### App Store
1. Préparez les captures d'écran
2. Rédigez la description
3. Soumettez pour review via App Store Connect

## 📞 Support

Pour toute question sur la compilation iOS:
- Documentation Flutter iOS: https://docs.flutter.dev/deployment/ios
- Forum Flutter: https://flutter.dev/community

---

**Version de l'App**: 1.0.0+1  
**Dernière mise à jour**: Mai 2026
