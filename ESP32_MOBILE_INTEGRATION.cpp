/**
 * MODIFICATIONS POUR MAIN.CPP - Support Application Mobile
 * 
 * Ce fichier contient le code à ajouter dans main.cpp pour supporter
 * la communication avec l'application mobile via Bluetooth BLE.
 * 
 * INSTRUCTIONS D'INTEGRATION:
 * 1. Ajouter les includes en haut du fichier
 * 2. Ajouter les définitions UUID après les defines BLE existants
 * 3. Ajouter les variables globales après celles existantes
 * 4. Ajouter les classes de callback
 * 5. Ajouter les fonctions de notification
 * 6. Appeler setupBLEServer() dans setup()
 * 7. Appeler les fonctions de notification dans loop() et addPoint()
 */

// ============================================================================
// 1. INCLUDES (à ajouter en haut avec les autres includes)
// ============================================================================

#include <NimBLEServer.h>
#include <NimBLEService.h>
#include <NimBLECharacteristic.h>

// ============================================================================
// 2. DÉFINITIONS UUID (à ajouter après les defines BLE existants)
// ============================================================================

// UUIDs pour le service de contrôle de score
#define SERVICE_SCORE_UUID        "0000AA00-0000-1000-8000-00805F9B34FB"
#define CHAR_SCORE_UPDATE_UUID    "0000AA01-0000-1000-8000-00805F9B34FB"
#define CHAR_COMMAND_UUID         "0000AA02-0000-1000-8000-00805F9B34FB"
#define CHAR_MATCH_STATUS_UUID    "0000AA03-0000-1000-8000-00805F9B34FB"
#define CHAR_BATTERY_INFO_UUID    "0000AA04-0000-1000-8000-00805F9B34FB"

// UUIDs pour le service de configuration joueurs
#define SERVICE_PLAYER_UUID       "0000BB00-0000-1000-8000-00805F9B34FB"
#define CHAR_PLAYER_NAMES_UUID    "0000BB01-0000-1000-8000-00805F9B34FB"
#define CHAR_MATCH_CONFIG_UUID    "0000BB02-0000-1000-8000-00805F9B34FB"

// ============================================================================
// 3. VARIABLES GLOBALES (à ajouter après les variables globales existantes)
// ============================================================================

// Serveur BLE pour mobile
NimBLEServer* pServer = nullptr;
NimBLECharacteristic* pScoreUpdateChar = nullptr;
NimBLECharacteristic* pMatchStatusChar = nullptr;
NimBLECharacteristic* pBatteryInfoChar = nullptr;
NimBLECharacteristic* pPlayerNamesChar = nullptr;
NimBLECharacteristic* pCommandChar = nullptr;

// Noms des joueurs (personnalisables depuis l'app)
String player1Name = "Joueur 1";
String player2Name = "Joueur 2";

// État de connexion mobile
bool mobileConnected = false;
unsigned long lastMobileNotify = 0;
#define MOBILE_NOTIFY_INTERVAL 1000  // Notifications toutes les 1s

// ============================================================================
// 4. CLASSES DE CALLBACK (à ajouter avant setup())
// ============================================================================

/**
 * Callback pour détecter connexion/déconnexion de l'app mobile
 */
class MobileServerCallbacks: public NimBLEServerCallbacks {
    void onConnect(NimBLEServer* pServer) {
        mobileConnected = true;
        Serial.println("📱 Application mobile connectée");
    }
    
    void onDisconnect(NimBLEServer* pServer) {
        mobileConnected = false;
        Serial.println("📱 Application mobile déconnectée");
        
        // Redémarrer l'advertising
        pServer->startAdvertising();
    }
};

/**
 * Callback pour réception de commandes depuis l'app mobile
 */
