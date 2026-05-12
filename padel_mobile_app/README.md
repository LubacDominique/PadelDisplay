# Padel Mobile App

Application mobile Flutter pour contrôler le tableau d'affichage PadelDisplay via Bluetooth Low Energy (BLE).

## 🚀 Démarrage Rapide

### Prérequis
- Flutter 3.0 ou supérieur
- Un appareil physique Android/iOS avec Bluetooth
- Tableau PadelDisplay avec BLE activé

### Installation des dépendances
```bash
flutter pub get
```

### Lancer l'application
```bash
# Sur un appareil connecté en USB
flutter run

# Lister les appareils disponibles
flutter devices

# Sur un appareil spécifique
flutter run -d <device_id>
```

## 📁 Structure du Projet

```
lib/
├── main.dart                      # Point d'entrée, écran d'accueil
├── services/
│   └── ble_service.dart          # Service de communication Bluetooth
├── models/
│   ├── player.dart               # Modèle de données joueur
│   └── match.dart                # Modèle de données match
└── screens/
    └── match_control_screen.dart # Écran de contrôle du match
```

## 🔌 Connexion au Tableau

1. **Scanner**: Appuyez sur "Rechercher tableau"
2. **Sélectionner**: Choisissez "PadelDisplay" dans la liste
3. **Connecter**: Appuyez sur "Connecter"
4. **Contrôler**: Accédez à l'écran de match

## 📡 Protocole BLE

### Service Score (`0000AA00-...`)
- **Score Update** (`AA01`) - Notifications de mise à jour du score
- **Command** (`AA02`) - Envoi de commandes (P1_ADD, P2_ADD, RESET, etc.)
- **Match Status** (`AA03`) - Statut du match (JSON)
- **Battery Info** (`AA04`) - Informations batterie

### Service Player (`0000BB00-...`)
- **Player 1 Name** (`BB01`) - Nom du joueur 1
- **Player 2 Name** (`BB02`) - Nom du joueur 2

### Commandes disponibles
```dart
await bleService.sendCommand('P1_ADD');      // Ajouter point joueur 1
await bleService.sendCommand('P2_ADD');      // Ajouter point joueur 2
await bleService.sendCommand('P1_REMOVE');   // Retirer point joueur 1
await bleService.sendCommand('P2_REMOVE');   // Retirer point joueur 2
await bleService.sendCommand('RESET');       // Reset complet
await bleService.sendCommand('RESET_GAME');  // Reset jeu actuel
```

## 🎮 Utilisation

### Écran d'Accueil
- Affiche le statut de connexion Bluetooth
- Permet de scanner et se connecter aux tableaux
- Navigation vers l'écran de match une fois connecté

### Écran de Match
- **Score en temps réel**: Affichage des points/jeux/sets
- **Boutons +/-**: Ajouter/retirer des points
- **Reset**: Réinitialiser le jeu ou le match
- **Batterie**: Niveau de batterie du tableau et des eTags
- **Historique**: Liste des derniers points marqués

## 🔧 Développement

### Lancer en mode debug
```bash
flutter run --debug
```

### Analyser le code
```bash
flutter analyze
```

### Lancer les tests
```bash
flutter test
```

### Compiler pour la production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 📱 Permissions

### Android
- `BLUETOOTH` - Accès Bluetooth de base
- `BLUETOOTH_ADMIN` - Administration Bluetooth
- `BLUETOOTH_SCAN` - Scan BLE
- `BLUETOOTH_CONNECT` - Connexion BLE
- `ACCESS_FINE_LOCATION` - Localisation (requis pour BLE sur Android)

### iOS
- `NSBluetoothAlwaysUsageDescription` - Utilisation Bluetooth
- `NSBluetoothPeripheralUsageDescription` - Communication BLE
- `NSLocationWhenInUseUsageDescription` - Localisation

## 🐛 Dépannage

### Bluetooth ne fonctionne pas
1. Vérifier que le Bluetooth est activé sur le téléphone
2. Autoriser les permissions dans les paramètres de l'app
3. **Important**: Tester sur un appareil physique (les émulateurs ne supportent pas BLE)
4. Vérifier que l'ESP32 diffuse correctement

### L'ESP32 n'apparaît pas dans le scan
1. S'assurer que l'ESP32 est allumé et le BLE activé
2. Vérifier que le nom du device est "PadelDisplay"
3. Tester avec une app comme "nRF Connect" pour confirmer que l'ESP32 diffuse
4. Vérifier que les UUIDs correspondent

### Erreurs de compilation
```bash
flutter clean
flutter pub get
flutter run
```

## 📚 Documentation

- [Architecture complète](../MOBILE_APP.md) - Documentation détaillée de l'architecture
- [Guide de démarrage](../MOBILE_APP_QUICKSTART.md) - Guide pas à pas
- [Intégration ESP32](../ESP32_MOBILE_INTEGRATION.cpp) - Code d'intégration ESP32
- [Configuration terminée](../SETUP_COMPLETE.md) - Résumé de la configuration

## 🎯 Fonctionnalités Futures

- [ ] Gestion des joueurs (création, édition, suppression)
- [ ] Historique des matchs avec filtres
- [ ] Statistiques détaillées par joueur
- [ ] Graphiques de performance
- [ ] Export des données (CSV, PDF)
- [ ] Mode multijoueur (tournois)
- [ ] Thèmes personnalisables
- [ ] Support multilingue

## 🤝 Contribution

Pour contribuer au projet:
1. Créer une branche pour votre fonctionnalité
2. Implémenter les changements
3. Tester sur un appareil physique
4. Soumettre une pull request

## 📄 Licence

Voir le fichier [LICENSE](../LICENSE) à la racine du projet.
