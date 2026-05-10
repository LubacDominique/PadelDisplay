/**
 * Afficheur de Score de Padel - ESP32 + LED P5 HUB75
 * 
 * Gère l'affichage des scores d'une partie de padel sur un panneau LED RGB
 * Contrôle sans fil via 2 eTags BLE (1 clic = +1 point, 2 clics = -1 point)
 * 
 * Matériel:
 * - ESP32 DevKit 30 broches (CH340C)
 * - Panneau LED P5 32x64 pixels HUB75 (320x160mm, scan 1/16)
 * - 2x eTags BLE avec bouton
 * - Alimentation 5V 4A pour panneau LED
 * 
 * @version 1.0
 * @date 2026-04-01
 */

#include <Arduino.h>
#include <WiFi.h>
#include <ESP32-HUB75-MatrixPanel-I2S-DMA.h>
#include <NimBLEDevice.h>
#include <NimBLEUtils.h>
#include <NimBLEScan.h>
#include <NimBLEAdvertisedDevice.h>
#include <SPIFFS.h>
#include <PNGdec.h>

// ============================================================================
// CONFIGURATION DU PANNEAU LED HUB75
// ============================================================================

#define PANEL_RES_X 64    // Largeur: 64 pixels
#define PANEL_RES_Y 32    // Hauteur: 32 pixels
#define PANEL_CHAIN 1     // Nombre de panneaux chaînés

// Configuration HUB75 personnalisée pour ESP32 30 broches
#define R1_PIN 25
#define G1_PIN 26
#define B1_PIN 27
#define R2_PIN 14
#define G2_PIN 12
#define B2_PIN 13
#define A_PIN  23
#define B_PIN  19
#define C_PIN  5
#define D_PIN  17
#define E_PIN  18  // Nécessaire pour scan 1/16
#define LAT_PIN 4
#define OE_PIN  15
#define CLK_PIN 16

// ============================================================================
// CONFIGURATION BLUETOOTH BLE
// ============================================================================

// Durée du scan BLE (secondes)
#define BLE_SCAN_DURATION 5

// Délai pour détecter un double-clic (millisecondes)
#define DOUBLE_CLICK_DELAY 400

// Délai anti-rebond pour ignorer les clics multiples du BLE (millisecondes)
#define DEBOUNCE_DELAY 100

// Adresses MAC des eTags (à modifier selon vos appareils)
// Format: "xx:xx:xx:xx:xx:xx" (MINUSCULES obligatoires)
// Laisser vide pour auto-détection des premiers iTags trouvés
String PLAYER1_MAC = "ff:ff:a0:04:cc:1f";  // eTag Joueur 1 (gauche)
String PLAYER2_MAC = "ff:ff:a0:04:a6:63";  // eTag Joueur 2 (droite)

// UUIDs des services BLE (iTags standards)
static NimBLEUUID serviceUUID("0000ffe0-0000-1000-8000-00805f9b34fb");
static NimBLEUUID charUUID("0000ffe1-0000-1000-8000-00805f9b34fb");

// ============================================================================
// CONFIGURATION MESURE BATTERIE LiFePO4 12.8V 20Ah (3S)
// ============================================================================

// Pin ADC pour mesure batterie (GPIO uniquement ADC1: 32, 33, 34, 35, 36, 39)
#define BATTERY_PIN 35

// Caractéristiques batterie LiFePO4 3S (3 cellules × 3.2V nominal)
#define BATTERY_MAX_VOLTAGE 12.2  // Voltage max chargé (3 × 4.6V) = 100%
#define BATTERY_NOM_VOLTAGE 12   // Voltage nominal (3 × 3.2V + stabilisateur)
#define BATTERY_MIN_VOLTAGE 9.5    // Voltage min déchargé (3 × 3.0V) = 0%

// Pont diviseur de tension: R1=100kΩ, R2=30kΩ → ratio 4.33:1
// Formule: Vout = Vin × (R2 / (R1 + R2)) = Vin × (30k / 130k) = Vin / 4.333
// 12.2V → 2.82V (⚠️ proche limite ADC 3.3V)
// 12.0V → 2.77V (nominal)
// 9.5V  → 2.19V  (min détectable)
#define VOLTAGE_DIVIDER 4.333      // Rapport du diviseur (100kΩ + 30kΩ) / 30kΩ

// Paramètres de mesure
#define BATTERY_SAMPLES 10          // Nombre d'échantillons pour moyenne
#define BATTERY_UPDATE_INTERVAL 5000  // Mise à jour toutes les 5 secondes

// ============================================================================
// VARIABLES GLOBALES
// ============================================================================

// Objet pour contrôler le panneau LED
MatrixPanel_I2S_DMA *dma_display = nullptr;

// Structure pour gérer le score d'un joueur
struct Player {
    int points;         // Points dans le jeu actuel (0, 1, 2, 3, 4+)
    int games;          // Jeux gagnés dans le set actuel
    int sets;           // Sets gagnés
    bool hasAdvantage;  // True si le joueur a l'avantage après deuce
    unsigned long lastClickTime;  // Timestamp du dernier clic
    int clickCount;     // Compteur de clics pour détection double-clic
    bool pendingClick;  // True si un clic est en attente de confirmation (pas de double-clic)
    NimBLEAddress* bleAddress;  // Adresse BLE du tag
    NimBLEClient* bleClient;    // Client BLE
    NimBLERemoteCharacteristic* bleCharacteristic;  // Caractéristique BLE pour notifications
    bool connected;     // État de connexion BLE
};

Player player1;
Player player2;

// État du jeu
bool isDeuce = false;           // Égalité à 40-40
bool gameInProgress = true;     // Partie en cours
String lastMessage = "";        // Dernier message affiché
bool waitingForSetContinue = false;  // Attend un clic pour continuer après victoire de set
int currentServer = 1;          // Joueur qui sert actuellement (1 ou 2)

// BLE Scan
NimBLEScan* pBLEScan;
bool bleScanning = false;
unsigned long lastBleScanTime = 0;
const unsigned long BLE_RECONNECT_INTERVAL = 10000; // 10 secondes
NimBLEAddress* discoveredPlayer1Address = nullptr;
NimBLEAddress* discoveredPlayer2Address = nullptr;

// Mesure batterie
float currentBatteryVoltage = 0.0;
int currentBatteryPercentage = 0;
unsigned long lastBatteryReadTime = 0;

// État des alertes de connexion
unsigned long lastConnLossTime = 0;
int lastConnLossPlayer = 0;
#define CONN_LOSS_MSG_DURATION 3000 // Durée du message d'alerte en ms

// État des indicateurs visuels (V1.1 Roadmap)
unsigned long matchStartTime = 0;
unsigned long lastPointTime = 0;
#define POINT_TIMER_WARN 20 // Temps d'alerte orange en secondes (règle des 20-25s)

// Objet PNG decoder
PNG png;