class CommandCallbacks: public NimBLECharacteristicCallbacks {
    void onWrite(NimBLECharacteristic* pCharacteristic) {
        std::string value = pCharacteristic->getValue();
        String command = String(value.c_str());
        
        Serial.println("📱 Commande reçue: " + command);
        
        if (command == "P1_ADD") {
            addPoint(1);
        }
        else if (command == "P1_REMOVE") {
            // Retirer un point au joueur 1
            if (player1.points > 0) {
                player1.points--;
                displayScore();
                notifyScoreUpdate();
            }
        }
        else if (command == "P2_ADD") {
            addPoint(2);
        }
        else if (command == "P2_REMOVE") {
            // Retirer un point au joueur 2
            if (player2.points > 0) {
                player2.points--;
                displayScore();
                notifyScoreUpdate();
            }
        }
        else if (command == "RESET") {
            resetMatch();
            displayScore();
            notifyScoreUpdate();
            notifyMatchStatus();
        }
        else if (command == "RESET_GAME") {
            resetGame();
            displayScore();
            notifyScoreUpdate();
            notifyMatchStatus();
        }
        else if (command == "GET_STATUS") {
            // Envoyer toutes les données immédiatement
            notifyScoreUpdate();
            notifyMatchStatus();
            notifyBatteryInfo();
        }
    }
};

/**
 * Callback pour réception des noms de joueurs
 */
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
            
            // Rafraîchir l'affichage avec les nouveaux noms
            // Note: Pour afficher les noms sur LED, il faudra modifier displayScore()
            displayScore();
        }
    }
};

// ============================================================================
// 5. FONCTION D'INITIALISATION DU SERVEUR BLE (à ajouter avant setup())
// ============================================================================

/**
 * Initialise le serveur BLE pour communication avec l'app mobile
 * À appeler APRÈS NimBLEDevice::init() dans setup()
 */
void setupBLEServer() {
    Serial.println("🔧 Initialisation serveur BLE mobile...");
    
    // Créer le serveur BLE
    pServer = NimBLEDevice::createServer();
    pServer->setCallbacks(new MobileServerCallbacks());
    
    // ========== SERVICE SCORE CONTROL ==========
    NimBLEService* pScoreService = pServer->createService(SERVICE_SCORE_UUID);
    
    // Caractéristique Score Update (Read/Notify)
    pScoreUpdateChar = pScoreService->createCharacteristic(
        CHAR_SCORE_UPDATE_UUID,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY
    );
    pScoreUpdateChar->setValue("0,0,0,0,0,0");  // Valeur initiale
    
    // Caractéristique Command (Write)
    pCommandChar = pScoreService->createCharacteristic(
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
    
    // ========== SERVICE PLAYER CONFIGURATION ==========
    NimBLEService* pPlayerService = pServer->createService(SERVICE_PLAYER_UUID);
    
    // Caractéristique Player Names (Read/Write)
    pPlayerNamesChar = pPlayerService->createCharacteristic(
        CHAR_PLAYER_NAMES_UUID,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::WRITE
    );
    pPlayerNamesChar->setCallbacks(new PlayerNamesCallbacks());
    pPlayerNamesChar->setValue("Joueur 1,Joueur 2");  // Valeur par défaut
    
    // Caractéristique Match Config (Read/Write) - Pour future utilisation
    NimBLECharacteristic* pMatchConfigChar = pPlayerService->createCharacteristic(
        CHAR_MATCH_CONFIG_UUID,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::WRITE
    );
    
    pPlayerService->start();
    
    // ========== DÉMARRER L'ADVERTISING ==========
    NimBLEAdvertising* pAdvertising = pServer->getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_SCORE_UUID);
    pAdvertising->addServiceUUID(SERVICE_PLAYER_UUID);
    pAdvertising->setScanResponse(true);
    pAdvertising->setMinPreferred(0x06);  // iPhone connections
    pAdvertising->setMaxPreferred(0x12);
    pAdvertising->start();
    
    Serial.println("✅ Serveur BLE Mobile démarré");
    Serial.println("   Nom: " + String(NimBLEDevice::getAddress().toString().c_str()));
}

