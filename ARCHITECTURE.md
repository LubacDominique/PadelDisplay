# Architecture du Système - PadelDisplay

## Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                     SYSTÈME PADELDISPLAY                         │
│                                                                  │
│  ┌────────────┐         ┌──────────────┐      ┌──────────────┐ │
│  │   eTag     │◄───BLE──┤    ESP32     ├──HUB75──┤  Panneau   │ │
│  │  Joueur 1  │         │  WROOM-32    │      │   LED P5     │ │
│  │  (Gauche)  │         │  WiFi/BLE    │      │   32x64px    │ │
│  └────────────┘         └──────┬───────┘      │   320x160mm  │ │
│                                │              └──────────────┘ │
│  ┌────────────┐                │                                │
│  │   eTag     │◄───BLE─────────┘                                │
│  │  Joueur 2  │                                                 │
│  │  (Droite)  │                                                 │
│  └────────────┘                                                 │
│                                                                  │
│  Alimentation: 5V/4A DC (Adaptateur secteur)                    │
└─────────────────────────────────────────────────────────────────┘
```

## Architecture Logicielle

### Diagramme des Composants

```
┌───────────────────────────────────────────────────────────────┐
│                         main.cpp                               │
├───────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │              COUCHE PRÉSENTATION                        │  │
│  │  ┌─────────────┐ ┌──────────────┐ ┌─────────────────┐  │  │
│  │  │  Display    │ │  Animations  │ │   Messages      │  │  │
│  │  │  Score()    │ │  GameWon()   │ │   Welcome       │  │  │
│  │  └─────────────┘ └──────────────┘ └─────────────────┘  │  │
│  └─────────────────────────────────────────────────────────┘  │
│                            │                                   │
│  ┌─────────────────────────▼───────────────────────────────┐  │
│  │              COUCHE LOGIQUE MÉTIER                       │  │
│  │  ┌──────────┐ ┌──────────┐ ┌─────────┐ ┌────────────┐  │  │
│  │  │ addPoint │ │checkGame │ │checkSet │ │checkMatch  │  │  │
│  │  │  ()      │ │  Won()   │ │  Won()  │ │  Won()     │  │  │
│  │  └──────────┘ └──────────┘ └─────────┘ └────────────┘  │  │
│  │                                                          │  │
│  │  ┌──────────────────────────────────────────────────┐   │  │
│  │  │  Gestion Deuce / Avantage                        │   │  │
│  │  │  Règles du Padel                                 │   │  │
│  │  └──────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────┘  │
│                            │                                   │
│  ┌─────────────────────────▼───────────────────────────────┐  │
│  │              COUCHE ENTRÉES/SORTIES                      │  │
│  │                                                          │  │
│  │  ┌────────────────────┐      ┌──────────────────────┐   │  │
│  │  │   BLE Manager      │      │   LED Controller     │   │  │
│  │  │                    │      │                      │   │  │
│  │  │ • Scan devices     │      │ • MatrixPanel DMA    │   │  │
│  │  │ • Connect eTags    │      │ • GFX primitives     │   │  │
│  │  │ • Handle clicks    │      │ • Brightness control │   │  │
│  │  │ • Reconnect        │      │ • Color management   │   │  │
│  │  └────────────────────┘      └──────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────┘  │
│                            │                                   │
│  ┌─────────────────────────▼───────────────────────────────┐  │
│  │              COUCHE MATÉRIEL (HAL)                       │  │
│  │                                                          │  │
│  │  ┌────────────────┐              ┌──────────────────┐   │  │
│  │  │  ESP32 BLE     │              │  HUB75 Protocol  │   │  │
│  │  │  Stack         │              │  GPIO Control    │   │  │
│  │  └────────────────┘              └──────────────────┘   │  │
│  └─────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
```

## Flux de Données

### 1. Detection de Clic BLE

```
┌──────────┐    ①Appui      ┌──────────┐    ②Signal      ┌──────────┐
│  eTag    │    bouton      │   BLE    │     BLE         │  ESP32   │
│  iTAG    ├───────────────►│  Radio   ├────────────────►│  Core    │
└──────────┘                └──────────┘                 └─────┬────┘
                                                                │
                                                                │
              ┌─────────────────────────────────────────────────┘
              │
              │ ③Notification
              ▼
     ┌─────────────────┐
     │ handlePlayerClick│
     │   ()             │
     └────────┬─────────┘
              │
              │ ④Analyse
              ▼
     ┌─────────────────────┐
     │ Simple / Double ?   │
     └────────┬────────────┘
              │
        ┌─────┴─────┐
        │           │
    Simple      Double
        │           │
        ▼           ▼
   addPoint()   removePoint()
