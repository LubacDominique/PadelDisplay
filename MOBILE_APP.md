# Application Mobile PadelDisplay

## Vue d'Ensemble

Application mobile multi-plateforme (Android/iOS) pour contrôler, configurer et analyser les matchs de Padel affichés sur le système PadelDisplay ESP32.

## Architecture Technique

### Stack Technologique Recommandé

```
┌─────────────────────────────────────────────────────────────┐
│                   APPLICATION MOBILE                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Framework: Flutter / React Native                           │
│  Langage: Dart (Flutter) ou TypeScript (React Native)       │
│  État: Redux/MobX (RN) ou Riverpod/Bloc (Flutter)          │
│  Bluetooth: flutter_blue_plus ou react-native-ble-plx       │
│  Base de données locale: SQLite (sqflite/react-native-sqli) │
│  Navigation: React Navigation ou Flutter Navigator          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Recommandation: Flutter** 
- Performance native
- UI cohérente cross-platform
- Excellente gestion BLE avec flutter_blue_plus
- Communauté active

### Architecture de l'Application

```
┌───────────────────────────────────────────────────────────────┐
│                    MOBILE APP ARCHITECTURE                     │
├───────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │                   COUCHE PRÉSENTATION                     │ │
│  │  ┌────────────┐ ┌─────────────┐ ┌──────────────────┐    │ │
│  │  │   Home     │ │    Match    │ │    Statistics    │    │ │
│  │  │   Screen   │ │   Control   │ │      Screen      │    │ │
│  │  └────────────┘ └─────────────┘ └──────────────────┘    │ │
│  │  ┌────────────┐ ┌─────────────┐ ┌──────────────────┐    │ │
│  │  │  Players   │ │   History   │ │     Settings     │    │ │
│  │  │  Config    │ │   Screen    │ │      Screen      │    │ │
│  │  └────────────┘ └─────────────┘ └──────────────────┘    │ │
│  └──────────────────────────────────────────────────────────┘ │
│                            │                                   │
│  ┌─────────────────────────▼────────────────────────────────┐ │
│  │                   COUCHE LOGIQUE MÉTIER                   │ │
│  │  ┌──────────────┐ ┌──────────────┐ ┌─────────────────┐  │ │
│  │  │ Match        │ │ Statistics   │ │ Player          │  │ │
│  │  │ Manager      │ │ Calculator   │ │ Manager         │  │ │
│  │  └──────────────┘ └──────────────┘ └─────────────────┘  │ │
│  └──────────────────────────────────────────────────────────┘ │
│                            │                                   │
│  ┌─────────────────────────▼────────────────────────────────┐ │
│  │                   COUCHE SERVICES                         │ │
│  │  ┌──────────────┐ ┌──────────────┐ ┌─────────────────┐  │ │
│  │  │   BLE        │ │   Database   │ │   Analytics     │  │ │
│  │  │   Service    │ │   Service    │ │   Service       │  │ │
│  │  └──────────────┘ └──────────────┘ └─────────────────┘  │ │
│  └──────────────────────────────────────────────────────────┘ │
│                            │                                   │
│  ┌─────────────────────────▼────────────────────────────────┐ │
│  │                   COUCHE DONNÉES                          │ │
│  │  ┌──────────────┐ ┌──────────────┐ ┌─────────────────┐  │ │
│  │  │   SQLite     │ │   BLE API    │ │   Preferences   │  │ │
│  │  │   Database   │ │   (ESP32)    │ │   Storage       │  │ │
│  │  └──────────────┘ └──────────────┘ └─────────────────┘  │ │
│  └──────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────┘
```

## Protocole de Communication BLE

### Architecture de Communication

```
┌─────────────────┐                            ┌──────────────┐
│   Mobile App    │◄──────── BLE ─────────────►│   ESP32      │
│                 │                            │  PadelDisplay│
│  • Scan         │   ①Discovery              │              │
│  • Connect      │◄───────────────────────────│  • Advertise │
│  • Control      │                            │  • Notify    │
│  • Monitor      │   ②Connect & Subscribe     │  • Respond   │
│  • Receive Data │◄───────────────────────────│              │
│                 │                            │              │
│                 │   ③Send Commands           │              │
│                 ├────────────────────────────►│              │
│                 │                            │              │
│                 │   ④Receive Updates         │              │
│                 │◄───────────────────────────│              │
└─────────────────┘                            └──────────────┘
```

### Services BLE ESP32 à Créer

**Service Principal: Score Control**
```
UUID: 0000AA00-0000-1000-8000-00805F9B34FB

