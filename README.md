# Afficheur de Score de Padel - LED P5 HUB75

## Description du Projet

Application ESP32 pour afficher en temps réel les scores d'une partie de padel sur un panneau LED P5 (32x64 pixels, 320x160mm). Les scores sont contrôlés sans fil via des eTags BLE, un par joueur.

## Caractéristiques Techniques

### Matériel
- **Afficheur LED**: P5 SMD RGB HUB75
  - Résolution: 32x64 pixels
  - Dimensions: 320x160mm
  - Balayage: 1/16
  - Usage: Intérieur
  - Interface: HUB75

- **Microcontrôleur**: ESP32 CH340C (30 broches)
  - WiFi/Bluetooth intégré
  - Voltage: 5V via USB ou alimentation externe
  
- **Contrôleurs**: 2x eTags BLE (un par joueur)
  - 1 clic: Incrémente le score
  - 2 clics: Décrémente le score

### Fonctionnalités
- ✅ Affichage simultané des scores de 2 joueurs
- ✅ Contrôle sans fil via BLE (Bluetooth Low Energy)
- ✅ Détection des clics simples et doubles
- ✅ Gestion automatique des jeux, sets et match
- ✅ Affichage clair et lisible sur LED RGB
- ✅ Réinitialisation du match
- ✅ Mode veille automatique
- ✅ Mesure et affichage du niveau de batterie LiFePO4
- 📱 **Application Mobile** (Android/iOS) - Voir [MOBILE_APP.md](MOBILE_APP.md)
  - Configuration des joueurs
  - Historique des matchs
  - Statistiques détaillées
  - Contrôle via Bluetooth

## Structure du Projet

```
PadelDisplay/
├── README.md                      # Ce fichier
├── HARDWARE.md                    # Schéma de connexion et composants
├── BATTERY.md                     # Guide mesure batterie LiFePO4 12.8V
├── USAGE.md                       # Guide d'utilisation
├── MOBILE_APP.md                  # 📱 Documentation app mobile complète
├── MOBILE_APP_QUICKSTART.md       # 📱 Guide rapide app mobile
├── ESP32_MOBILE_INTEGRATION.cpp   # 🔧 Code ESP32 pour app mobile
├── platformio.ini                 # Configuration PlatformIO
├── src/
│   └── main.cpp                   # Code source principal
└── mobile_app_examples/           # 📱 Exemples Flutter
    ├── README.md
    └── lib/
        ├── services/
        ├── models/
        └── screens/
```

## Installation

### Prérequis
1. [Visual Studio Code](https://code.visualstudio.com/)
2. [PlatformIO Extension](https://platformio.org/install/ide?install=vscode)
3. **Option A**: Alimentation 5V 3-4A pour panneau LED (usage fixe)
5. **Option B**: Batterie LiFePO4 12.8V 20Ah + régulateurs Buck (usage portable) - [Voir BATTERY.md](BATTERY.md)
4. Alimentation 5V 3-4A pour le panneau LED

### Étapes d'Installation

1. **Cloner ou ouvrir le projet**
   ```bash
   cd f:\VsCode\PadelDisplay
   ```

2. **Ouvrir dans VS Code avec PlatformIO**
   - Ouvrir VS Code
   - File > Open Folder > Sélectionner PadelDisplay

3. **Connecter le matériel** (voir HARDWARE.md)

4. **Compiler et téléverser**
   - Connecter l'ESP32 via USB
   - Cliquer sur l'icône PlatformIO (alien)
   - Upload (ou raccourci: Ctrl+Alt+U)

5. **Moniteur série**
   - Ouvrir le moniteur série (icône prise)
   - Baudrate: 115200
   - Observer les messages de connexion BLE

## Configuration des eTags BLE

Les eTags doivent être configurés avec les UUIDs suivants:

**Joueur 1 (Gauche)**
- Nom: "PadelTag1" ou "iTAG"
- Adresse MAC: à définir dans le code

**Joueur 2 (Droite)**  
- Nom: "PadelTag2" ou "iTAG"
- Adresse MAC: à définir dans le code

> **Note**: Si vous utilisez des iTags standards, l'application détectera automatiquement les appareils compatibles.

## Utilisation Rapide

1. **Allumer le système**
   - Alimenter l'afficheur LED (5V 3-4A)
   - Alimenter l'ESP32 (USB ou 5V)

2. **Connexion BLE**
   - Appuyer sur le bouton des eTags pour les activer
   - L'ESP32 se connecte automatiquement
   - Le panneau LED affiche "READY" puis "0 - 0"

3. **Marquer des points**
   - **1 clic simple**: +1 point au joueur
   - **2 clics rapides**: -1 point au joueur (correction)

4. **Fin de partie**
   - Le système détecte automatiquement la fin des sets
   - Un joueur gagne à 6 jeux (avec 2 jeux d'écart)
   - Possibilité de réinitialiser via double-clic long

## Règles du Padel Implémentées

- Points: 0, 15, 30, 40, Avantage, Jeu
- Égalité à 40-40 (deuce)
- Avantage après deuce
- Jeu gagné: 4 points avec 2 d'écart minimum
- Set gagné: 6 jeux avec 2 jeux d'écart (ou tie-break à 6-6)

## Dépannage

### L'afficheur ne s'allume pas
- Vérifier l'alimentation 5V (minimum 3A)
- Vérifier les connexions HUB75
- Vérifier que l'ESP32 est alimenté

### Les eTags ne se connectent pas
- Vérifier que le Bluetooth est activé sur les eTags
- Rapprocher les eTags de l'ESP32
- Vérifier les UUIDs dans le code
- Redémarrer l'ESP32

### Affichage incorrect
- Vérifier les paramètres du panneau (résolution, scan)
- Vérifier la configuration dans le code (PANEL_WIDTH, PANEL_HEIGHT)

### Clics non détectés
- Ajuster le délai de double-clic (DOUBLE_CLICK_DELAY)
- Vérifier la batterie des eTags

## Ressources

- [Documentation ESP32-HUB75-MatrixPanel-DMA](https://github.com/mrfaptastic/ESP32-HUB75-MatrixPanel-DMA)
- [Spécifications HUB75](https://github.com/pixelmatix/SmartMatrix/wiki)
- [ESP32 BLE Arduino](https://github.com/nkolban/ESP32_BLE_Arduino)

## Licence

Projet open-source - Libre d'utilisation et modification

## Auteur

Projet créé pour l'affichage de scores de padel
Version 1.0 - Avril 2026
