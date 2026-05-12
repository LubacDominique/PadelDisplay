# Application Mobile PadelDisplay - Exemples Flutter

Ce dossier contient des exemples de code Flutter pour créer l'application mobile PadelDisplay.

## 📁 Structure

```
mobile_app_examples/
├── lib/
│   ├── models/          # Modèles de données
│   │   ├── player.dart  # Joueur et statistiques
│   │   └── match.dart   # Match, Set, Point
│   ├── services/        # Services
│   │   └── ble_service.dart  # Communication Bluetooth
│   └── screens/         # Écrans UI
│       └── match_control_screen.dart  # Contrôle match
└── README.md
```

## 🚀 Démarrage Rapide

### Prérequis

1. **Flutter SDK** (version 3.0+)
   - [Installation Flutter](https://docs.flutter.dev/get-started/install)
   - Vérifier: `flutter doctor`

2. **Android Studio** ou **Xcode** (selon plateforme cible)

3. **Appareil physique recommandé** (le BLE ne fonctionne pas bien sur émulateurs)

### Création du Projet

```bash
# Créer un nouveau projet Flutter
flutter create padel_mobile_app

# Aller dans le dossier
cd padel_mobile_app

# Copier les fichiers d'exemple
# Copier le contenu de mobile_app_examples/lib/ vers padel_mobile_app/lib/
```

### Installation des Dépendances

Modifier `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # BLE
  flutter_blue_plus: ^1.14.0
  
  # Base de données
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  
  # État
  provider: ^6.1.1
  
  # UI
  google_fonts: ^6.1.0
  
  # Utilitaires
  intl: ^0.18.1
  
  # Permissions
  permission_handler: ^11.1.0
```

Installer:

```bash
flutter pub get
```

### Configuration Android

Modifier `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
    <!-- Permissions Bluetooth -->
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
                     android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    
    <!-- Features -->
    <uses-feature android:name="android.hardware.bluetooth_le" android:required="true"/>
    
    <application ...>
        ...
    </application>
</manifest>
```

Modifier `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34  // Minimum 31 pour BLE
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### Configuration iOS

Modifier `ios/Runner/Info.plist`:

```xml
<dict>
    ...
    <!-- Bluetooth permissions -->
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>Cette app utilise Bluetooth pour se connecter au tableau de score Padel</string>
    
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>Cette app utilise Bluetooth pour se connecter au tableau de score Padel</string>
    
    <key>UIBackgroundModes</key>
    <array>
        <string>bluetooth-central</string>
    </array>
</dict>
```

## 📱 Utilisation des Exemples

### 1. BLE Service

Le service BLE gère toute la communication avec l'ESP32:

```dart
import 'package:provider/provider.dart';
import 'services/ble_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BLEService(),
      child: MyApp(),
    ),
  );
}
```

### 2. Scanner et Connecter

```dart
final bleService = context.read<BLEService>();

// Scanner les appareils
await bleService.startScan();

// Connecter à un appareil
await bleService.connect(device);
```

### 3. Contrôler le Match

```dart
// Ajouter un point
await bleService.addPoint(1);  // Joueur 1
await bleService.addPoint(2);  // Joueur 2

// Réinitialiser
await bleService.resetMatch();
await bleService.resetGame();

// Définir les noms
await bleService.setPlayerNames("Jean", "Marie");
```

### 4. Écouter les Mises à Jour

```dart
bleService.scoreStream.listen((score) {
  print('Score: ${score.player1Points} - ${score.player2Points}');
});