```

### 2. Mise à Jour du Score

```
addPoint(player)
     │
     ├──► player.points++
     │
     ├──► Check Deuce (>=3 && >=3)
     │        │
     │        ├──► Égalité? → isDeuce = true
     │        └──► Avantage? → player.hasAdvantage = true
     │
     ├──► checkGameWon()
     │        │
     │        ├──► 4 pts + 2 écart? → Yes
     │        │         │
     │        │         ├──► player.games++
     │        │         ├──► displayGameWon()
     │        │         └──► resetGame()
     │        │
     │        └──► checkSetWon()
     │                 │
     │                 ├──► 6 jeux + 2 écart? → Yes
     │                 │         │
     │                 │         ├──► player.sets++
     │                 │         ├──► displaySetWon()
     │                 │         └──► resetGames()
     │                 │
     │                 └──► checkMatchWon()
     │                           │
     │                           └──► 2 sets? → displayMatchWon()
     │
     └──► displayScore()
              │
              └──► Refresh LED Panel
```

## Structure des Données

### Objet Player

```cpp
struct Player {
    // État du jeu
    int points;              // 0-4+ (0, 15, 30, 40, ADV)
    int games;               // 0-7 (jeux gagnés)
    int sets;                // 0-3 (sets gagnés)
    bool hasAdvantage;       // true si avantage après deuce
    
    // Gestion des clics
    unsigned long lastClickTime;  // Timestamp dernier clic
    int clickCount;               // 1 ou 2 (simple/double)
    
    // Connexion BLE
    BLEAddress* bleAddress;  // Adresse MAC de l'eTag
    BLEClient* bleClient;    // Client BLE connecté
    bool connected;          // État connexion
};
```

### Machine à États - Jeu

```
┌─────────────────────────────────────────────────────────────┐
│                     ÉTATS DU JEU                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ╔═══════════╗                                              │
│  ║  INITIAL  ║  (0-0)                                       │
│  ╚═════╤═════╝                                              │
│        │                                                     │
│        │ Point marqué                                       │
│        ▼                                                     │
│  ╔═══════════╗                                              │
│  ║  PLAYING  ║  (15-0, 30-15, ...)                          │
│  ╚═════╤═════╝                                              │
│        │                                                     │
│        │ Score 40-40                                        │
│        ▼                                                     │
│  ╔═══════════╗                                              │
│  ║   DEUCE   ║  (40-40)                                     │
│  ╚═════╤═════╝                                              │
│        │                                                     │
│        │ Point marqué                                       │
│        ▼                                                     │
│  ╔═══════════╗                                              │
│  ║ ADVANTAGE ║  (ADV-40 ou 40-ADV)                          │
│  ╚═════╤═════╝                                              │
│        │                                                     │
│        │ Point marqué (joueur avec ADV)                     │
│        ▼                                                     │
│  ╔═══════════╗                                              │
│  ║ GAME WON  ║  Animation + games++                         │
│  ╚═════╤═════╝                                              │
│        │                                                     │
│        │ Auto                                               │
│        ▼                                                     │
│  ╔═══════════╗                                              │
│  ║  INITIAL  ║  Nouveau jeu                                 │
│  ╚═══════════╝                                              │
└─────────────────────────────────────────────────────────────┘
```

## Timing et Performance

### Temps de Réponse

| Événement | Temps | Notes |
|-----------|-------|-------|
| Clic eTag → ESP32 | 50-150ms | Latence BLE |
| Traitement logique | <10ms | CPU ESP32 |
| Mise à jour affichage | 16ms | 60 FPS |
| **Total clic → affichage** | **<200ms** | Perceptible immédiatement |

### Occupation CPU

```
┌────────────────────────────────────┐
│  ESP32 Dual Core (240MHz)          │
├────────────────────────────────────┤
│                                    │
│  Core 0:                           │
│  ├─ WiFi/BLE Stack         40%     │
│  ├─ FreeRTOS               10%     │
│  └─ Idle                   50%     │
│                                    │
│  Core 1:                           │
│  ├─ LED Refresh (DMA)      60%     │
│  ├─ Application Logic      15%     │
│  └─ Idle                   25%     │
│                                    │
└────────────────────────────────────┘
```

### Consommation Mémoire

| Composant | RAM | Flash |
|-----------|-----|-------|
| Code programme | - | ~250 KB |
| Variables globales | 4 KB | - |
| Stack | 8 KB | - |
| BLE Stack | 80 KB | - |
| LED Framebuffer | 12 KB | - |
| Librairies | - | ~400 KB |
| **Total** | **~104 KB** | **~650 KB** |
| **Disponible** | 320 KB | 4 MB |
| **Marge** | **68%** | **84%** |

## Sécurité et Fiabilité

### Gestion des Erreurs

```cpp
// Watchdog Timer
esp_task_wdt_init(30, true);  // 30 secondes