// ============================================================================
// 6. FONCTIONS DE NOTIFICATION (à ajouter avant setup())
// ============================================================================

/**
 * Notifie l'app mobile d'une mise à jour du score
 * Format: "P1_points,P1_games,P1_sets,P2_points,P2_games,P2_sets"
 */
void notifyScoreUpdate() {
    if (pScoreUpdateChar == nullptr || !mobileConnected) return;
    
    String scoreData = String(player1.points) + "," + 
                      String(player1.games) + "," + 
                      String(player1.sets) + "," +
                      String(player2.points) + "," + 
                      String(player2.games) + "," + 
                      String(player2.sets);
    
    pScoreUpdateChar->setValue(scoreData.c_str());
    pScoreUpdateChar->notify();
    
    Serial.println("📤 Score envoyé: " + scoreData);
}

/**
 * Notifie l'app mobile du statut du match
 * Format JSON
 */
void notifyMatchStatus() {
    if (pMatchStatusChar == nullptr || !mobileConnected) return;
    
    String statusJson = "{";
    statusJson += "\"gameInProgress\":" + String(gameInProgress ? "true" : "false") + ",";
    statusJson += "\"isDeuce\":" + String(isDeuce ? "true" : "false") + ",";
    statusJson += "\"currentServer\":" + String(currentServer) + ",";
    statusJson += "\"matchTime\":" + String(matchStartTime > 0 ? (millis() - matchStartTime) : 0) + ",";
    statusJson += "\"lastPointTime\":" + String(lastPointTime);
    statusJson += "}";
    
    pMatchStatusChar->setValue(statusJson.c_str());
    pMatchStatusChar->notify();
    
    Serial.println("📤 Statut envoyé");
}

/**
 * Notifie l'app mobile des niveaux de batterie
 * Format: "system_voltage,system_percent,etag1_percent,etag2_percent"
 */
void notifyBatteryInfo() {
    if (pBatteryInfoChar == nullptr || !mobileConnected) return;
    
    String batteryData = String(currentBatteryVoltage, 1) + "," +
                        String(currentBatteryPercentage) + "," +
                        String(player1.eTagBatteryLevel) + "," +
                        String(player2.eTagBatteryLevel);
    
    pBatteryInfoChar->setValue(batteryData.c_str());
    pBatteryInfoChar->notify();
    
    Serial.println("📤 Batterie envoyée: " + batteryData);
}

// ============================================================================
// 7. MODIFICATIONS DANS SETUP() 
// ============================================================================

/*
Dans la fonction setup(), APRÈS l'initialisation BLE existante:

void setup() {
    // ... code existant ...
    
    // Initialisation BLE existante
    NimBLEDevice::init("PadelDisplay");
    // ... scan et connexion eTags ...
    
    // ✅ AJOUTER CET APPEL ICI:
    setupBLEServer();  // Initialiser serveur BLE pour mobile
    
    // ... reste du code ...
}
*/

// ============================================================================
// 8. MODIFICATIONS DANS LOOP()
// ============================================================================

/*
Dans la fonction loop(), ajouter ces notifications périodiques:

void loop() {
    // ... code existant ...
    
    // ✅ AJOUTER CE BLOC:
    // Notifier l'app mobile périodiquement (si connectée)
    if (mobileConnected && (millis() - lastMobileNotify > MOBILE_NOTIFY_INTERVAL)) {
        notifyBatteryInfo();
        notifyMatchStatus();
        lastMobileNotify = millis();
    }
    
    // ... reste du code ...
}
*/

// ============================================================================
// 9. MODIFICATIONS DANS ADDPOINT()
// ============================================================================