Caractéristiques:
├─ Score Update (Read/Notify) 
│  UUID: 0000AA01-0000-1000-8000-00805F9B34FB
│  Format: "P1_points,P1_games,P1_sets,P2_points,P2_games,P2_sets"
│  Exemple: "30,2,1,40,1,0"
│
├─ Command (Write)
│  UUID: 0000AA02-0000-1000-8000-00805F9B34FB
│  Commandes:
│    • "P1_ADD"      → Ajouter point joueur 1
│    • "P1_REMOVE"   → Retirer point joueur 1
│    • "P2_ADD"      → Ajouter point joueur 2
│    • "P2_REMOVE"   → Retirer point joueur 2
│    • "RESET"       → Réinitialiser match
│    • "RESET_GAME"  → Réinitialiser jeu
│    • "GET_STATUS"  → Demander état complet
│
├─ Match Status (Read/Notify)
│  UUID: 0000AA03-0000-1000-8000-00805F9B34FB
│  Format JSON:
│  {
│    "gameInProgress": true,
│    "isDeuce": false,
│    "currentServer": 1,
│    "matchTime": 1234567,
│    "lastPointTime": 123456
│  }
│
└─ Battery Info (Read/Notify)
   UUID: 0000AA04-0000-1000-8000-00805F9B34FB
   Format: "system_voltage,system_percent,etag1_percent,etag2_percent"
   Exemple: "12.2,95,80,75"
```

**Service Secondaire: Player Configuration**
```
UUID: 0000BB00-0000-1000-8000-00805F9B34FB

Caractéristiques:
├─ Player Names (Read/Write)
│  UUID: 0000BB01-0000-1000-8000-00805F9B34FB
│  Format: "Player1Name,Player2Name"
│
└─ Match Config (Read/Write)
   UUID: 0000BB02-0000-1000-8000-00805F9B34FB
   Format JSON:
   {
     "setsToWin": 2,
     "gamesToWin": 6,
     "tiebreakAt": 6,
     "matchType": "doubles"
   }
```

## Modèle de Données

### Base de Données SQLite

```sql
-- Table des joueurs
CREATE TABLE players (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    photo_path TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Table des matchs
CREATE TABLE matches (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    match_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    player1_id INTEGER,
    player2_id INTEGER,
    player1_sets INTEGER DEFAULT 0,
    player2_sets INTEGER DEFAULT 0,
    duration_seconds INTEGER,
    completed BOOLEAN DEFAULT 0,
    winner_id INTEGER,
    FOREIGN KEY (player1_id) REFERENCES players(id),
    FOREIGN KEY (player2_id) REFERENCES players(id),
    FOREIGN KEY (winner_id) REFERENCES players(id)
);

-- Table des sets (détail par set)
CREATE TABLE match_sets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    match_id INTEGER,
    set_number INTEGER,
    player1_games INTEGER DEFAULT 0,
    player2_games INTEGER DEFAULT 0,
    duration_seconds INTEGER,
    FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE
);

-- Table des points (historique détaillé)
CREATE TABLE match_points (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    match_id INTEGER,
    set_number INTEGER,
    game_number INTEGER,
    point_winner INTEGER, -- 1 ou 2
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    score_after TEXT, -- Format: "30-15"
    FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE
);

-- Table des statistiques
CREATE TABLE player_statistics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER,
    total_matches INTEGER DEFAULT 0,
    total_wins INTEGER DEFAULT 0,
    total_losses INTEGER DEFAULT 0,
    total_sets_won INTEGER DEFAULT 0,
    total_sets_lost INTEGER DEFAULT 0,
    total_games_won INTEGER DEFAULT 0,
    total_games_lost INTEGER DEFAULT 0,
    total_points_won INTEGER DEFAULT 0,
    total_points_lost INTEGER DEFAULT 0,
    average_match_duration INTEGER DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);
