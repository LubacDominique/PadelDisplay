# Guide Rapide - Application Mobile PadelDisplay

## 📱 Vue d'Ensemble

Application mobile **Android/iOS** pour contrôler et analyser les matchs de Padel affichés sur le système PadelDisplay ESP32.

## ✨ Fonctionnalités

- ✅ **Connexion Bluetooth** avec l'ESP32
- ✅ **Contrôle du match** en temps réel
- ✅ **Configuration des joueurs** (nom, photo)
- ✅ **Historique des matchs** avec détails
- ✅ **Statistiques détaillées** par joueur
- ✅ **Surveillance batterie** (ESP32 + eTags)

## 🛠️ Technologies

**Recommandé: Flutter**
- Performance native
- UI cohérente cross-platform
- Excellente gestion BLE
- Une seule codebase

**Alternative: React Native**
- Écosystème JavaScript
- Large communauté

## 📂 Fichiers Créés

```
PadelDisplay/
├── MOBILE_APP.md                    # 📖 Documentation complète
├── ESP32_MOBILE_INTEGRATION.cpp     # 🔧 Code ESP32 à intégrer
└── mobile_app_examples/             # 📱 Exemples Flutter
    ├── README.md                    # Guide d'utilisation
    └── lib/
        ├── services/
        │   └── ble_service.dart     # Service Bluetooth
        ├── models/
        │   ├── player.dart          # Modèle Joueur
        │   └── match.dart           # Modèle Match
        └── screens/
            └── match_control_screen.dart  # Écran contrôle
```

## 🚀 Démarrage Rapide (5 minutes)

### 1. Installer Flutter

```bash
# Windows
# Télécharger: https://docs.flutter.dev/get-started/install/windows

# Vérifier l'installation
flutter doctor
```

### 2. Créer le Projet

```bash
# Créer nouveau projet
flutter create padel_mobile_app
cd padel_mobile_app

# Copier les exemples
# Copier le contenu de mobile_app_examples/lib/ vers lib/
```

### 3. Ajouter les Dépendances

Dans `pubspec.yaml`:

```yaml
dependencies:
  flutter_blue_plus: ^1.14.0
  provider: ^6.1.1
  sqflite: ^2.3.0
  path_provider: ^2.1.1
```

```bash
flutter pub get
```

### 4. Modifier l'ESP32

✅ **TERMINÉ** - Le code ESP32 a été modifié avec succès:

1. ✅ Includes ajoutés (`NimBLEServer.h`, `NimBLEService.h`, `NimBLECharacteristic.h`)
2. ✅ UUIDs ajoutés (Service Score `0000AA00-...`, Service Player `0000BB00-...`)
3. ✅ Callbacks ajoutés (`MobileServerCallbacks`, `CommandCallbacks`, `PlayerNamesCallbacks`)
4. ✅ Fonction `setupBLEServer()` ajoutée et appelée dans `initBLE()`
5. ✅ Notifications ajoutées dans `addPoint()` et `loop()`

**Résultat de la compilation:**
```
RAM:   [===       ]  31.5% (used 103316 bytes from 327680 bytes)
Flash: [====      ]  35.8% (used 1127337 bytes from 3145728 bytes)
✅ SUCCESS - Compilation terminée
```

**Prochaine étape:** Téléverser le code vers l'ESP32
```powershell
pio run --target upload
```

### 5. Tester

```bash
# Téléverser le code ESP32 modifié
# (via PlatformIO)

# Lancer l'app mobile
flutter run
```

## 🔌 Communication BLE

### De l'App vers l'ESP32 (Commandes)

```dart
bleService.addPoint(1);        // Ajouter point J1
bleService.addPoint(2);        // Ajouter point J2
bleService.resetMatch();       // Réinitialiser match
bleService.setPlayerNames('Jean', 'Marie');
```

### De l'ESP32 vers l'App (Notifications)

```dart
// Écouter les scores
bleService.scoreStream.listen((score) {
  print('${score.player1Points} - ${score.player2Points}');
});

// Écouter les batteries
bleService.batteryStream.listen((battery) {
  print('Batterie: ${battery.systemPercent}%');
});
```

## 📊 Architecture Données

### Base de Données SQLite

```sql
-- Tables principales
players           # Joueurs
matches           # Matchs
match_sets        # Détails des sets
match_points      # Historique point par point
player_statistics # Statistiques calculées
```

### Flux de Données

```
┌─────────┐    BLE     ┌─────────┐   SQLite   ┌──────────┐
│  ESP32  │◄──────────►│   App   │───────────►│ Database │
└─────────┘            └─────────┘            └──────────┘
     │                      │
     ▼                      ▼
  LED Panel            UI Display
```

## 🎨 Écrans Principaux

### 1. Home - Connexion BLE
- Scan des appareils
- Liste des ESP32 disponibles
- Connexion/Déconnexion

### 2. Match Control - Contrôle en Direct
- Scores temps réel
- Boutons +/- points
- Chronomètre
- Indicateurs batterie
- Historique points

### 3. Players - Gestion Joueurs
- Liste joueurs
- Ajout/Modification/Suppression
- Photo profil
- Statistiques de base

### 4. History - Historique Matchs
- Liste chronologique
- Filtres (date, joueur)
- Détails complets
- Export PDF/CSV

