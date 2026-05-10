# 🛠️ Guide de Dépannage - PadelDisplay

## Table des Matières

- [Problèmes Matériels](#problèmes-matériels)
- [Problèmes Logiciels](#problèmes-logiciels)
- [Problèmes BLE](#problèmes-ble)
- [Problèmes d'Affichage](#problèmes-daffichage)
- [Codes d'Erreur](#codes-derreur)
- [Logs de Diagnostic](#logs-de-diagnostic)

---

## Problèmes Matériels

### ❌ Le panneau LED reste noir

**Symptômes:**
- Panneau complètement éteint
- Aucune LED ne s'allume

**Causes possibles:**

1. **Pas d'alimentation 5V**
   ```
   Solution:
   ✅ Vérifier que l'adaptateur est branché
   ✅ Mesurer la tension au multimètre: doit être 4.8-5.2V
   ✅ Vérifier le fusible de l'alimentation
   ```

2. **Câble d'alimentation déconnecté**
   ```
   Solution:
   ✅ Vérifier les bornes +5V et GND du panneau
   ✅ Vérifier la polarité (rouge = +, noir = -)
   ✅ Resserrer les vis du bornier
   ```

3. **ESP32 non alimenté**
   ```
   Solution:
   ✅ Brancher le câble USB de l'ESP32
   ✅ Vérifier que la LED power de l'ESP32 est allumée
   ✅ Essayer un autre port USB ou câble
   ```

4. **Panneau défectueux**
   ```
   Test:
   □ Débrancher l'ESP32
   □ Alimenter uniquement le panneau en 5V
   □ Si le panneau ne clignote pas brièvement, il est défectueux
   ```

---

### ❌ Couleurs incorrectes ou inversées

**Symptômes:**
- Rouge affiché en vert
- Couleurs mélangées
- Affichage "psychédélique"

**Solutions:**

1. **Vérifier le câblage RGB**
   ```cpp
   // Dans main.cpp, vérifier les pins:
   #define R1_PIN 25  // Rouge moitié haute
   #define G1_PIN 26  // Vert moitié haute
   #define B1_PIN 27  // Bleu moitié haute
   #define R2_PIN 14  // Rouge moitié basse
   #define G2_PIN 12  // Vert moitié basse
   #define B2_PIN 13  // Bleu moitié basse
   ```

2. **Inverser les pins si nécessaire**
   ```cpp
   // Exemple: Si rouge et vert sont inversés
   #define R1_PIN 26  // Était 25
   #define G1_PIN 25  // Était 26
   ```

3. **Vérifier les connexions physiques**
   - Refaire les connexions Dupont
   - Vérifier l'absence de faux contact

---

### ❌ Moitié de l'écran ne fonctionne pas

**Symptômes:**
- Seule la moitié haute affiche
- OU seule la moitié basse affiche

**Cause:**
- Pins R2, G2, B2 déconnectés ou mal configurés

**Solution:**
```
✅ Vérifier les connexions:
   - GPIO 14 → R2
   - GPIO 12 → G2
   - GPIO 13 → B2

✅ Tester avec code de diagnostic:
   dma_display->fillRect(0, 16, 64, 16, COLOR_RED);
   // Si rien ne s'affiche en bas, problème R2/G2/B2
```

---

### ❌ Affichage qui scintille

**Symptômes:**
- Image instable
- Flickering visible
- Lignes qui tremblent

**Causes:**

1. **Pas de GND commun**
   ```
   Solution CRITIQUE:
   ✅ Connecter GND de l'ESP32 au GND du panneau
   ✅ Utiliser un fil court et de bonne section (>0.5mm²)
   ```

2. **Alimentation insuffisante**
   ```
   Test:
   □ Mesurer la tension sous charge: doit rester > 4.8V
   □ Si < 4.8V, utiliser une alimentation plus puissante (4A →5A)
   ```

3. **Câbles trop longs**
   ```
   Solution:
   ✅ Réduire la longueur des câbles GPIO à < 30cm
   ✅ Utiliser des câbles de même longueur
   ```

---

### ❌ ESP32 chauffe beaucoup

**Symptômes:**
- Puce ESP32 très chaude au toucher (>60°C)
- Redémarrages inopinés

**Causes:**

1. **Court-circuit**
   ```
   DANGER! Débrancher immédiatement!
   
   Vérifications:
   ✅ Aucun contact entre broches adjacentes
   ✅ Pas de contact +5V ↔ GND
   ✅ Vérifier au multimètre (mode continuité)
   ```

2. **Surconsommation**
   ```
   Solution:
   ✅ Réduire la luminosité:
      dma_display->setBrightness8(64);  // Au lieu de 255
   ✅ Ajouter un dissipateur thermique sur l'ESP32
   ✅ Améliorer la ventilation
   ```

---

## Problèmes Logiciels

### ❌ "Upload Failed" / Impossible de téléverser

**Symptômes:**
- Échec lors de l'upload
- Message "Failed to connect"

**Solutions:**

1. **Maintenir le bouton BOOT**
   ```
   Procédure:
   1. Maintenir le bouton BOOT de l'ESP32
   2. Cliquer sur Upload
   3. Attendre "Connecting..."
   4. Relâcher BOOT quand upload démarre
   ```

2. **Vérifier le port COM**
   ```powershell
   # Dans le terminal PlatformIO:
   pio device list
   
   # Doit afficher quelque chose comme:
   # COM3 - USB-SERIAL CH340
   ```

3. **Installer/Réinstaller le driver CH340**
   - Windows: [Télécharger CH340 Driver](https://sparks.gogo.co.nz/ch340.html)
   - Redémarrer après installation

4. **Essayer un autre câble USB**
   - Certains câbles sont power-only (pas de données)
   - Utiliser un câble USB de qualité

5. **Spécifier manuellement le port**
   ```ini
   ; Dans platformio.ini, ajouter:
   upload_port = COM3     ; Adapter selon votre port
   monitor_port = COM3
   ```

---

### ❌ "Library Not Found" / Librairie manquante

**Symptômes:**
```
Error: ESP32-HUB75-MatrixPanel-I2S-DMA.h: No such file or directory
```

**Solutions:**

1. **Installation automatique**
   ```powershell
   # Dans le terminal PlatformIO:
   pio lib install
   ```

2. **Installation manuelle**
   ```powershell
   pio lib install "mrfaptastic/ESP32 HUB75 LED MATRIX PANEL DMA Display"
   pio lib install "adafruit/Adafruit GFX Library"
   ```

3. **Nettoyer et reconstruire**
   ```powershell
   pio run --target clean
   pio run
   ```

---

### ❌ Erreurs de compilation

**Symptôme:**
```
error: 'dma_display' was not declared in this scope
```

**Solutions:**

1. **Vérifier la syntaxe C++**
   - Manque un point-virgule `;`
   - Accolade manquante `}`
   - Vérifier les commentaires `/* */` et `//`

2. **Vérifier les includes**
   ```cpp
   #include <Arduino.h>
   #include <ESP32-HUB75-MatrixPanel-I2S-DMA.h>
   ```

3. **Déclarer les variables globales**
   ```cpp
   // En haut du fichier, avant setup():
   MatrixPanel_I2S_DMA *dma_display = nullptr;
   ```

---

### ❌ ESP32 se redémarre en boucle

**Symptômes:**
- Moniteur série affiche:
  ```
  rst:0x8 (TG1WDT_SYS_RESET),boot:0x13 (SPI_FAST_FLASH_BOOT)
  ```
- Redémarre toutes les X secondes

**Causes:**

1. **Watchdog Timer**
   ```cpp
   // Solution: Désactiver temporairement
   void setup() {
       disableCore0WDT();
       disableCore1WDT();
       // ... reste du code
   }
   ```

2. **Boucle infinie dans le code**
   ```cpp
   // Vérifier les while(true) sans delay
   while(condition) {
       // ... code ...
       delay(10);  // ← Ajouter un delay!
   }
   ```

3. **Exception / Crash**
   - Activer le décodeur d'exception:
   ```ini
   ; Dans platformio.ini:
   monitor_filters = esp32_exception_decoder
   ```
   - Observer les logs pour identifier la ligne problématique

---

## Problèmes BLE

### ❌ eTags non détectés

**Symptômes:**
- Logs: "BLE Découvert: 0 devices"
- Pas de connexion

**Solutions:**

1. **Activer les eTags**
   ```
   ✅ Appuyer sur le bouton de chaque eTag
   ✅ Vérifier que la LED clignote (mode découverte)
   ✅ Remplacer les piles si nécessaire (CR2032)
   ```

2. **Vérifier la portée**
   ```
   ✅ Rapprocher les eTags à < 2m de l'ESP32
   ✅ Supprimer les obstacles métalliques
   ✅ Éloigner des sources WiFi 2.4GHz
   ```

3. **Augmenter la durée de scan**
   ```cpp
   // Dans main.cpp:
   #define BLE_SCAN_DURATION 10  // Au lieu de 5
   ```

4. **Logs de debug BLE**
   ```cpp
   // Dans setup(), après BLEDevice::init():
   BLEDevice::setDebugLevel(ESP_LOG_VERBOSE);
   ```

---

### ❌ Connexion BLE perdue fréquemment

**Symptômes:**
- Connexions/déconnexions répétées
- Message "Client déconnecté"

**Solutions:**

1. **Interférences WiFi**
   ```cpp
   // Désactiver le WiFi si non utilisé:
   void setup() {
       WiFi.mode(WIFI_OFF);
       // ... reste du code
   }
   ```

2. **Piles faibles**
   ```
   ✅ Remplacer les piles des eTags (CR2032)
   ✅ Vérifier voltage: doit être > 2.8V
   ```

3. **Augmenter l'intervalle de reconnexion**
   ```cpp
   const unsigned long BLE_RECONNECT_INTERVAL = 5000;  // 5 sec au lieu de 10
   ```

---

### ❌ Double-clic non détecté

**Symptômes:**
- 2 clics = 2 incrémentations au lieu de 1 décrémentation
- Impossible d'annuler un point

**Solutions:**

1. **Cliquer plus rapidement**
   ```
   Les 2 clics doivent être espacés de < 400ms
   ```

2. **Ajuster le délai**
   ```cpp
   // Dans main.cpp:
   #define DOUBLE_CLICK_DELAY 600  // Au lieu de 400 (plus tolérant)
   ```

3. **Vérifier la batterie**
   ```
   Pile faible → Latence accrue → Double-clic non détecté
   ```

---

## Problèmes d'Affichage

### ❌ Texte illisible ou mal positionné

**Symptômes:**
- Score coupé
- Texte hors écran
- Chevauchement

**Solutions:**

1. **Ajuster les coordonnées**
   ```cpp
   // Dans displayScore():
   dma_display->setCursor(2, 2);   // X, Y
   // Tester différentes valeurs
   ```

2. **Changer la taille de police**
   ```cpp
   dma_display->setTextSize(1);  // Plus petit
   dma_display->setTextSize(2);  // Moyen (défaut)
   dma_display->setTextSize(3);  // Plus grand
   ```

3. **Vérifier la résolution**
   ```cpp
   // Doit correspondre à votre panneau:
   #define PANEL_RES_X 64  // Largeur en pixels
   #define PANEL_RES_Y 32  // Hauteur en pixels
   ```

---

### ❌ Affichage figé / ne se met pas à jour

**Symptômes:**
- Score bloqué
- Pas de réaction aux clics

**Solutions:**

1. **Vérifier loop()**
   ```cpp
   void loop() {
       // DOIT contenir:
       handleBLEReconnection();
       // ... traitement des clics ...
       delay(10);  // ← Important!
   }
   ```

2. **Redémarrer l'ESP32**
   ```
   ✅ Appuyer sur le bouton RESET
   ✅ OU débrancher/rebrancher
   ```

3. **Vérifier la RAM**
   ```cpp
   // Ajouter dans loop():
   Serial.printf("Free heap: %d bytes\n", ESP.getFreeHeap());
   // Si < 10000 bytes → Problème de mémoire
   ```

---

## Codes d'Erreur

### Moniteur Série

| Message | Signification | Solution |
|---------|---------------|----------|
| `rst:0x8 (TG1WDT_SYS_RESET)` | Watchdog timeout | Ajouter delays dans loop() |
| `Guru Meditation Error` | Exception CPU | Utiliser exception_decoder |
| `BLE: Failed to connect` | Échec connexion BLE | Rapprocher eTag, vérifier pile |
| `Out of memory` | RAM saturée | Réduire résolution ou options |
| `Brownout detector` | Tension trop basse | Améliorer alimentation |

### LEDs de l'ESP32

| État LED | Signification |
|----------|---------------|
| Éteinte | Pas d'alimentation |
| Allumée fixe | Normal |
| Clignotement rapide | Upload en cours |
| Clignotement lent | En attente BLE |

---

## Logs de Diagnostic

### Activer les Logs Détaillés

```cpp
// En haut de main.cpp:
#define DEBUG_MODE 1

// Dans setup():
Serial.begin(115200);
Serial.setDebugOutput(true);

// Dans loop():
#if DEBUG_MODE
    Serial.printf("[%lu] Free heap: %d | BLE: %s\n", 
                  millis(), 
                  ESP.getFreeHeap(),
                  player1.connected ? "OK" : "KO");
#endif
```

### Commandes de Test

Via le moniteur série:

| Commande | Description |
|----------|-------------|
| `s` | Afficher statut complet |
| `m` | Afficher utilisation mémoire |
| `b` | Scanner BLE manuellement |
| `r` | Reset complet |
| `t` | Mode test (animation) |

### Exemple de Log Normal

```
=================================
Afficheur Score Padel - ESP32
=================================

Panneau LED initialisé
BLE initialisé. Début du scan...
BLE Découvert: iTAG, Address: aa:bb:cc:dd:ee:ff
Tentative de connexion Joueur 1...
Joueur 1 connecté!
BLE Découvert: iTAG, Address: 11:22:33:44:55:66
Tentative de connexion Joueur 2...
Joueur 2 connecté!

Système prêt!
Appuyez sur les boutons des eTags pour démarrer
```

---

## 🆘 Support Supplémentaire

Si le problème persiste:

1. **Vérifier l'INDEX.md** pour naviguer dans la doc
2. **Consulter HARDWARE.md** pour validation matérielle
3. **Relire WIRING.md** pour vérifier le câblage
4. **Chercher dans les issues GitHub** (si disponible)
5. **Faire un reset complet**:
   ```
   - Débrancher tout
   - Attendre 30 secondes
   - Rebrancher dans l'ordre: Panneau, ESP32, eTags
   ```

---

**N'hésitez pas à demander de l'aide avec:**
- Logs complets du moniteur série
- Photos du câblage
- Configuration matérielle exacte
- Étapes déjà testées

**Bon courage!** 🛠️