```

## Fonctionnalités Détaillées

### 1. Configuration des Joueurs

**Écran: Player Management**
```
┌─────────────────────────────────────┐
│  ☰  Joueurs                    ➕   │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │  👤  Jean Dupont             │   │
│  │      Matchs: 45  Victoires: 28│  │
│  │      ⭐ 62% win rate          │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  👤  Marie Martin            │   │
│  │      Matchs: 32  Victoires: 20│  │
│  │      ⭐ 63% win rate          │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

**Fonctionnalités:**
- Ajouter/Modifier/Supprimer joueurs
- Photo de profil (caméra ou galerie)
- Nom, prénom, surnom
- Statistiques de base visibles
- Recherche par nom

### 2. Contrôle du Match en Direct

**Écran: Live Match Control**
```
┌─────────────────────────────────────┐
│  ← Match en cours         🔋95% 🔗  │
├─────────────────────────────────────┤
│                                     │
│  Jean Dupont          Marie Martin  │
│  ┌─────────┐           ┌─────────┐ │
│  │    2    │  Sets     │    1    │ │
│  └─────────┘           └─────────┘ │
│  ┌─────────┐           ┌─────────┐ │
│  │    4    │  Games    │    3    │ │
│  └─────────┘           └─────────┘ │
│  ┌─────────┐           ┌─────────┐ │
│  │   40    │  Points   │   30    │ │
│  └─────────┘           └─────────┘ │
│                                     │
│  🎾 Service: Jean                   │
│  ⏱️  Durée: 45:23                   │
│                                     │
│  ┌─────────┐ ┌─────────┐ ┌───────┐│
│  │  ➕ J1  │ │  ➕ J2  │ │ Reset ││
│  └─────────┘ └─────────┘ └───────┘│
│                                     │
│  Historique des points:             │
│  • 45:20 - Marie gagne (30-40)     │
│  • 44:15 - Jean gagne (30-30)      │
│  • 43:50 - Marie gagne (15-30)     │
│                                     │
└─────────────────────────────────────┘
```

**Fonctionnalités:**
- Affichage en temps réel du score
- Boutons d'ajout de points (±)
- Indicateur de service
- Chronomètre du match
- Historique des derniers points
- État de la connexion BLE
- Niveau batterie ESP32 et eTags
- Bouton reset match/game
- Sauvegarde automatique

### 3. Historique des Matchs

**Écran: Match History**
```
┌─────────────────────────────────────┐
│  ☰  Historique            🔍 📅     │
├─────────────────────────────────────┤
│                                     │
│  📅 Aujourd'hui                     │
│  ┌─────────────────────────────┐   │
│  │ Jean vs Marie      ⏱️ 48:32  │   │
│  │ 🏆 Jean  2-1               │   │
│  │ Sets: 6-4, 3-6, 6-3        │   │
│  │ 15:30 - Court 1            │   │
│  └─────────────────────────────┘   │
│                                     │
│  📅 Hier                            │
│  ┌─────────────────────────────┐   │
│  │ Paul vs Luc        ⏱️ 52:15  │   │
│  │ 🏆 Paul  2-0               │   │
│  │ Sets: 6-2, 7-5             │   │
│  │ 18:00 - Court 2            │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

**Fonctionnalités:**
- Liste chronologique des matchs
- Filtre par date, joueur, résultat
- Tri par date/durée/joueur
- Détails complets au clic
- Export PDF/CSV
- Partage sur réseaux sociaux
- Suppression de matchs

### 4. Statistiques Détaillées

**Écran: Statistics Dashboard**
```
┌─────────────────────────────────────┐
│  ☰  Statistiques      [Jean Dupont]│
├─────────────────────────────────────┤
│                                     │
│  📊 Vue d'ensemble                  │
│  ┌─────────────────────────────┐   │
│  │  Matchs: 45                 │   │
│  │  Victoires: 28 (62%)        │   │
│  │  Défaites: 17 (38%)         │   │
│  │  Win Streak actuelle: 3     │   │
│  └─────────────────────────────┘   │
│                                     │
│  📈 Performance                     │
│  ┌─────────────────────────────┐   │
│  │  Sets gagnés: 65/102 (64%) │   │
│  │  Games gagnés: 385/610 (63%)│  │
│  │  Durée moy: 47m 32s        │   │
│  │  Plus long match: 1h 25m   │   │
│  └─────────────────────────────┘   │
│                                     │
│  📅 Évolution (7 derniers jours)   │
│  ┌─────────────────────────────┐   │
│  │     ▁▃▅█▇▅▃                │   │
│  │  L M M J V S D              │   │
│  └─────────────────────────────┘   │
│                                     │
│  🎯 Head-to-Head                    │
│  ┌─────────────────────────────┐   │
│  │ vs Marie: 8-5 (62%)        │   │
│  │ vs Paul:  6-4 (60%)        │   │
│  │ vs Luc:   5-3 (63%)        │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