// Buffer pour l'image Set_RGB.png (64x32 pixels)
uint16_t setImageBuffer[64 * 32];
int bufferLineIndex = 0;  // Index de ligne pour remplir le buffer

// ============================================================================
// DÉCLARATIONS FORWARD DES FONCTIONS
// ============================================================================

void displayScore(bool showServiceChange = true);
void displayGameWon(int playerNum);
void displaySetWon(int playerNum);
void displayMatchWon(int playerNum);
void displaySetImage();
void displayBallServiceChange(int fromPlayer, int toPlayer);
void checkGameWon();
void checkSetWon();
void checkMatchWon();
float getBatteryVoltage();
int getBatteryPercentage();
void checkConnLossAlert();
void updateBatteryLevel();
void displayBatteryLevel(int x, int y);

// ============================================================================
// COULEURS RGB565 POUR LE PANNEAU LED
// ============================================================================

uint16_t COLOR_RED     = 0xF800;  // Rouge pur
uint16_t COLOR_GREEN   = 0x07E0;  // Vert pur
uint16_t COLOR_BLUE    = 0x001F;  // Bleu pur
uint16_t COLOR_YELLOW  = 0xFFE0;  // Jaune
uint16_t COLOR_WHITE   = 0xFFFF;  // Blanc
uint16_t COLOR_ORANGE  = 0xFD20;  // Orange
uint16_t COLOR_CYAN    = 0x07FF;  // Cyan

// ============================================================================
// FONCTIONS UTILITAIRES
// ============================================================================

/**
 * Convertit RGB (0-255) en couleur RGB565 pour le panneau LED
 */
uint16_t rgb565(uint8_t r, uint8_t g, uint8_t b) {
    return ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3);
}

/**
 * Initialise le score d'un joueur
 */
void initPlayer(Player &player) {
    player.points = 0;
    player.games = 0;
    player.sets = 0;
    player.hasAdvantage = false;
    player.lastClickTime = 0;
    player.clickCount = 0;
    player.pendingClick = false;
    player.bleAddress = nullptr;
    player.bleClient = nullptr;
    player.bleCharacteristic = nullptr;
    player.connected = false;
}

/**
 * Réinitialise les scores pour un nouveau match
 */
void resetMatch() {
    initPlayer(player1);
    initPlayer(player2);
    isDeuce = false;
    gameInProgress = true;
    lastPointTime = millis();
    matchStartTime = millis();
    lastPointTime = 0;
    matchStartTime = 0;
    waitingForSetContinue = false;
    currentServer = 1;  // Le joueur 1 commence à servir
    Serial.println("Match réinitialisé");
}

/**
 * Réinitialise uniquement le jeu en cours
 */
void resetGame() {
    player1.points = 0;
    player2.points = 0;
    player1.hasAdvantage = false;
    player2.hasAdvantage = false;
    isDeuce = false;
}

// ============================================================================
// GESTION BATTERIE LiFePO4
// ============================================================================

/**
 * Mesure la tension de la batterie avec moyenne de plusieurs échantillons
 * @return Tension en Volts (float)
 */
float getBatteryVoltage() {
    long sum = 0;
    
    // Prendre plusieurs échantillons pour stabilité
    for (int i = 0; i < BATTERY_SAMPLES; i++) {
        sum += analogRead(BATTERY_PIN);
        delayMicroseconds(100);  // Petit délai entre lectures
    }
    
    // Moyenne des échantillons
    float adcValue = sum / (float)BATTERY_SAMPLES;
    
    // Conversion ADC (12-bit: 0-4095) vers voltage
    // ESP32 ADC: 0-4095 correspond à 0-3.3V
    // Avec atténuation 11dB: plage effective 0-2.6V (mais on utilise 0-3.3V comme référence)
    float adcVoltage = (adcValue / 4095.0) * 3.3;
    
    // Appliquer le facteur du diviseur de tension
    float batteryVoltage = adcVoltage * VOLTAGE_DIVIDER;
    
    return batteryVoltage;
}

/**
 * Calcule le pourcentage de charge de la batterie
 * Utilise une courbe de décharge linéaire pour LiFePO4
 * @return Pourcentage (0-100)
 */
int getBatteryPercentage() {
    float voltage = currentBatteryVoltage;
    
    // Calcul linéaire du pourcentage
    float percentage = ((voltage - BATTERY_MIN_VOLTAGE) / 
                       (BATTERY_MAX_VOLTAGE - BATTERY_MIN_VOLTAGE)) * 100.0;
    
    // Limiter entre 0-100%
    if (percentage > 100) percentage = 100;
    if (percentage < 0) percentage = 0;
    
    return (int)percentage;
}

/**
 * Met à jour les valeurs de batterie (appelé périodiquement)
 */
void updateBatteryLevel() {
    unsigned long now = millis();
    
    // Mise à jour uniquement si intervalle écoulé
    if (now - lastBatteryReadTime >= BATTERY_UPDATE_INTERVAL) {
        currentBatteryVoltage = getBatteryVoltage();
        currentBatteryPercentage = getBatteryPercentage();
        lastBatteryReadTime = now;
        
        // Affichage sur Serial pour debugging
        Serial.printf("[Batterie] Voltage: %.2fV | Charge: %d%% | ADC: %d\n", 
                     currentBatteryVoltage, 
                     currentBatteryPercentage,
                     analogRead(BATTERY_PIN));
        
        // Alerte batterie faible
        if (currentBatteryPercentage < 20 && currentBatteryPercentage > 0) {
            Serial.println("⚠️  ATTENTION: Batterie faible!");
        }
        if (currentBatteryPercentage < 10 && currentBatteryPercentage > 0) {
            Serial.println("🔴 CRITIQUE: Batterie très faible! Rechargez immédiatement.");
        }
    }
}

/**
 * Affiche l'indicateur de batterie sur le panneau LED
 * Format: icône + pourcentage
 */
void displayBatteryLevel(int x, int y) {
    if (x < 0 || y < 0) return;

    dma_display->setTextSize(1);
    
    // Couleur selon niveau de charge
    uint16_t color;
    if (currentBatteryPercentage >= 75) {
        color = COLOR_GREEN;       // Vert: ≥75%
    } else if (currentBatteryPercentage >= 50) {
        color = COLOR_CYAN;        // Cyan: 50-74%
    } else if (currentBatteryPercentage >= 25) {
        color = COLOR_YELLOW;      // Jaune: 25-49%
    } else if (currentBatteryPercentage >= 10) {
        color = COLOR_ORANGE;      // Orange: 10-24%
    } else {
        color = COLOR_RED;         // Rouge: <10%
    }
    
    // Icône batterie simple (rectangle)
    dma_display->drawRect(x, y, 8, 4, color);      // Corps batterie
    dma_display->drawPixel(x + 8, y + 1, color);   // Borne +
    dma_display->drawPixel(x + 8, y + 2, color);
    
    // Remplissage selon niveau (4 barres)
    int bars = map(currentBatteryPercentage, 0, 100, 0, 4);
    for (int i = 0; i < bars && i < 4; i++) {
        dma_display->drawLine(x + 2 + i, y + 1, x + 2 + i, y + 2, color);
    }
    
}