/*
Dans la fonction addPoint(), APRÈS tout changement de score, ajouter:

void addPoint(int playerNum) {
    // ... code existant de gestion des points ...
    
    // Afficher le nouveau score
    displayScore();
    
    // ✅ AJOUTER CES APPELS:
    // Notifier l'app mobile
    notifyScoreUpdate();
    notifyMatchStatus();
}
*/

// ============================================================================
// 10. EXEMPLE D'INTÉGRATION COMPLÈTE DANS SETUP()
// ============================================================================

/*
void setup() {
    Serial.begin(115200);
    delay(1000);
    
    Serial.println("\n═══════════════════════════════════════════════");
    Serial.println("   🎾 AFFICHEUR PADEL - ESP32 + LED P5 HUB75");
    Serial.println("═══════════════════════════════════════════════\n");
    
    // Configuration des pins
    HUB75_I2S_CFG mxconfig(
        PANEL_RES_X,
        PANEL_RES_Y,
        PANEL_CHAIN
    );
    
    mxconfig.gpio.r1 = R1_PIN;
    mxconfig.gpio.g1 = G1_PIN;
    mxconfig.gpio.b1 = B1_PIN;
    mxconfig.gpio.r2 = R2_PIN;
    mxconfig.gpio.g2 = G2_PIN;
    mxconfig.gpio.b2 = B2_PIN;
    mxconfig.gpio.a = A_PIN;
    mxconfig.gpio.b = B_PIN;
    mxconfig.gpio.c = C_PIN;
    mxconfig.gpio.d = D_PIN;
    mxconfig.gpio.e = E_PIN;
    mxconfig.gpio.lat = LAT_PIN;
    mxconfig.gpio.oe = OE_PIN;
    mxconfig.gpio.clk = CLK_PIN;
    
    dma_display = new MatrixPanel_I2S_DMA(mxconfig);
    dma_display->begin();
    dma_display->setBrightness8(90);
    dma_display->clearScreen();
    
    // Initialiser les joueurs
    initPlayer(player1);
    initPlayer(player2);
    
    // Initialiser BLE
    Serial.println("🔧 Initialisation Bluetooth...");
    NimBLEDevice::init("PadelDisplay");
    NimBLEDevice::setPower(ESP_PWR_LVL_P9);
    
    // ✅✅✅ AJOUTER ICI ✅✅✅
    setupBLEServer();  // Serveur pour app mobile
    
    // Scanner les eTags
    pBLEScan = NimBLEDevice::getScan();
    // ... reste du scan ...
    
    Serial.println("\n✅ Initialisation terminée!");
    displayScore();
}
*/

// ============================================================================
// 11. NOTES IMPORTANTES
// ============================================================================

/*
POINTS IMPORTANTS:

1. COMPATIBILITÉ:
   - Ce code utilise NimBLE (déjà présent dans votre projet)
   - Pas de conflits avec le scan des eTags existant
   - Les deux fonctionnent en parallèle

2. PERFORMANCE:
   - Les notifications sont limitées à 1x/seconde max
   - Pas d'impact sur l'affichage LED
   - Consommation mémoire minimale

3. SÉCURITÉ:
   - Pas d'authentification BLE (optionnel pour futur)
   - Portée limitée au Bluetooth (~10m)

4. DEBUGGING:
   - Tous les messages BLE sont loggés sur Serial
   - Format: "📱" pour mobile, "🔍" pour scan, "📤" pour envoi

5. EXTENSIBILITÉ:
   - Facile d'ajouter d'autres commandes
   - Facile d'ajouter d'autres caractéristiques
   - Configuration match future prête (CHAR_MATCH_CONFIG_UUID)

6. TEST:
   - Tester d'abord sans app mobile (vérifier logs Serial)
   - Puis tester connexion simple
   - Enfin tester envoi/réception commandes

7. ADVERTISING NAME:
   Pour changer le nom visible de l'ESP32, modifier dans NimBLEDevice::init():
   
   NimBLEDevice::init("PadelDisplay-Court1");  // Nom personnalisé
*/
