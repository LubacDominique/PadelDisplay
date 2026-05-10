# Configuration BLE - Personnalisation des eTags

## Fichier Optionnel de Configuration

Si vous souhaitez fixer les adresses MAC des eTags sans modifier `main.cpp`, créez un fichier `config.h` dans le dossier `src/` avec le contenu suivant:

```cpp
#ifndef CONFIG_H
#define CONFIG_H

// Adresses MAC des eTags BLE
// Format: "AA:BB:CC:DD:EE:FF"
// Laisser vides pour auto-détection

#define PLAYER1_MAC_ADDRESS "aa:bb:cc:dd:ee:ff"  // eTag Joueur 1
#define PLAYER2_MAC_ADDRESS "11:22:33:44:55:66"  // eTag Joueur 2

// Paramètres d'affichage
#define DEFAULT_BRIGHTNESS 128  // 0-255 (128 = 50%)

// Délai de double-clic (millisecondes)
#define DOUBLE_CLICK_TIME 400

// Intervalle de reconnexion BLE (millisecondes)
#define BLE_RECONNECT_MS 10000

// Paramètres de jeu
#define POINTS_TO_WIN_GAME 4    // Nombre de points pour gagner un jeu
#define GAMES_TO_WIN_SET 6      // Nombre de jeux pour gagner un set
#define SETS_TO_WIN_MATCH 2     // Nombre de sets pour gagner le match

#endif
```

Puis dans `main.cpp`, ajouter en haut:
```cpp
#include "config.h"
```

---

## Comment Trouver l'Adresse MAC de vos eTags

### Méthode 1: Via le Moniteur Série

1. Téléverser le programme sur l'ESP32
2. Ouvrir le moniteur série (Baudrate: 115200)
3. Activer le premier eTag (appuyer sur le bouton)
4. Observer les messages:
   ```
   BLE Découvert: Name: iTAG, Address: aa:bb:cc:dd:ee:ff, RSSI: -45
   ```
5. Noter l'adresse MAC
6. Répéter pour le second eTag
7. Reporter les adresses dans `config.h`

### Méthode 2: Via Application Smartphone

**Android:**
- Installer "nRF Connect" (Nordic Semiconductor)
- Scanner les appareils BLE
- Identifier les iTags
- Noter les adresses MAC

**iOS:**
- Installer "LightBlue Explorer"
- Scanner les appareils BLE
- Identifier les iTags
- Noter les adresses MAC

---

## Codes de Commande Série

Pendant l'exécution, vous pouvez envoyer des commandes via le moniteur série:

| Commande | Action |
|----------|--------|
| `1` ou `+` | Point pour Joueur 1 |
| `2` ou `=` | Point pour Joueur 2 |
| `!` | Retire un point à Joueur 1 |
| `@` | Retire un point à Joueur 2 |
| `r` ou `R` | Réinitialise le match |
| `s` ou `S` | Affiche le statut complet |

### Exemple d'Utilisation

```
Commande: s
Sortie:
Statut:
Joueur 1: 2 points, 3 jeux, 1 sets - Connecté
Joueur 2: 3 points, 2 jeux, 0 sets - Connecté
Deuce: Non
```

---

## Personnalisation Avancée

### Modifier les Couleurs

Dans `main.cpp`, ligne ~70, modifier:

```cpp
// Couleurs des scores
uint16_t COLOR_PLAYER1 = rgb565(255, 0, 0);    // Rouge
uint16_t COLOR_PLAYER2 = rgb565(0, 255, 0);    // Vert

// Autres couleurs disponibles
uint16_t COLOR_WHITE   = rgb565(255, 255, 255);
uint16_t COLOR_YELLOW  = rgb565(255, 255, 0);
uint16_t COLOR_CYAN    = rgb565(0, 255, 255);
uint16_t COLOR_MAGENTA = rgb565(255, 0, 255);
uint16_t COLOR_ORANGE  = rgb565(255, 165, 0);
```

### Ajuster la Luminosité

```cpp
// Dans setup(), ligne ~630
dma_display->setBrightness8(128);  // 0-255

// Exemples:
// 64  = 25% (très sombre, économie)
// 128 = 50% (recommandé intérieur)
// 192 = 75% (lumineux)
// 255 = 100% (maximum, consommation élevée)
```

### Changer la Taille du Texte

```cpp
// Dans displayScore(), modifier setTextSize()
dma_display->setTextSize(1);  // Petit
dma_display->setTextSize(2);  // Moyen (par défaut)
dma_display->setTextSize(3);  // Grand
```

---

## Débuggage

### Activer les Messages de Debug

Ajouter en haut de `main.cpp`:

```cpp
#define DEBUG_MODE 1

#if DEBUG_MODE
  #define DEBUG_PRINT(x) Serial.print(x)
  #define DEBUG_PRINTLN(x) Serial.println(x)
#else
  #define DEBUG_PRINT(x)
  #define DEBUG_PRINTLN(x)
#endif
```

Puis utiliser partout:
```cpp
DEBUG_PRINTLN("Message de debug");
```

### Logs Verbeux BLE

```cpp
// Dans setup(), après BLEDevice::init()
BLEDevice::setDebugLevel(ESP_LOG_VERBOSE);
```

---

## FAQ Technique

**Q: Comment changer le délai de double-clic?**
```cpp
#define DOUBLE_CLICK_DELAY 400  // Millisecondes (défaut: 400)
// Plus court = détection plus rapide mais risque de faux positifs
// Plus long = plus fiable mais moins réactif
```

**Q: Comment désactiver l'auto-détection BLE?**
```cpp
// Définir les adresses MAC manuellement
String PLAYER1_MAC = "AA:BB:CC:DD:EE:FF";
String PLAYER2_MAC = "11:22:33:44:55:66";
```

**Q: Comment afficher plus d'informations?**
Modifier la fonction `displayScore()` pour ajouter:
- Chronomètre
- Nom des joueurs
- Numéro de set
- Statistiques

---

## Support et Contributions

Pour signaler un bug ou proposer une amélioration:
1. Vérifier la section USAGE.md et HARDWARE.md
2. Consulter les issues GitHub (si repository public)
3. Fournir les informations suivantes:
   - Version du code
   - Modèle exact de l'ESP32
   - Modèle du panneau LED
   - Log du moniteur série
   - Description du problème

---

**Version:** 1.0  
**Date:** Avril 2026  
**Licence:** Open Source