**Statistiques calculées:**
- Taux de victoire global et par adversaire
- Séries de victoires/défaites
- Performance par set (1er, 2e, 3e)
- Tendance sur période (7j, 30j, année)
- Points gagnés/perdus
- Durée moyenne des matchs
- Graphiques d'évolution
- Comparaison joueurs

### 5. Connexion Bluetooth

**Écran: BLE Connection**
```
┌─────────────────────────────────────┐
│  Connexion au Tableau               │
├─────────────────────────────────────┤
│                                     │
│  🔍 Recherche en cours...           │
│                                     │
│  Appareils disponibles:             │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 📡 PadelDisplay #A3F2       │   │
│  │    Signal: ████░░ -65 dBm   │   │
│  │    Batterie: 95%            │   │
│  │    [Connecter]              │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 📡 PadelDisplay #B7C1       │   │
│  │    Signal: ██░░░░ -82 dBm   │   │
│  │    Batterie: 78%            │   │
│  │    [Connecter]              │   │
│  └─────────────────────────────┘   │
│                                     │
│  ℹ️  Assurez-vous que le tableau   │
│     est allumé et à portée         │
│                                     │
└─────────────────────────────────────┘
```

**Fonctionnalités BLE:**
- Scan automatique des ESP32 PadelDisplay
- Affichage force du signal
- Connexion/Déconnexion manuelle
- Reconnexion automatique
- Gestion multi-appareils (plusieurs tableaux)
- Indicateur de statut permanent
- Notifications de déconnexion
- Mode offline (continue à enregistrer)

### 6. Paramètres

**Écran: Settings**
```
┌─────────────────────────────────────┐
│  ☰  Paramètres                      │
├─────────────────────────────────────┤
│                                     │
│  🎾 Match                            │
│  • Sets à gagner: [2] [3]          │
│  • Games par set: [6]              │
│  • Tie-break à: [6] [7]            │
│  • Type: [Simple] [Double]         │
│                                     │
│  📱 Application                      │
│  • Thème: [Clair] [Sombre] [Auto] │
│  • Langue: [Français]              │
│  • Son: [Activé]                   │
│  • Vibration: [Activé]             │
│                                     │
│  🔋 Batterie                         │
│  • Alerte batterie faible: 20%     │
│  • Économie d'énergie: [Activé]    │
│                                     │
│  📊 Données                          │
│  • Export base de données          │
│  • Import base de données          │
│  • Effacer toutes les données      │
│                                     │
│  ℹ️  À propos                        │
│  • Version: 1.0.0                  │
│  • Licence: MIT                    │
│  • GitHub: PadelDisplay            │
│                                     │
└─────────────────────────────────────┘
```

## Flux de Travail Principal

### Scénario: Démarrer un nouveau match