// ============================================================================
// AFFICHAGE SUR PANNEAU LED
// ============================================================================

/**
 * Efface l'écran
 */
void clearDisplay() {
    dma_display->fillScreen(dma_display->color444(0, 0, 0));
}

/**
 * Affiche un message centré
 */
void displayMessage(String message, uint16_t color) {
    clearDisplay();
    
    int16_t x1, y1;
    uint16_t w, h;
    dma_display->setTextSize(1);
    dma_display->getTextBounds(message, 0, 0, &x1, &y1, &w, &h);
    
    int x = (PANEL_RES_X - w) / 2;
    int y = (PANEL_RES_Y - h) / 2;
    
    dma_display->setCursor(x, y);
    dma_display->setTextColor(color);
    dma_display->print(message);
}

/**
 * Convertit les points en notation tennis (0, 15, 30, 40, ADV)
 */
String getPointsDisplay(Player &player, Player &opponent) {
    if (isDeuce) {
        if (player.hasAdvantage) {
            return "AV";
        } else if (opponent.hasAdvantage) {
            return "40";
        } else {
            return "40";  // Deuce
        }
    }
    
    switch (player.points) {
        case 0: return " 0";
        case 1: return "15";
        case 2: return "30";
        case 3: return "40";
        default: return "40";
    }
}

/**
 * Affiche le score actuel
 */
void displayScore(bool showServiceChange) {
     // Si showServiceChange est true, afficher une animation de service
    clearDisplay();
    int16_t y=1;
    String p1Score = getPointsDisplay(player1, player2);
    String p2Score = getPointsDisplay(player2, player1);
    
    // Affichage des points (ligne du haut)
    dma_display->setTextSize(2);
    
    // Score joueur 1 (gauche)
    dma_display->setCursor(2, y);
    dma_display->setTextColor(COLOR_RED);
    dma_display->print(p1Score);
    
    // Séparateur
    dma_display->setCursor(26, y);
    dma_display->setTextColor(COLOR_WHITE);
    dma_display->print("-");
    
    // Score joueur 2 (droite)
    int p2X = (p2Score.length() > 2) ? 34 : 38;  // Ajustement pour "ADV" ou "AV"
    dma_display->setCursor(p2X, y);
    dma_display->setTextColor(COLOR_GREEN);
    dma_display->print(p2Score);

    // 1. Barres de progression du jeu (V1.1 Roadmap)
    // Progression Joueur 1
    int p1ProgW = 22;
    dma_display->drawRect(2, 17, p1ProgW, 2, rgb565(40, 40, 40)); // Fond gris
    int p1Val = player1.hasAdvantage ? 3 : player1.points;
    if (p1Val > 0) {
        int prog = map(min(p1Val, 3), 0, 3, 0, p1ProgW - 2);
        dma_display->fillRect(3, 18, prog, 1, COLOR_RED);
    }
    
    // Progression Joueur 2
    int p2ProgW = 22;
    dma_display->drawRect(40, 17, p2ProgW, 2, rgb565(40, 40, 40)); // Fond gris
    int p2Val = player2.hasAdvantage ? 3 : player2.points;
    if (p2Val > 0) {
        int prog = map(min(p2Val, 3), 0, 3, 0, p2ProgW - 2);
        dma_display->fillRect(41, 18, prog, 1, COLOR_GREEN);
    }
    
    // Affichage des jeux (ligne du bas)
    dma_display->setTextSize(1);
    
    // Jeux joueur 1
    dma_display->setCursor(5, 24);
    dma_display->setTextColor(COLOR_YELLOW);
    dma_display->print(player1.games);
    
    // Jeux joueur 2
    dma_display->setCursor(53, 24);
    dma_display->setTextColor(COLOR_YELLOW);
    dma_display->print(player2.games);
    
    // 2. Timer entre les points (V1.1 Roadmap)
    if (lastPointTime > 0 && !waitingForSetContinue && gameInProgress) {
        unsigned long seconds = (millis() - lastPointTime) / 1000;
        if (seconds < 100) {
            dma_display->setTextSize(1); // Taille de texte 1 (8 pixels de haut)
            dma_display->setCursor(28, 14); // Positionné entre les barres de progression (y=17) et les jeux (y=22)
            dma_display->setTextColor(seconds >= POINT_TIMER_WARN ? COLOR_ORANGE : COLOR_WHITE);
            if (seconds < 10) dma_display->print("0");
            dma_display->print(seconds);
        }
    }

    // 3. Chronomètre de match (V1.2 Roadmap)
    if (matchStartTime > 0 && gameInProgress) {
        unsigned long totalSeconds = (millis() - matchStartTime) / 1000;
        int mins = totalSeconds / 60;
        int secs = totalSeconds % 60;
        char timeStr[8];
        if (mins < 100) sprintf(timeStr, "%02d:%02d", mins, secs);
        else sprintf(timeStr, "%d:%02d", mins, secs);
        dma_display->setCursor(17, 21);
        dma_display->setTextColor(COLOR_CYAN);
        dma_display->print(timeStr);
    }

    // Indicateurs de connexion BLE (petits points)
    if (player1.connected) {
        dma_display->fillCircle(1, 30, 1, COLOR_CYAN);
    } else {
        // Clignotement rouge si déconnecté (toutes les 500ms)
        if ((millis() / 500) % 2 == 0) dma_display->fillCircle(1, 30, 1, COLOR_RED);
    }

    if (player2.connected) {
        dma_display->fillCircle(62, 30, 1, COLOR_CYAN);
    } else {
        if ((millis() / 500) % 2 == 0) dma_display->fillCircle(62, 30, 1, COLOR_RED);
    }
    
    // Indicateur de service: petite balle à côté du score du serveur
    if(showServiceChange) {
        if (currentServer == 1) {
            dma_display->fillCircle(2, PANEL_RES_Y / 2+2, 2, COLOR_YELLOW);  // Balle jaune à gauche
        } else {
            dma_display->fillCircle(61, PANEL_RES_Y / 2+2, 2, COLOR_YELLOW);  // Balle jaune à droite
        }
    }
    
    // Affichage du niveau de batterie
    displayBatteryLevel(28, 28);
}

/**
 * Callback pour le décodage PNG - dessine chaque pixel sur le panneau LED
 */