// Vérification connexions
if (!player1.connected) {
    reconnectBLE(player1);
}

// Sanity checks
if (player.points < 0 || player.points > 10) {
    resetGame();
    logError("Invalid points");
}
```

### Tolérance aux Pannes

| Scénario | Comportement |
|----------|--------------|
| Perte connexion BLE | Tentative de reconnexion automatique |
| Alimentation coupée | Perte du score (pas de sauvegarde*) |
| Panneau LED défectueux | Logs série toujours actifs |
| Clics simultanés | Traitement séquentiel (FIFO) |

*Future: Sauvegarde EEPROM/SPIFFS

## Protocole HUB75

### Signaux et Synchronisation

```
┌─────────────────────────────────────────────────────┐
│  Cycle de Rafraîchissement (1/16 scan)              │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Pour chaque ligne (0-15):                          │
│                                                      │
│    1. Désactiver Output (OE = HIGH)                 │
│    2. Sélectionner ligne (A,B,C,D,E)                │
│    3. Clock in les données RGB (CLK + R1,G1,B1...)  │
│    4. Latch les données (LAT = HIGH puis LOW)       │
│    5. Activer Output (OE = LOW)                     │
│    6. Attendre 1/16 du temps de frame               │
│                                                      │
│  Répéter à 60 Hz pour éviter le flickering          │
│                                                      │
└─────────────────────────────────────────────────────┘

Timing:
    ┌───┐   ┌───┐   ┌───┐
CLK │   └───┘   └───┘   └───  (Horloge données)
    ────┬───────────────────
R1      └───────────────────  (Données rouge)
        ┌───────────────────
LAT ────┘                     (Validation)
    ────────────┐   ┌───────
OE              └───┘         (Activation sortie)
```

## Protocole BLE

### Services et Caractéristiques

```
Service UUID: 0000FFE0-0000-1000-8000-00805F9B34FB
    │
    └─ Characteristic UUID: 0000FFE1-0000-1000-8000-00805F9B34FB
           │
           ├─ Properties: READ, WRITE, NOTIFY
           │
           └─ Value: 1 byte
                  │
                  ├─ 0x01: Button pressed
                  ├─ 0x02: Button released
                  └─ 0x03: Double-press
```

### Séquence de Connexion

```
ESP32                                  eTag iTAG
  │                                        │
  │ ────── BLE Scan ─────►                │
  │                                        │
  │ ◄───── Advertisement ──────           │
  │       (Name: iTAG, UUID: FFE0)        │
  │                                        │
  │ ────── Connect Request ─────►         │
  │                                        │
  │ ◄───── Connection OK ──────           │
  │                                        │
  │ ────── Discover Services ─────►       │
  │                                        │
  │ ◄───── Service List ──────            │
  │       (UUID: FFE0)                    │
  │                                        │
  │ ────── Subscribe Notify ─────►        │
  │       (Char UUID: FFE1)               │
  │                                        │
  │ ◄───── Subscription OK ──────         │
  │                                        │
  │                [Appui bouton]         │
  │                        │               │
  │ ◄───── Notification ───┘              │
  │       (Value: 0x01)                   │
  │                                        │
  ▼                                        ▼
handlePlayerClick()                   [LED flash]
```

## Extensions Possibles

### Modularisation Future

```
PadelDisplay/
│
├── src/
│   ├── main.cpp              # Point d'entrée
│   │
│   ├── display/              # Module affichage
│   │   ├── display_manager.h
│   │   ├── display_manager.cpp
│   │   ├── animations.h
│   │   └── animations.cpp
│   │
│   ├── game/                 # Logique de jeu
│   │   ├── game_engine.h
│   │   ├── game_engine.cpp
│   │   ├── score_manager.h
│   │   └── score_manager.cpp
│   │
│   ├── ble/                  # Gestion BLE
│   │   ├── ble_manager.h
│   │   ├── ble_manager.cpp
│   │   ├── tag_handler.h
│   │   └── tag_handler.cpp
│   │
│   ├── config/               # Configuration
│   │   ├── config.h
│   │   └── pins.h
│   │
│   └── utils/                # Utilitaires
│       ├── logger.h
│       ├── logger.cpp
│       └── helpers.h
│
├── test/                     # Tests unitaires
│   ├── test_game_engine.cpp
│   ├── test_score_manager.cpp
│   └── test_ble_manager.cpp
│
└── docs/                     # Documentation
    ├── API.md
    ├── ARCHITECTURE.md (ce fichier)
    └── PROTOCOL.md
```

---

**Architecture Version:** 1.0  
**Dernière mise à jour:** Avril 2026  
**Complexité:** Moyenne (adaptée à des développeurs intermédiaires)