```
1. Utilisateur ouvre l'app
   └─► Écran d'accueil

2. Vérifie la connexion BLE
   ├─► Si déconnecté: propose de scanner
   └─► Si connecté: affiche état OK

3. Tap sur "Nouveau Match"
   └─► Écran de sélection joueurs

4. Sélectionne Joueur 1
   ├─► Liste des joueurs existants
   └─► Ou "Créer nouveau joueur"

5. Sélectionne Joueur 2
   └─► Même processus

6. Configure match (optionnel)
   ├─► Nombre de sets
   ├─► Type (simple/double)
   └─► Paramètres avancés

7. Tap "Démarrer"
   ├─► Envoie commande BLE "RESET"
   ├─► Envoie noms joueurs
   ├─► Crée entrée en base de données
   └─► Affiche écran contrôle live

8. Pendant le match
   ├─► Reçoit notifications BLE (scores)
   ├─► Affiche en temps réel
   ├─► Enregistre chaque point
   └─► Calcule statistiques

9. Fin du match
   ├─► Détecte victoire (via BLE)
   ├─► Marque match terminé en DB
   ├─► Affiche écran récapitulatif
   ├─► Propose partage résultat
   └─► Retour à l'accueil
```

## Modifications ESP32 Requises

### Code à Ajouter dans main.cpp