int PNGDraw(PNGDRAW *pDraw) {
    uint16_t lineBuffer[PANEL_RES_X];
    png.getLineAsRGB565(pDraw, lineBuffer, PNG_RGB565_BIG_ENDIAN, 0xffffffff);
    
    // Centrer l'image si elle est plus petite que l'écran
    int offsetX = (PANEL_RES_X - png.getWidth()) / 2;
    int offsetY = (PANEL_RES_Y - png.getHeight()) / 2;
    
    // Debug TOUTES les lignes
    Serial.printf("Ligne %d/%d - offset X=%d Y=%d\n", pDraw->y, png.getHeight()-1, offsetX, offsetY);
    
    for (int x = 0; x < png.getWidth(); x++) {
        int displayX = x + offsetX;
        int displayY = pDraw->y + offsetY;
        
        if (displayX >= 0 && displayX < PANEL_RES_X && 
            displayY >= 0 && displayY < PANEL_RES_Y) {
            dma_display->drawPixel(displayX, displayY, lineBuffer[x]);
        }
    }
    
    return 1; // Continue le décodage
}

/**
 * Callback pour ouvrir un fichier depuis SPIFFS
 */
void * myOpen(const char *filename, int32_t *size) {
    File *f = new File(SPIFFS.open(filename, "r"));
    if (f && *f) {
        *size = f->size();
        return (void *)f;
    }
    delete f;
    return NULL;
}

/**
 * Callback pour fermer un fichier
 */
void myClose(void *handle) {
    if (handle) {
        File *f = (File *)handle;
        f->close();
        delete f;
    }
}

/**
 * Callback pour lire depuis un fichier
 */
int32_t myRead(PNGFILE *handle, uint8_t *buffer, int32_t length) {
    if (!handle)
        return 0;
    File *f = (File *)handle->fHandle;
    return f->read(buffer, length);
}

/**
 * Callback pour se positionner dans un fichier
 */
int32_t mySeek(PNGFILE *handle, int32_t position) {
    if (!handle)
        return 0;
    File *f = (File *)handle->fHandle;
    return f->seek(position);
}

/**
 * Callback pour décoder Set_RGB.png dans un buffer (pour drawRGBBitmap)
 */
int pngDrawToBuffer(PNGDRAW *pDraw) {
    int y = pDraw->y;
    uint8_t *src = (uint8_t *)pDraw->pPixels;
    
    // Détecter le format selon bpp
    if (pDraw->iBpp == 24) {
        // RGB888 - 3 bytes par pixel
        for (int x = 0; x < pDraw->iWidth; x++) {
            uint8_t r = src[x * 3];
            uint8_t g = src[x * 3 + 1];
            uint8_t b = src[x * 3 + 2];
            setImageBuffer[y * 64 + x] = ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3);
        }
    } else if (pDraw->iBpp == 16) {
        // RGB565 - 2 bytes par pixel
        uint16_t *src16 = (uint16_t *)pDraw->pPixels;
        for (int x = 0; x < pDraw->iWidth; x++) {
            setImageBuffer[y * 64 + x] = src16[x];
        }
    } else {
        // Autre format (8-bit palette) - considérer comme RGB888
        for (int x = 0; x < pDraw->iWidth; x++) {
            uint8_t r = src[x * 3];
            uint8_t g = src[x * 3 + 1];
            uint8_t b = src[x * 3 + 2];
            setImageBuffer[y * 64 + x] = ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3);
        }
    }
    
    return 1;
}

/**
 * Affiche l'image Set_RGB.png depuis SPIFFS
 */
void displaySetImage() {
    Serial.println("Début affichage Set_RGB.png...");
    clearDisplay();
    
    // Réinitialiser le buffer
    memset(setImageBuffer, 0, sizeof(setImageBuffer));
    bufferLineIndex = 0;
    
    // Ouvrir et décoder le PNG dans le buffer
    int rc = png.open("/Set_RGB.png", myOpen, myClose, myRead, mySeek, pngDrawToBuffer);
    if (rc == PNG_SUCCESS) {
        Serial.printf("Image Set_RGB.png: %d x %d pixels\n", png.getWidth(), png.getHeight());
        
        // Décoder (format RGB888 par défaut pour palette)
        rc = png.decode(NULL, 0);
        png.close();
        
        if (rc == PNG_SUCCESS) {
            Serial.println("PNG décodé avec succès, affichage avec drawRGBBitmap...");
            
            // Afficher le buffer sur le panneau avec drawRGBBitmap
            dma_display->drawRGBBitmap(0, 0, setImageBuffer, 64, 32);
            
            Serial.println("Image Set_RGB.png affichée - Reste visible jusqu'au clic eTag");
        } else {
            Serial.printf("Erreur décodage PNG: %d\n", rc);
        }
    } else {
        Serial.printf("Erreur ouverture Set_RGB.png: %d\n", rc);
    }
}

/**
 * Affiche l'animation de jeu gagné
 */
void displayGameWon(int playerNum) {
    clearDisplay();
    
    dma_display->setTextSize(1);
    dma_display->setCursor(12, 8);
    dma_display->setTextColor(COLOR_YELLOW);
    dma_display->print("JEU");
    
    // Coche
    dma_display->setCursor(28, 16);
    dma_display->setTextColor(playerNum == 1 ? COLOR_RED : COLOR_GREEN);
    dma_display->setTextSize(2);
    dma_display->print(playerNum == 1 ? "<":">");
    
    delay(2000);
}

/**
 * Affiche l'animation de set gagné
 */
void displaySetWon(int playerNum) {
    clearDisplay();
    
    dma_display->setTextSize(1);
    dma_display->setCursor(12, 8);
    dma_display->setTextColor(COLOR_ORANGE);
    dma_display->print("SET");
    
    // Nom du joueur
    dma_display->setCursor(8, 18);
    dma_display->setTextColor(playerNum == 1 ? COLOR_RED : COLOR_GREEN);
    dma_display->print("J");
    dma_display->print(playerNum);
    dma_display->print(" GAGNE!");
    
    delay(3000);
}

/**
 * Affiche l'animation de match gagné
 */
void displayMatchWon(int playerNum) {
    for (int i = 0; i < 3; i++) {
        clearDisplay();
        dma_display->setTextSize(1);
        dma_display->setCursor(4, 8);
        dma_display->setTextColor(COLOR_YELLOW);
        dma_display->print("MATCH!");
        
        dma_display->setCursor(8, 18);
        dma_display->setTextColor(playerNum == 1 ? COLOR_RED : COLOR_GREEN);
        dma_display->print("JOUEUR ");
        dma_display->print(playerNum);
        
        delay(500);
        clearDisplay();
        delay(300);
    }
    
    gameInProgress = false;
}

/**
 * Affiche l'animation de "balle" lors du changement de service
 * Une balle traverse l'écran du joueur fromPlayer vers le joueur toPlayer
 */