bleService.batteryStream.listen((battery) {
  print('Batterie: ${battery.systemPercent}%');
});
```

## 🎨 Exemple d'Application Complète

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/ble_service.dart';
import 'models/player.dart';
import 'screens/match_control_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BLEService(),
      child: const PadelApp(),
    ),
  );
}

class PadelApp extends StatelessWidget {
  const PadelApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Padel Display',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bleService = context.watch<BLEService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Padel Display'),
        actions: [
          Icon(
            bleService.isConnected 
                ? Icons.bluetooth_connected 
                : Icons.bluetooth_disabled,
            color: bleService.isConnected ? Colors.blue : Colors.red,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!bleService.isConnected) ...[
              const Text('Non connecté au tableau'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: bleService.isScanning
                    ? null
                    : () async {
                        await bleService.startScan();
                        if (bleService.discoveredDevices.isNotEmpty) {
                          await bleService.connect(
                            bleService.discoveredDevices.first
                          );
                        }
                      },
                icon: const Icon(Icons.bluetooth_searching),
                label: Text(
                  bleService.isScanning 
                      ? 'Recherche...' 
                      : 'Rechercher tableau'
                ),
              ),
            ] else ...[
              const Text('Connecté au tableau'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchControlScreen(
                        player1: Player(name: 'Joueur 1'),
                        player2: Player(name: 'Joueur 2'),
                      ),
                    ),
                  );
                },
                child: const Text('Démarrer un match'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

## 🔧 Intégration ESP32

**IMPORTANT:** Avant d'utiliser l'app mobile, vous devez modifier le code ESP32.

Voir le fichier `ESP32_MOBILE_INTEGRATION.cpp` pour les instructions détaillées.

### Résumé des modifications ESP32:

1. Ajouter les services BLE pour mobile
2. Ajouter les callbacks de commandes
3. Implémenter les fonctions de notification
4. Appeler `setupBLEServer()` dans `setup()`
5. Appeler les notifications dans `loop()` et `addPoint()`

## 📊 Protocole BLE

### Services

1. **Score Control** (`0000AA00-...`)
   - Score Update (Notify)
   - Command (Write)
   - Match Status (Notify)
   - Battery Info (Notify)

2. **Player Config** (`0000BB00-...`)
   - Player Names (Read/Write)
   - Match Config (Read/Write)

### Commandes disponibles

- `P1_ADD` - Ajouter point joueur 1
- `P1_REMOVE` - Retirer point joueur 1
- `P2_ADD` - Ajouter point joueur 2
- `P2_REMOVE` - Retirer point joueur 2
- `RESET` - Réinitialiser match
- `RESET_GAME` - Réinitialiser jeu
- `GET_STATUS` - Demander statut complet

## 🧪 Tests

### Test 1: Connexion BLE

```bash
flutter run -d <device>
```

Vérifier:
- ✅ Scan détecte l'ESP32
- ✅ Connexion réussie
- ✅ Indicateur BLE vert

### Test 2: Envoi de Commandes

```dart
await bleService.addPoint(1);
```

Vérifier:
- ✅ LED affiche nouveau score
- ✅ Notification reçue
- ✅ UI mise à jour

### Test 3: Réception de Données

Utiliser les eTags pour marquer un point.

Vérifier:
- ✅ App reçoit notification
- ✅ Score mis à jour automatiquement

## 🐛 Debugging

### Problème: App ne trouve pas l'ESP32

**Solutions:**
1. Vérifier que l'ESP32 est allumé
2. Vérifier permissions Bluetooth dans l'app
3. Vérifier que le serveur BLE est démarré (`setupBLEServer()`)
4. Vérifier les logs Serial de l'ESP32

### Problème: Connexion échoue

**Solutions:**
1. Redémarrer l'ESP32
2. Désactiver/Réactiver Bluetooth du téléphone
3. Vérifier la distance (<10m)
4. Vérifier qu'aucune autre app n'est connectée

### Problème: Pas de notifications

**Solutions:**
1. Vérifier `notifyScoreUpdate()` est appelée
2. Vérifier subscription aux caractéristiques
3. Vérifier logs: "📤 Score envoyé"

## 📚 Ressources

- [Documentation Flutter](https://docs.flutter.dev/)
- [Flutter Blue Plus](https://pub.dev/packages/flutter_blue_plus)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io/)

## 🎯 Prochaines Étapes

1. ✅ Tester les exemples fournis
2. ⬜ Implémenter la base de données SQLite
3. ⬜ Créer l'écran d'historique
4. ⬜ Ajouter les statistiques
5. ⬜ Implémenter le thème sombre
6. ⬜ Ajouter les exports PDF/CSV
7. ⬜ Tests sur iOS
8. ⬜ Publication sur stores

## 📄 Licence

Même licence que le projet PadelDisplay principal.

## 🤝 Contribution

Les contributions sont les bienvenues! Voir le README principal pour les guidelines.