```cpp
// Nouveaux includes BLE pour services personnalisés
#include <NimBLEServer.h>
#include <NimBLEService.h>
#include <NimBLECharacteristic.h>

// UUIDs des services mobiles
#define SERVICE_SCORE_UUID        "0000AA00-0000-1000-8000-00805F9B34FB"
#define CHAR_SCORE_UPDATE_UUID    "0000AA01-0000-1000-8000-00805F9B34FB"
#define CHAR_COMMAND_UUID         "0000AA02-0000-1000-8000-00805F9B34FB"
#define CHAR_MATCH_STATUS_UUID    "0000AA03-0000-1000-8000-00805F9B34FB"
#define CHAR_BATTERY_INFO_UUID    "0000AA04-0000-1000-8000-00805F9B34FB"

#define SERVICE_PLAYER_UUID       "0000BB00-0000-1000-8000-00805F9B34FB"
#define CHAR_PLAYER_NAMES_UUID    "0000BB01-0000-1000-8000-00805F9B34FB"
#define CHAR_MATCH_CONFIG_UUID    "0000BB02-0000-1000-8000-00805F9B34FB"

// Variables globales
NimBLEServer* pServer = nullptr;
NimBLECharacteristic* pScoreUpdateChar = nullptr;
NimBLECharacteristic* pMatchStatusChar = nullptr;
NimBLECharacteristic* pBatteryInfoChar = nullptr;
NimBLECharacteristic* pPlayerNamesChar = nullptr;

String player1Name = "Joueur 1";
String player2Name = "Joueur 2";

// Callback pour réception de commandes
class CommandCallbacks: public NimBLECharacteristicCallbacks {
    void onWrite(NimBLECharacteristic* pCharacteristic) {
        std::string value = pCharacteristic->getValue();
        String command = String(value.c_str());
        
        Serial.println("📱 Commande reçue: " + command);
        
        if (command == "P1_ADD") {
            handlePlayerClick(1, false);
        }
        else if (command == "P1_REMOVE") {
            handlePlayerClick(1, true);
        }
        else if (command == "P2_ADD") {
            handlePlayerClick(2, false);
        }
        else if (command == "P2_REMOVE") {
            handlePlayerClick(2, true);
        }
        else if (command == "RESET") {
            resetMatch();
            notifyScoreUpdate();
        }
        else if (command == "RESET_GAME") {
            resetGame();
            notifyScoreUpdate();
        }
        else if (command == "GET_STATUS") {
            notifyScoreUpdate();
            notifyMatchStatus();
            notifyBatteryInfo();
        }
    }
};

// Callback pour réception des noms de joueurs
class PlayerNamesCallbacks: public NimBLECharacteristicCallbacks {
    void onWrite(NimBLECharacteristic* pCharacteristic) {
        std::string value = pCharacteristic->getValue();
        String names = String(value.c_str());
        
        int commaIndex = names.indexOf(',');
        if (commaIndex > 0) {
            player1Name = names.substring(0, commaIndex);
            player2Name = names.substring(commaIndex + 1);
            
            Serial.println("📝 Noms joueurs mis à jour:");
            Serial.println("   J1: " + player1Name);
            Serial.println("   J2: " + player2Name);
            
            displayScore();  // Rafraîchir l'affichage
        }
    }
};

// Initialisation du serveur BLE pour mobile
void setupBLEServer() {
    // Créer le serveur BLE
    pServer = NimBLEDevice::createServer();
    
    // Service Score Control
    NimBLEService* pScoreService = pServer->createService(SERVICE_SCORE_UUID);
    
    // Caractéristique Score Update (Read/Notify)
    pScoreUpdateChar = pScoreService->createCharacteristic(
        CHAR_SCORE_UPDATE_UUID,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY
    );
    
    // Caractéristique Command (Write)
    NimBLECharacteristic* pCommandChar = pScoreService->createCharacteristic(
        CHAR_COMMAND_UUID,
        NIMBLE_PROPERTY::WRITE
    );
    pCommandChar->setCallbacks(new CommandCallbacks());
    
    // Caractéristique Match Status (Read/Notify)
    pMatchStatusChar = pScoreService->createCharacteristic(
        CHAR_MATCH_STATUS_UUID,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY
    );
    
    // Caractéristique Battery Info (Read/Notify)
    pBatteryInfoChar = pScoreService->createCharacteristic(
        CHAR_BATTERY_INFO_UUID,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY
    );
    
    pScoreService->start();
    
    // Service Player Configuration
    NimBLEService* pPlayerService = pServer->createService(SERVICE_PLAYER_UUID);
    
    // Caractéristique Player Names (Read/Write)
    pPlayerNamesChar = pPlayerService->createCharacteristic(
        CHAR_PLAYER_NAMES_UUID,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::WRITE
    );
    pPlayerNamesChar->setCallbacks(new PlayerNamesCallbacks());
    
    // Caractéristique Match Config (Read/Write)
    NimBLECharacteristic* pMatchConfigChar = pPlayerService->createCharacteristic(
        CHAR_MATCH_CONFIG_UUID,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::WRITE
    );
    
    pPlayerService->start();
    
    // Démarrer l'advertising
    NimBLEAdvertising* pAdvertising = pServer->getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_SCORE_UUID);
    pAdvertising->addServiceUUID(SERVICE_PLAYER_UUID);
    pAdvertising->start();
    
    Serial.println("✅ Serveur BLE Mobile démarré");
}

// Notifier l'app mobile d'une mise à jour du score
void notifyScoreUpdate() {
    if (pScoreUpdateChar != nullptr) {
        String scoreData = String(player1.points) + "," + 
                          String(player1.games) + "," + 
                          String(player1.sets) + "," +
                          String(player2.points) + "," + 
                          String(player2.games) + "," + 
                          String(player2.sets);
        
        pScoreUpdateChar->setValue(scoreData.c_str());
        pScoreUpdateChar->notify();
    }
}

// Notifier l'app mobile du statut du match
void notifyMatchStatus() {
    if (pMatchStatusChar != nullptr) {
        String statusJson = "{";
        statusJson += "\"gameInProgress\":" + String(gameInProgress ? "true" : "false") + ",";
        statusJson += "\"isDeuce\":" + String(isDeuce ? "true" : "false") + ",";
        statusJson += "\"currentServer\":" + String(currentServer) + ",";
        statusJson += "\"matchTime\":" + String(millis() - matchStartTime) + ",";
        statusJson += "\"lastPointTime\":" + String(lastPointTime);
        statusJson += "}";
        
        pMatchStatusChar->setValue(statusJson.c_str());
        pMatchStatusChar->notify();
    }
}

// Notifier l'app mobile des niveaux de batterie
void notifyBatteryInfo() {
    if (pBatteryInfoChar != nullptr) {
        String batteryData = String(currentBatteryVoltage, 1) + "," +
                            String(currentBatteryPercentage) + "," +
                            String(player1.eTagBatteryLevel) + "," +
                            String(player2.eTagBatteryLevel);
        
        pBatteryInfoChar->setValue(batteryData.c_str());
        pBatteryInfoChar->notify();
    }
}
```