void displayBallServiceChange(int fromPlayer, int toPlayer) {
    Serial.printf("Animation changement de service: J%d → J%d\n", fromPlayer, toPlayer);
    
    // Direction: de gauche à droite si fromPlayer=1, de droite à gauche si fromPlayer=2
    int startX = (fromPlayer == 1) ? 2 : (PANEL_RES_X - 3);
    int endX = (fromPlayer == 1) ? (PANEL_RES_X - 3) : 2;
    int direction = (fromPlayer == 1) ? 1 : -1;
    
    int ballY = PANEL_RES_Y / 2+2;  // Milieu de l'écran verticalement
    int ballRadius = 2;
    
    // Couleur de la balle: jaune vif pour visibilité
    uint16_t ballColor = COLOR_YELLOW;
    
    // Animation: la balle traverse l'écran
    int numSteps = 20;  // Nombre d'étapes d'animation
    int stepSize = abs(endX - startX) / numSteps;
    if (stepSize < 1) stepSize = 1;
    
    for (int x = startX; 
         (direction > 0 && x < endX) || (direction < 0 && x > endX); 
         x += direction * stepSize) {
        
        // Afficher le score en arrière-plan (semi-transparent via effacement partiel)
        displayScore(false);
        
        // Dessiner la balle
        dma_display->fillCircle(x, ballY, ballRadius, ballColor);
        
        // Petite traînée pour effet de mouvement
        if (x - direction * stepSize >= 0 && x - direction * stepSize < PANEL_RES_X) {
            dma_display->fillCircle(x - direction * stepSize, ballY, ballRadius - 1, 
                                   rgb565(128, 128, 0));  // Traînée jaune foncé
        }
        
        delay(30);  // Délai pour animation fluide
    }
    
    // Dernière position de la balle
    displayScore();
    dma_display->fillCircle(endX, ballY, ballRadius, ballColor);
    delay(200);
    
    // Effet de "rebond" à l'arrivée
    for (int i = 0; i < 3; i++) {
        displayScore();
        dma_display->fillCircle(endX, ballY - 2, ballRadius, ballColor);
        delay(50);
        displayScore();
        dma_display->fillCircle(endX, ballY, ballRadius, ballColor);
        delay(50);
    }
    
    Serial.println("Animation changement de service terminée");
}

// ============================================================================
// LOGIQUE DU JEU DE PADEL
// ============================================================================

/**
 * Vérifie si un joueur a gagné le jeu
 */
void checkGameWon() {
    Player *winner = nullptr;
    int winnerNum = 0;
    
    // Cas avec avantage : il faut 2 points d'écart pour gagner
    if (isDeuce) {
        if (player1.hasAdvantage && player1.points - player2.points >= 2) {
            winner = &player1;
            winnerNum = 1;
        } else if (player2.hasAdvantage && player2.points - player1.points >= 2) {
            winner = &player2;
            winnerNum = 2;
        }
    }
    // Cas normal: 4 points avec 2 d'écart
    else if (player1.points >= 4 && player1.points - player2.points >= 2) {
        winner = &player1;
        winnerNum = 1;
    } else if (player2.points >= 4 && player2.points - player1.points >= 2) {
        winner = &player2;
        winnerNum = 2;
    }
    
    if (winner != nullptr) {
        winner->games++;
        Serial.printf("Jeu gagné par Joueur %d! Score: %d-%d\n", 
                      winnerNum, player1.games, player2.games);
        
        displayGameWon(winnerNum);
        resetGame();
        
        // Animation de changement de service (la balle passe au joueur suivant)
        int previousServer = currentServer;
        currentServer = (currentServer == 1) ? 2 : 1;  // Alternance du service
        Serial.printf("Changement de service: J%d → J%d\n", previousServer, currentServer);
        displayBallServiceChange(previousServer, currentServer);
        
        checkSetWon();
        
        // Ne pas afficher le score si on attend la continuation après un set gagné
        if (!waitingForSetContinue) {
            displayScore();
        }
    }
}

/**
 * Vérifie si un joueur a gagné le set
 */
void checkSetWon() {
    Player *winner = nullptr;
    int winnerNum = 0;
    
    // 6 jeux avec 2 d'écart
    if (player1.games >= 6 && player1.games - player2.games >= 2) {
        winner = &player1;
        winnerNum = 1;
    } else if (player2.games >= 6 && player2.games - player1.games >= 2) {
        winner = &player2;
        winnerNum = 2;
    }
    
    // Cas 7-5
    if (player1.games == 7 && player2.games == 5) {
        winner = &player1;
        winnerNum = 1;
    } else if (player2.games == 7 && player1.games == 5) {
        winner = &player2;
        winnerNum = 2;
    }
    
    if (winner != nullptr) {
        winner->sets++;
        Serial.printf("Set gagné par Joueur %d! Sets: %d-%d\n", 
                      winnerNum, player1.sets, player2.sets);
        
        // Afficher l'image Set_RGB.png
        displaySetImage();
        
        // Passer en mode attente : attendre un clic pour continuer
        waitingForSetContinue = true;
        Serial.println("⏸️  En attente d'un clic pour continuer...");
        
        // Réinitialiser les jeux
        player1.games = 0;
        player2.games = 0;
        
        // Ne pas vérifier immédiatement le match gagné
        // Ce sera fait après le clic de continuation
    }
}

/**
 * Vérifie si un joueur a gagné le match
 */
void checkMatchWon() {
    // Match en 2 sets gagnants
    if (player1.sets >= 2) {
        Serial.println("Match gagné par Joueur 1!");
        displayMatchWon(1);
    } else if (player2.sets >= 2) {
        Serial.println("Match gagné par Joueur 2!");
        displayMatchWon(2);
    }
}

/**
 * Ajoute un point à un joueur
 */
void addPoint(Player &player, Player &opponent, int playerNum) {
    if (!gameInProgress) {
        Serial.println("Match terminé. Redémarrez pour une nouvelle partie.");
        return;
    }
    
    if (waitingForSetContinue) {
        Serial.println("⏸️  En attente de continuation après set gagné. Cliquez pour continuer.");
        return;
    }
    
    player.points++;
    lastPointTime = millis(); // Reset du timer au point marqué
    Serial.printf("Joueur %d: +1 point (total: %d)\n", playerNum, player.points);
    
    // Gestion du deuce et de l'avantage
    if (player.points >= 3 && opponent.points >= 3) {
        isDeuce = true;
        
        if (player.points == opponent.points) {
            // Retour à deuce
            player.hasAdvantage = false;
            opponent.hasAdvantage = false;
            Serial.println("Deuce!");
        } else if (player.points > opponent.points) {
            // Joueur prend l'avantage
            player.hasAdvantage = true;
            opponent.hasAdvantage = false;
            Serial.printf("Avantage Joueur %d\n", playerNum);
        }
    }
    
    checkGameWon();
    
    // Ne pas afficher le score si on attend la continuation après un set gagné
    // (l'image Set_RGB.png doit rester affichée)
    if (!waitingForSetContinue) {
        displayScore();
    }
}

/**
 * Retire un point à un joueur (correction d'erreur)
 */