### 5. Statistics - Statistiques
- Vue d'ensemble
- Graphiques d'évolution
- Head-to-Head
- Tendances

## 🔧 Code ESP32 - Résumé

### Setup (une seule fois)

```cpp
void setup() {
    // ... code existant ...
    
    NimBLEDevice::init("PadelDisplay");
    
    // ✅ AJOUTER:
    setupBLEServer();  // Pour app mobile
    
    // ... reste du code ...
}
```

### Loop (périodique)

```cpp
void loop() {
    // ... code existant ...
    
    // ✅ AJOUTER:
    if (mobileConnected && (millis() - lastMobileNotify > 1000)) {
        notifyBatteryInfo();
        notifyMatchStatus();
        lastMobileNotify = millis();
    }
}
```

### AddPoint (à chaque point)

```cpp
void addPoint(int playerNum) {
    // ... code existant de gestion points ...
    
    displayScore();
    
    // ✅ AJOUTER:
    notifyScoreUpdate();
    notifyMatchStatus();
}
```

## 🧪 Checklist de Test

### Phase 1: Connexion
- [ ] App détecte l'ESP32
- [ ] Connexion réussie
- [ ] Indicateur BLE actif
- [ ] Logs Serial ESP32 OK

### Phase 2: Envoi Commandes
- [ ] Bouton +1 J1 fonctionne
- [ ] Bouton +1 J2 fonctionne
- [ ] LED affiche bon score
- [ ] Reset fonctionne

### Phase 3: Réception Données
- [ ] eTags incrémentent score
- [ ] App reçoit notification
- [ ] UI se met à jour
- [ ] Batterie affichée

### Phase 4: Base de Données
- [ ] Match sauvegardé
- [ ] Historique visible
- [ ] Statistiques calculées

## 🐛 Résolution Problèmes

### Problème: "App ne trouve pas l'ESP32"

**Solution:**
1. Vérifier ESP32 allumé
2. Activer Bluetooth sur téléphone
3. Permissions Bluetooth accordées
4. Distance <10m

### Problème: "Connexion échoue"

**Solution:**
1. Redémarrer ESP32
2. Redémarrer app mobile
3. Vérifier `setupBLEServer()` appelé
4. Vérifier logs Serial

### Problème: "Pas de notifications"

**Solution:**
1. Vérifier `notifyScoreUpdate()` appelé
2. Vérifier `mobileConnected == true`
3. Vérifier logs "📤 Score envoyé"

## 📈 Roadmap

### Phase 1: MVP (2-3 semaines)
- [x] Architecture documentée
- [x] Code exemple Flutter
- [x] Code exemple ESP32
- [ ] App mobile fonctionnelle basique
- [ ] Connexion BLE stable
- [ ] Contrôle match simple

### Phase 2: Fonctionnalités (2-3 semaines)
- [ ] Gestion joueurs complète
- [ ] Historique matchs
- [ ] Statistiques de base
- [ ] Thème clair/sombre

### Phase 3: Analytics (1-2 semaines)
- [ ] Statistiques avancées
- [ ] Graphiques évolution
- [ ] Export PDF/CSV
- [ ] Partage réseaux sociaux

### Phase 4: Release (1 semaine)
- [ ] Tests iOS/Android
- [ ] Optimisation performances
- [ ] Documentation utilisateur
- [ ] Publication stores

## 📚 Documentation Complète

- **MOBILE_APP.md** - Architecture complète, protocoles, wireframes
- **ESP32_MOBILE_INTEGRATION.cpp** - Code ESP32 détaillé avec commentaires
- **mobile_app_examples/README.md** - Guide Flutter avec exemples

## 💡 Tips

### Développement

1. **Tester sur appareil réel** (pas émulateur) pour BLE
2. **Garder Serial Monitor ouvert** pour debugging ESP32
3. **Utiliser flutter_blue_plus debugger** pour voir paquets BLE
4. **Commencer simple** puis ajouter fonctionnalités

### Performance

1. **Limiter fréquence notifications** (1x/seconde max)
2. **Utiliser StreamBuilder** pour UI réactive
3. **Cacher données localement** (moins de requêtes BLE)
4. **Optimiser queries SQLite** (index sur colonnes fréquentes)

### UX

1. **Indicateur connexion visible** (top right)
2. **Feedback visuel** sur chaque action
3. **Messages d'erreur clairs**
4. **Mode offline** si déconnexion

## 🎯 Prochaines Actions

1. ✅ Lire la documentation (MOBILE_APP.md)
2. ⬜ Installer Flutter
3. ⬜ Créer projet Flutter
4. ⬜ Copier exemples fournis
5. ⬜ Modifier code ESP32
6. ⬜ Tester connexion BLE
7. ⬜ Implémenter écrans manquants
8. ⬜ Ajouter base de données
9. ⬜ Tests finaux
10. ⬜ Publication

## 🤝 Support

Pour questions ou problèmes:
1. Consulter FAQ dans MOBILE_APP.md
2. Vérifier logs Serial ESP32
3. Vérifier logs Flutter console
4. Ouvrir issue GitHub

## 📄 Licence

Même licence que PadelDisplay (MIT)

---

**Bon développement! 🎾📱**