### Modifications dans setup()

```cpp
void setup() {
    // ... code existant ...
    
    // Initialiser le serveur BLE pour mobile (APRÈS NimBLEDevice::init())
    setupBLEServer();
    
    // ... reste du code ...
}
```

### Modifications dans loop()

```cpp
void loop() {
    // ... code existant ...
    
    // Notifier l'app mobile périodiquement
    static unsigned long lastNotifyTime = 0;
    if (millis() - lastNotifyTime > 1000) {  // Toutes les secondes
        notifyBatteryInfo();
        lastNotifyTime = millis();
    }
}
```

### Modifications dans addPoint()

```cpp
void addPoint(int playerNum) {
    // ... code existant ...
    
    // ✅ Notifier l'app mobile à chaque changement
    notifyScoreUpdate();
    notifyMatchStatus();
    
    // ... reste du code ...
}
```

## Roadmap d'Implémentation

### Phase 1: MVP (2-3 semaines)
- [ ] Configuration du projet Flutter/React Native
- [ ] Interface de connexion BLE
- [ ] Écran de contrôle de match basique
- [ ] Affichage score en temps réel
- [ ] Modifications ESP32 (services BLE)
- [ ] Base de données SQLite locale
- [ ] Sauvegarde match simple

### Phase 2: Fonctionnalités Core (2-3 semaines)
- [ ] Gestion complète des joueurs
- [ ] Historique des matchs
- [ ] Statistiques de base
- [ ] Configuration match avancée
- [ ] Interface settings
- [ ] Thème clair/sombre

### Phase 3: Analytics (1-2 semaines)
- [ ] Statistiques détaillées
- [ ] Graphiques d'évolution
- [ ] Head-to-Head comparaisons
- [ ] Export PDF/CSV
- [ ] Partage réseaux sociaux

### Phase 4: Polish (1 semaine)
- [ ] Optimisation performances
- [ ] Tests iOS/Android
- [ ] Gestion erreurs robuste
- [ ] Animations fluides
- [ ] Documentation utilisateur
- [ ] Publication stores

## Structure de Projet Flutter Recommandée

```
padel_mobile_app/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── player.dart
│   │   ├── match.dart
│   │   ├── match_set.dart
│   │   └── statistics.dart
│   ├── services/
│   │   ├── ble_service.dart
│   │   ├── database_service.dart
│   │   └── analytics_service.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── match_control_screen.dart
│   │   ├── players_screen.dart
│   │   ├── history_screen.dart
│   │   ├── statistics_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── score_display.dart
│   │   ├── player_card.dart
│   │   ├── match_card.dart
│   │   └── stat_chart.dart
│   └── utils/
│       ├── constants.dart
│       └── helpers.dart
├── pubspec.yaml
└── README.md
```

## Dépendances Flutter (pubspec.yaml)

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
  fl_chart: ^0.65.0
  
  # Utilitaires
  intl: ^0.18.1
  uuid: ^4.2.2
  share_plus: ^7.2.1
  pdf: ^3.10.7
  image_picker: ^1.0.5
  
  # Permissions
  permission_handler: ^11.1.0
```

## Prochaines Étapes

1. **Choix de la technologie**
   - Flutter recommandé (performance + BLE)
   - Alternative: React Native

2. **Setup projet**
   - Créer nouveau projet Flutter
   - Installer dépendances
   - Configurer permissions Android/iOS

3. **Développement ESP32**
   - Implémenter services BLE
   - Tester communication bidirectionnelle
   - Valider protocole

4. **MVP Mobile**
   - Connexion BLE
   - Affichage scores
   - Contrôle basique

5. **Itération**
   - Tester avec utilisateurs
   - Ajouter fonctionnalités
   - Optimiser UX

## Ressources

- [Flutter BLE Plus Documentation](https://pub.dev/packages/flutter_blue_plus)
- [ESP32 NimBLE Server Examples](https://github.com/h2zero/esp-nimble-cpp)
- [SQLite Flutter Guide](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [Material Design 3](https://m3.material.io/)