void removePoint(Player &player, int playerNum) {
    if (waitingForSetContinue) {
        Serial.println("⏸️  En attente de continuation après set gagné. Cliquez pour continuer.");
        return;
    }
    
    if (player.points > 0) {
        player.points--;
        lastPointTime = millis(); // Reset du timer à la correction
        Serial.printf("Joueur %d: -1 point (total: %d)\n", playerNum, player.points);
        
        // Réajuster deuce/avantage si nécessaire
        if (player1.points < 3 || player2.points < 3) {
            isDeuce = false;
            player1.hasAdvantage = false;
            player2.hasAdvantage = false;
        }
        
        displayScore();
    }
}

// ============================================================================
// GESTION BLUETOOTH BLE
// ============================================================================

/**
 * Traite un clic de joueur (simple ou double) - Version non-bloquante
 */
void handlePlayerClick(Player &player, Player &opponent, int playerNum) {
    unsigned long currentTime = millis();
    unsigned long timeSinceLastClick = currentTime - player.lastClickTime;

    // Démarrer les chronomètres au premier clic (Roadmap V1.2)
    if (matchStartTime == 0) {
        matchStartTime = currentTime;
        lastPointTime = currentTime;
        Serial.println("⏱️ Premier clic détecté : Lancement des chronomètres !");
    }
    
    // Si on attend la continuation après un set gagné, n'importe quel clic continue
    if (waitingForSetContinue) {
        Serial.printf("▶️  Joueur %d a cliqué → Reprise du jeu\n", playerNum);
        waitingForSetContinue = false;
        lastPointTime = millis();
        
        // Vérifier si le match est terminé
        checkMatchWon();
        
        // Si le match n'est pas terminé, afficher le score
        if (gameInProgress) {
            displayScore();
        }
        
        return;  // Ne pas traiter comme un point
    }
    
    // Anti-rebond : ignorer les clics trop rapprochés (bruit BLE)
    if (timeSinceLastClick < DEBOUNCE_DELAY && player.clickCount > 0) {
        Serial.printf("⚠️  Joueur %d: Clic ignoré (anti-rebond, %lums)\n", playerNum, timeSinceLastClick);
        return;
    }
    
    // Détection du double-clic : deuxième clic dans le délai imparti
    if (timeSinceLastClick >= DEBOUNCE_DELAY && timeSinceLastClick < DOUBLE_CLICK_DELAY && player.clickCount == 1) {
        // Double-clic détecté : décrémenter de 1 point (pas d'augmentation au 1er clic)
        Serial.printf("🔄 Joueur %d: Double-clic → Décrémentation de 1 point\n", playerNum);
        player.pendingClick = false;  // Annuler le clic en attente
        removePoint(player, playerNum);  // -1 point
        player.clickCount = 0;  // Réinitialiser le compteur
    } else {
        // Premier clic : marquer comme en attente, ne pas ajouter le point immédiatement
        Serial.printf("⏳ Joueur %d: Clic détecté → En attente de confirmation\n", playerNum);
        player.pendingClick = true;  // Marquer qu'un clic est en attente
        player.clickCount = 1;  // Compteur pour le prochain clic
    }
    
    player.lastClickTime = currentTime;
}

// Callback pour recevoir les notifications des boutons eTags
static void notifyCallback(NimBLERemoteCharacteristic* pBLERemoteCharacteristic,
                           uint8_t* pData, size_t length, bool isNotify) {
    // Les eTags envoient typiquement 0x01 quand le bouton est pressé
    if (length > 0) {
        Serial.printf("🔔 Notification BLE reçue: ");
        for (size_t i = 0; i < length; i++) {
            Serial.printf("%02X ", pData[i]);
        }
        Serial.println();
        
        // Déterminer quel joueur a cliqué
        if (player1.bleCharacteristic == pBLERemoteCharacteristic) {
            Serial.println("→ Clic détecté: Joueur 1");
            handlePlayerClick(player1, player2, 1);
        } else if (player2.bleCharacteristic == pBLERemoteCharacteristic) {
            Serial.println("→ Clic détecté: Joueur 2");
            handlePlayerClick(player2, player1, 2);
        }
    }
}

// Callback pour les notifications BLE
class MyClientCallback : public NimBLEClientCallbacks {
    void onConnect(NimBLEClient* pclient) {
        Serial.println("BLE: Client connecté");
    }

    void onDisconnect(NimBLEClient* pclient) {
        Serial.println("BLE: Client déconnecté");
        
        // Marquer comme déconnecté
        if (player1.bleClient == pclient) {
            player1.connected = false;
            lastConnLossPlayer = 1;
            lastConnLossTime = millis();
            Serial.println("⚠️ Joueur 1 déconnecté !");
        }
        if (player2.bleClient == pclient) {
            player2.connected = false;
            lastConnLossPlayer = 2;
            lastConnLossTime = millis();
            Serial.println("⚠️ Joueur 2 déconnecté !");
        }
        
        // Le réaffichage est géré par checkConnLossAlert() dans la loop
    }
};

// Callback pour les appareils BLE découverts
class MyAdvertisedDeviceCallbacks : public NimBLEAdvertisedDeviceCallbacks {
    void onResult(NimBLEAdvertisedDevice* advertisedDevice) {
        Serial.printf("BLE Découvert: %s\n", advertisedDevice->toString().c_str());
        
        String deviceAddress = advertisedDevice->getAddress().toString().c_str();
        deviceAddress.toLowerCase();
        String deviceName = advertisedDevice->haveName() ? advertisedDevice->getName().c_str() : "";
        
        // Auto-détection des iTags si adresses MAC non définies
        bool isITag = (deviceName.indexOf("iTAG") >= 0 || 
                       deviceName.indexOf("iTag") >= 0 ||
                       advertisedDevice->haveServiceUUID() && 
                       advertisedDevice->isAdvertisingService(serviceUUID));
        
        // Attribution aux joueurs
        if (PLAYER1_MAC.length() == 0 && discoveredPlayer1Address == nullptr && isITag) {
            PLAYER1_MAC = deviceAddress;
            Serial.printf("Auto-assigné Joueur 1: %s\n", deviceAddress.c_str());
        }
        
        if (PLAYER2_MAC.length() == 0 && discoveredPlayer2Address == nullptr && isITag && 
            deviceAddress != PLAYER1_MAC) {
            PLAYER2_MAC = deviceAddress;
            Serial.printf("Auto-assigné Joueur 2: %s\n", deviceAddress.c_str());
        }
        
        // Stocker l'adresse si correspond à un joueur
        if (deviceAddress == PLAYER1_MAC && discoveredPlayer1Address == nullptr) {
            discoveredPlayer1Address = new NimBLEAddress(advertisedDevice->getAddress());
            Serial.printf("→ Joueur 1 détecté: %s (RSSI: %d)\n", deviceAddress.c_str(), advertisedDevice->getRSSI());
        }
        
        if (deviceAddress == PLAYER2_MAC && discoveredPlayer2Address == nullptr) {
            discoveredPlayer2Address = new NimBLEAddress(advertisedDevice->getAddress());
            Serial.printf("→ Joueur 2 détecté: %s (RSSI: %d)\n", deviceAddress.c_str(), advertisedDevice->getRSSI());
        }
    }
};

/**
 * Initialise le BLE et lance le scan
 */
void initBLE() {
    Serial.println("Initialisation NimBLE...");
    
    NimBLEDevice::init("PadelDisplay");
    pBLEScan = NimBLEDevice::getScan();
    pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
    pBLEScan->setActiveScan(true);
    pBLEScan->setInterval(100);
    pBLEScan->setWindow(99);
    
    Serial.println("NimBLE initialisé. Début du scan...");
}

/**
 * Tente de connecter un joueur par son adresse
 */
bool connectPlayer(NimBLEAddress* address, Player& player, int playerNum) {
    if (address == nullptr) return false;
    
    Serial.printf("Connexion Joueur %d...\n", playerNum);
    
    NimBLEClient* pClient = NimBLEDevice::createClient();
    pClient->setClientCallbacks(new MyClientCallback());
    if (pClient->connect(*address)) {
        Serial.printf("→ Connecté, vérification service...: %s\n", pClient->isConnected() ? "OUI" : "NON");
        
        // Délai minimal pour stabiliser
        delay(100);
        
        Serial.printf("→ Récupération service UUID: %s\n", serviceUUID.toString().c_str());
        Serial.flush();
        
        NimBLERemoteService* pRemoteService = pClient->getService(serviceUUID);
        Serial.printf("→ pRemoteService obtenu: %s\n", pRemoteService != nullptr ? "OUI" : "NON");
        Serial.flush();
        
        if (pRemoteService != nullptr) {
            // Délai minimal après getService
            delay(100);
            
            Serial.printf("→ Récupération caractéristique UUID: %s\n", charUUID.toString().c_str());
            Serial.flush();
            
            NimBLERemoteCharacteristic* pRemoteChar = pRemoteService->getCharacteristic(charUUID);
            
            Serial.printf("→ pRemoteChar obtenu: %s\n", pRemoteChar != nullptr ? "OUI" : "NON");
            Serial.flush();
            
            if (pRemoteChar != nullptr) {
                // S'abonner aux notifications du bouton
                Serial.printf("→ Caractéristique trouvée, canNotify: %s\n", pRemoteChar->canNotify() ? "OUI" : "NON");
                
                // Délai minimal avant subscribe
                delay(50);
                
                // Activer les notifications (NimBLE utilise subscribe au lieu de registerForNotify)
                if (pRemoteChar->canNotify()) {
                    pRemoteChar->subscribe(true, notifyCallback);
                    Serial.println("→ Notifications activées via subscribe");
                } else {
                    Serial.println("⚠️  Caractéristique ne supporte pas les notifications");
                }
                
                // Délai minimal pour la configuration BLE
                delay(100);
                
                Serial.printf("✓ Joueur %d connecté!\n", playerNum);
                player.bleClient = pClient;
                player.bleCharacteristic = pRemoteChar;
                player.connected = true;
                player.bleAddress = address;
                displayScore();  // Mettre à jour l'affichage avec les indicateurs de connexion
                return true;
            }
        }
        Serial.println("✗ Service/Caractéristique introuvable");
        pClient->disconnect();
    } else {
        Serial.printf("✗ Échec connexion Joueur %d\n", playerNum);
    }
    return false;
}

/**
 * Lance un scan BLE
 */
void scanBLE() {
    if (!bleScanning) {
        Serial.println("Scan BLE en cours...");
        bleScanning = true;
        discoveredPlayer1Address = nullptr;
        discoveredPlayer2Address = nullptr;
        pBLEScan->start(BLE_SCAN_DURATION, false);
        bleScanning = false;
        
        // Tenter les connexions après le scan
        if (discoveredPlayer1Address != nullptr && !player1.connected) {
            Serial.println("Tentative connexion Joueur 1...");
            connectPlayer(discoveredPlayer1Address, player1, 1);
        }
        delay(1000);  // NimBLE est plus stable - 1s suffit entre les connexions
        if (discoveredPlayer2Address != nullptr && !player2.connected) {
            Serial.println("Tentative connexion Joueur 2...");
            Serial.flush();
            connectPlayer(discoveredPlayer2Address, player2, 2);
        }
        
        pBLEScan->clearResults();
    }
}

/**
 * Gère la reconnexion automatique
 */
void handleBLEReconnection() {
    unsigned long currentTime = millis();
    
    if (currentTime - lastBleScanTime > BLE_RECONNECT_INTERVAL) {
        if (!player1.connected || !player2.connected) {
            Serial.println("Tentative de reconnexion...");
            scanBLE();
        }
        lastBleScanTime = currentTime;
    }
}

/**
 * Vérifie et traite les clics en attente (après expiration du délai double-clic)
 */
void processPendingClicks() {
    // Ne pas traiter les clics en attente si on attend la continuation d'un set
    if (waitingForSetContinue) {
        return;
    }
    
    unsigned long currentTime = millis();
    
    // Vérifier le joueur 1
    if (player1.pendingClick) {
        unsigned long timeSinceClick = currentTime - player1.lastClickTime;
        // Debug: afficher le temps écoulé
        //Serial.printf("[DEBUG] J1 pending: %lums écoulées (délai: %d)\n", timeSinceClick, DOUBLE_CLICK_DELAY);
        if (timeSinceClick >= DOUBLE_CLICK_DELAY) {
            // Le délai est passé sans double-clic : ajouter le point
            Serial.printf("➕ Joueur 1: Simple clic confirmé → +1 point\n");
            addPoint(player1, player2, 1);
            player1.pendingClick = false;
            player1.clickCount = 0;
        }
    }
    
    // Vérifier le joueur 2
    if (player2.pendingClick) {
        unsigned long timeSinceClick = currentTime - player2.lastClickTime;
        // Debug: afficher le temps écoulé
        //Serial.printf("[DEBUG] J2 pending: %lums écoulées (délai: %d)\n", timeSinceClick, DOUBLE_CLICK_DELAY);
        if (timeSinceClick >= DOUBLE_CLICK_DELAY) {
            // Le délai est passé sans double-clic : ajouter le point
            Serial.printf("➕ Joueur 2: Simple clic confirmé → +1 point\n");
            addPoint(player2, player1, 2);
            player2.pendingClick = false;
            player2.clickCount = 0;
        }
    }
}

/**
 * Vérifie s'il faut afficher ou effacer une alerte de perte de connexion
 */
void checkConnLossAlert() {
    static bool isAlerting = false;
    
    if (lastConnLossTime > 0) {
        if (millis() - lastConnLossTime < CONN_LOSS_MSG_DURATION) {
            if (!isAlerting) {
                isAlerting = true;
                char msg[16];
                sprintf(msg, "PERTE J%d", lastConnLossPlayer);
                displayMessage(msg, COLOR_RED);
            }
        } else {
            // Fin de l'alerte, on nettoie et on restaure le score
            lastConnLossTime = 0;
            isAlerting = false;
            displayScore();
        }
    }
}

// ============================================================================
// SETUP ET LOOP
// ============================================================================

void setup() {
    Serial.begin(115200);
    Serial.println("\n\n=================================");
    Serial.println("Afficheur Score Padel - ESP32");
    Serial.println("=================================\n");
    
    // Désactivation WiFi pour économie d'énergie (seul BLE est utilisé)
    Serial.println("Désactivation WiFi pour optimiser la consommation...");
    WiFi.mode(WIFI_OFF);
    btStop();  // Arrêt du Bluetooth Classic (seul BLE sera utilisé)
    Serial.println("WiFi et Bluetooth Classic désactivés");
    
    // Configuration du panneau LED HUB75
    HUB75_I2S_CFG mxconfig(
        PANEL_RES_X,   // Largeur
        PANEL_RES_Y,   // Hauteur
        PANEL_CHAIN    // Nombre de panneaux chaînés
    );
    
    // Configuration des broches personnalisées
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
    
    // Création de l'objet d'affichage
    dma_display = new MatrixPanel_I2S_DMA(mxconfig);
    dma_display->begin();
    dma_display->setBrightness8(128);  // Luminosité moyenne (0-255)
    dma_display->clearScreen();
    
    // Initialisation du système de fichiers SPIFFS pour les images
    Serial.println("Initialisation SPIFFS...");
    if (!SPIFFS.begin(true)) {
        Serial.println("⚠️  Erreur: Impossible de monter SPIFFS");
    } else {
        Serial.println("✓ SPIFFS monté avec succès");
        
        // Lister les fichiers pour vérification
        File root = SPIFFS.open("/");
        File file = root.openNextFile();
        while (file) {
            Serial.printf("  - %s (%d bytes)\n", file.name(), file.size());
            file = root.openNextFile();
        }
    }
    
    // Configuration ADC pour mesure batterie
    Serial.println("Configuration ADC pour batterie LiFePO4 12.8V...");
    analogReadResolution(12);           // Résolution 12-bit (0-4095)
    analogSetAttenuation(ADC_11db);     // Atténuation 11dB pour gamme 0-2.6V (utilise 3.3V ref)
    
    // Lecture initiale de la batterie
    delay(100);  // Laisser l'ADC se stabiliser
    currentBatteryVoltage = getBatteryVoltage();
    currentBatteryPercentage = getBatteryPercentage();
    lastBatteryReadTime = millis();
    
    Serial.printf("Batterie détectée: %.2fV (%d%%)\n", 
                  currentBatteryVoltage, currentBatteryPercentage);
    
    if (currentBatteryVoltage < BATTERY_MIN_VOLTAGE) {
        Serial.println("⚠️  ALERTE: Batterie critique ou non connectée!");
    }
    
    Serial.println("Panneau LED initialisé");
    
    // Message de bienvenue
    displayMessage("PADEL", COLOR_YELLOW);
    delay(2000);
    
    // Initialisation des joueurs
    initPlayer(player1);
    initPlayer(player2);
    
    // Initialisation BLE
    displayMessage("BLE...", COLOR_CYAN);
    initBLE();
    scanBLE();
    delay(BLE_SCAN_DURATION * 1000 + 1000);
    
    // Initialiser le timestamp de reconnexion
    lastBleScanTime = millis();
    lastPointTime = millis();
    matchStartTime = millis();
    lastPointTime = 0;
    matchStartTime = 0;
    
    // Affichage du score initial
    displayScore();
    
    Serial.println("\nSystème prêt!");
    Serial.println("Appuyez sur les boutons des eTags pour démarrer");
    Serial.println("1 clic = +1 point | 2 clics = -1 point\n");
}

void loop() {
    // Mise à jour du niveau de batterie (toutes les 5 secondes)
    updateBatteryLevel();
    
    // Gestion de la reconnexion BLE
    handleBLEReconnection();

    // Gestion des alertes visuelles de déconnexion
    checkConnLossAlert();
    
    // Rafraîchir l'affichage du timer toutes les secondes (Roadmap V1.1)
    static unsigned long lastTimerRefresh = 0;
    if (millis() - lastTimerRefresh >= 1000) {
        if (lastPointTime > 0 && gameInProgress && !waitingForSetContinue) {
            displayScore(true); // Rafraîchissement non-bloquant
        }
        lastTimerRefresh = millis();
    }

    // Traiter les clics en attente (après expiration du délai double-clic)
    processPendingClicks();
    
    // Simulation de détection de clics BLE
    // NOTE: Dans une implémentation réelle avec eTags iTAG, vous devrez
    // implémenter la lecture des caractéristiques BLE pour détecter les clics
    
    // Pour l'instant, permettre le contrôle via Serial Monitor
    if (Serial.available()) {
        char cmd = Serial.read();
        
        switch (cmd) {
            case '1':  // Point joueur 1
            case '+':
                if (matchStartTime == 0) {
                    matchStartTime = millis();
                    lastPointTime = matchStartTime;
                }
                addPoint(player1, player2, 1);
                break;
                
            case '2':  // Point joueur 2
            case '=':
                if (matchStartTime == 0) {
                    matchStartTime = millis();
                    lastPointTime = matchStartTime;
                }
                addPoint(player2, player1, 2);
                break;
                
            case '!':  // Retire point joueur 1
                removePoint(player1, 1);
                break;
                
            case '@':  // Retire point joueur 2
                removePoint(player2, 2);
                break;
                
            case 'r':  // Reset match
            case 'R':
                resetMatch();
                displayMessage("RESET", COLOR_ORANGE);
                delay(1000);
                displayScore();
                break;
                
            case 's':  // Statut
            case 'S':
                Serial.printf("\nStatut:\n");
                Serial.printf("Joueur 1: %d points, %d jeux, %d sets - %s\n",
                            player1.points, player1.games, player1.sets,
                            player1.connected ? "Connecté" : "Déconnecté");
                Serial.printf("Joueur 2: %d points, %d jeux, %d sets - %s\n",
                            player2.points, player2.games, player2.sets,
                            player2.connected ? "Connecté" : "Déconnecté");
                Serial.printf("Deuce: %s\n", isDeuce ? "Oui" : "Non");
                Serial.printf("En attente continuation: %s\n", waitingForSetContinue ? "Oui" : "Non");
                break;
                
            case 't':  // Test affichage image Set_RGB.png
            case 'T':
                Serial.println("Test: Affichage de Set_RGB.png");
                displaySetImage();
                Serial.println("Image affichée - Cliquez sur un eTag pour continuer");
                waitingForSetContinue = true;  // Simuler l'attente comme après un set gagné
                break;
        }
    }
    
    delay(10);  // Petit délai pour économiser le CPU
}
