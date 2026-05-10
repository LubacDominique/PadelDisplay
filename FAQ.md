# ❓ FAQ - Questions Fréquentes

## Table des Matières

- [Général](#général)
- [Matériel](#matériel)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Personnalisation](#personnalisation)
- [Avancé](#avancé)

---

## Général

### 💰 Combien coûte le projet?

**Budget total: 50-80€**

Détail:
- Panneau LED P5: 15-25€
- ESP32: 5-10€
- 2x eTags BLE: 10-20€
- Alimentation 5V/4A: 10-15€
- Câbles et accessoires: 5-10€

Achats groupés (AliExpress): ~50€  
Achats locaux/Amazon: ~80€

---

### ⏱️ Combien de temps pour le construire?

**Total: 2-4 heures**

Détail:
- Préparation des composants: 30 min
- Câblage: 1-2 heures
- Installation logiciel: 30 min
- Tests et ajustements: 30 min à 1 heure

Première fois: 4 heures  
Avec expérience: 2 heures

---

### 🎓 Quel niveau de compétence requis?

**Niveau: Débutant/Intermédiaire**

Compétences utiles:
- ✅ Lecture de schémas électroniques (basique)
- ✅ Soudure (optionnel, pour installation permanente)
- ✅ Utilisation de VS Code (basique)
- ✅ Câblage de composants

Pas besoin de:
- ❌ Programmation avancée (code fourni)
- ❌ Conception de PCB
- ❌ Expertise ESP32

**Si vous savez utiliser un Arduino, c'est suffisant!**

---

### 📏 Quelle est la taille finale?

**Dimensions:**
- Panneau seul: 320mm × 160mm × 12mm
- Avec boîtier: ~340mm × 180mm × 40mm
- Poids: ~300g (panneau) + 50g (électronique)

**Comparable à:**
- Une feuille A4 (210 × 297mm)
- Mais plus étroit et long

---

### 🔋 Consommation électrique?

**Utilisation normale:**
- Panneau LED: 10-15W (luminosité 50%)
- ESP32: 1-2W
- **Total: 12-17W** (~3A @ 5V)

**Utilisation max:**
- Panneau LED: 20-25W (luminosité 100%, tout blanc)
- ESP32: 2W
- **Total: 22-27W** (~5A @ 5V)

**Coût électrique:**
- 4h/jour × 15W = 60Wh = 0.06kWh
- 0.06 × 30 jours × 0.20€/kWh = **0.36€/mois**

---

### ☀️ Peut-on l'utiliser en extérieur?

**Non, pas en standard.**

Le panneau est conçu pour intérieur:
- ❌ Pas résistant à l'eau (IP20)
- ❌ Lisibilité limitée en plein soleil
- ❌ Électronique non protégée

**Pour extérieur:**
- Utiliser un panneau outdoor (IP65)
- Boîtier étanche
- Luminosité accrue (coût x2-3)

**Alternative:** Installer sous un auvent/toit

---

## Matériel

### 🛒 Où acheter les composants?

**Recommandé:**

| Composant | Fournisseur | Délai | Prix |
|-----------|-------------|-------|------|
| Panneau LED P5 | AliExpress, BTF-Lighting | 2-4 sem | 15-20€ |
| ESP32 DevKit | Amazon, AliExpress | 1-4 sem | 5-10€ |
| eTags BLE | Amazon "iTAG" | 2-5 jours | 5-10€/unité |
| Alimentation 5V | Amazon, Meanwell | 2-5 jours | 10-15€ |

**Recherche sur AliExpress:**
- "P5 LED panel 32x64 indoor"
- "ESP32 DevKit 30 pin"
- "iTAG Bluetooth tracker"

---

### 🔍 Comment vérifier la compatibilité du panneau?

**Checklist obligatoire:**

✅ **Résolution:** 32 lignes × 64 colonnes  
✅ **Pitch:** P5 (5mm entre LEDs)  
✅ **Interface:** HUB75 (connecteur 16 pins)  
✅ **Scan:** 1/16 (important!)  
✅ **Usage:** Indoor (intérieur)  
✅ **Dimensions:** ~320 × 160mm

**⚠️ Attention:**
- Ne pas acheter P10 (trop espacé)
- Ne pas acheter outdoor (sauf besoin)
- Vérifier "HUB75" dans la description

---

### 🔌 Peut-on utiliser un autre ESP32?

**Oui, mais vérifier:**

Compatible:
- ✅ ESP32-DevKitC (toutes versions)
- ✅ ESP32-WROOM-32
- ✅ ESP32-S3 (plus performant)
- ✅ ESP32-C3 (avec modifications)

Non compatible:
- ❌ ESP8266 (pas assez de GPIO)
- ❌ Arduino Uno/Mega (pas assez puissant)
- ❌ Raspberry Pi Pico (GPIO différents)

**Adapter les pins** si modèle différent!

---

### 🏷️ Quels eTags sont compatibles?

**Compatibles:**
- ✅ iTAG (le plus commun)
- ✅ Tile (certains modèles)
- ✅ TrackR
- ✅ Générique BLE avec bouton

**Critères:**
- BLE 4.0+ (pas Bluetooth classique)
- Bouton physique
- Service UUID: 0xFFE0 (Standard)

**Test:** Télécharger "nRF Connect" sur smartphone et scanner l'eTag

---

### ⚡ Quelle alimentation choisir?

**Recommandations:**

**Économique:** Adaptateur générique 5V/4A
- Prix: 8-12€
- Attention à la qualité (risque de bruit électrique)

**Optimal:** Meanwell LRS-150-5
- Prix: 15-20€
- Très fiable, silencieux
- Protection intégrée

**Spécifications minimum:**
- Voltage: 5V DC (± 5%)
- Courant: Minimum 3A, recommandé 4A+
- Connecteur: DC barrel ou bornier à vis

**⚠️ Ne pas utiliser:**
- Chargeur de téléphone (trop faible)
- Alimentation non régulée
- Ports USB d'ordinateur

---

## Installation

### 💻 Dois-je savoir programmer?

**Non!**

Le code est fourni complet et fonctionnel:
- ✅ Copier-coller dans VS Code
- ✅ Upload via PlatformIO
- ✅ Aucune modification requise

**Modifications optionnelles:**
- Couleurs (très simple)
- Luminosité (1 ligne)
- Adresses MAC eTags (copier-coller)

Niveau requis: savoir ouvrir un fichier .cpp

---

### 🍎 Compatible Mac/Linux?

**Oui, totalement!**

PlatformIO fonctionne sur:
- ✅ Windows 7+
- ✅ macOS 10.12+
- ✅ Linux (Ubuntu, Debian, Fedora...)

**Note:**
- macOS: Driver CH340 [différent](https://github.com/adrianmihalko/ch340g-ch34g-ch34x-mac-os-x-driver)
- Linux: Ajouter droits USB avec `sudo usermod -a -G dialout $USER`

---

### ❓ PlatformIO vs Arduino IDE?

**PlatformIO recommandé** pour ce projet.

| Feature | PlatformIO | Arduino IDE |
|---------|------------|-------------|
| Gestion librairies | Auto | Manuel |
| Organisation code | Meilleure | Basique |
| Logs détaillés | ✅ | Limités |
| Performance build | Rapide | Lent |
| Courbe d'apprentissage | Moyenne | Facile |

**Possible avec Arduino IDE** mais nécessite:
- Installer manuellement les librairies
- Configurer les partitions
- Moins de feedback en cas d'erreur

---

### 🔄 Comment mettre à jour le code?

**Méthode simple:**

1. Télécharger la nouvelle version
2. Remplacer `src/main.cpp`
3. Cliquer sur Upload (Ctrl+Alt+U)

**Méthode Git:**
```powershell
git pull origin main
pio run --target upload
```

**⚠️ Sauvegarder vos modifications**
- Copier votre `main.cpp` avant mise à jour
- OU utiliser `config.h` pour personnalisation

---

## Utilisation

### 🎮 Comment ajouter/retirer des points?

**Avec eTags BLE:**
- **1 clic:** +1 point
- **2 clics rapides (<400ms):** -1 point

**Avec moniteur série (test):**
- Taper `1` ou `+`: Point joueur 1
- Taper `2` ou `=`: Point joueur 2
- Taper `!`: Retire point joueur 1
- Taper `@`: Retire point joueur 2

---

### 🔄 Comment réinitialiser un match?

**Méthode 1: Moniteur série**
```
Taper: r
```

**Méthode 2: Bouton RESET**
```
Appuyer sur le bouton RESET de l'ESP32
```

**Méthode 3: Code (à implémenter)**
```cpp
// Triple-clic simultané sur les 2 eTags
if (player1.clickCount == 3 && player2.clickCount == 3) {
    resetMatch();
}
```

---

### 📏 Les règles du padel sont-elles standard?

**Oui, standard européen.**

Implémenté:
- ✅ Points: 0, 15, 30, 40
- ✅ Deuce à 40-40
- ✅ Avantage après deuce
- ✅ Jeu: 4 points avec 2 d'écart
- ✅ Set: 6 jeux avec 2 d'écart
- ✅ Match: 2 sets gagnants

**Variables possibles:**
- Super tie-break à 1 set partout (à implémenter)
- Match en 1 ou 3 sets (configurable dans code)

---

### ⏱️ Y a-t-il un chronomètre?

**Non, pas en v1.0.**

Prévu pour v1.2:
- Temps de jeu total
- Temps entre points
- Affichage optionnel

**Workaround actuel:**
- Utiliser un chronomètre externe
- OU vérifier les timestamps dans les logs série

---

### 🔊 Y a-t-il du son?

**Non, pas de son en v1.0.**

Prévu pour v2.0:
- Haut-parleur I2S
- Annonce vocale des scores
- Notifications sonores

**DIY possible:**
- Ajouter un buzzer passif sur GPIO libre
- Implémenter `tone()` pour bips

---

## Personnalisation

### 🎨 Comment changer les couleurs?

**Dans `src/main.cpp`, ligne ~70:**

```cpp
// Couleurs actuelles
uint16_t COLOR_RED     = 0xF800;  // Joueur 1
uint16_t COLOR_GREEN   = 0x07E0;  // Joueur 2
uint16_t COLOR_YELLOW  = 0xFFE0;  // Jeux

// Exemples de changement:
uint16_t COLOR_RED     = 0x001F;  // Bleu pour J1
uint16_t COLOR_GREEN   = 0xFFE0;  // Jaune pour J2
```

**Créer vos couleurs:**
```cpp
// Format: rgb565(Rouge, Vert, Bleu)
// Valeurs: 0-255 pour chaque composante

uint16_t MA_COULEUR = rgb565(255, 128, 0);  // Orange
uint16_t MA_COULEUR2 = rgb565(128, 0, 255); // Violet
```

---

### 💡 Comment régler la luminosité?

**Dans `setup()`, ligne ~630:**

```cpp
dma_display->setBrightness8(128);  // Valeur actuelle (50%)

// Modifier selon besoin:
dma_display->setBrightness8(64);   // 25% (économie)
dma_display->setBrightness8(192);  // 75% (lumineux)
dma_display->setBrightness8(255);  // 100% (max)
```

**Astuce:** Créer un potentiomètre de réglage:
```cpp
int potValue = analogRead(POT_PIN);  // 0-4095
int brightness = map(potValue, 0, 4095, 0, 255);
dma_display->setBrightness8(brightness);
```

---

### 📝 Comment afficher les noms des joueurs?

**À implémenter (v1.2):**

```cpp
String player1Name = "ALICE";
String player2Name = "BOB";

void displayScore() {
    // Afficher noms en haut
    dma_display->setCursor(2, 2);
    dma_display->print(player1Name.substring(0, 5));  // Max 5 chars
    
    dma_display->setCursor(40, 2);
    dma_display->print(player2Name.substring(0, 5));
    
    // Scores en dessous
    // ...
}
```

---

### 🖥️ Peut-on afficher le score sur un téléphone?

**Pas en v1.0.**

**Roadmap v1.2:**
- Interface Web via WiFi
- URL: `http://192.168.x.x/score`
- Affichage temps réel

**Alternative actuelle:**
- Moniteur série via Bluetooth Serial
- Application tierce de visualisation

---

### 📱 Application mobile dédiée?

**Prévue pour v1.2!**

Fonctionnalités planifiées:
- Configuration des joueurs
- Affichage du score
- Historique des matchs
- Statistiques

Plateformes:
- Android (React Native)
- iOS (React Native)

---

## Avancé

### 🔗 Peut-on chaîner plusieurs panneaux?

**Oui!**

**Configuration:**
```cpp
#define PANEL_RES_X 64     // Un panneau
#define PANEL_RES_Y 32
#define PANEL_CHAIN 1

// Pour 2 panneaux côte à côte (128x32):
#define PANEL_RES_X 128
#define PANEL_CHAIN 2
```

**Matériel:**
- Câble IDC 2x8 pour relier les panneaux
- Alimentation plus puissante (additionner les watts)

**Limites:**
- ESP32: jusqu'à 4 panneaux 32x64
- Au-delà: problèmes de RAM/performance

---

### 🎥 Caméra pour détection auto du score?

**Très avancé, prévu v2.0.**

**Concept:**
- ESP32-CAM en supplément
- Computer Vision (TensorFlow Lite)
- Détection de balle/joueurs
- Confirmation par eTags

**Complexité:** Projet à part entière

---

### 🌐 Intégration cloud/API?

**Prévu v1.2 via WiFi:**

```cpp
// Exemple d'endpoint REST:
GET /api/score
→ {"player1": 2, "player2": 3, "games": "4-3"}

POST /api/point
{"player": 1}
→ Ajoute un point
```

**Services possibles:**
- Firebase Realtime Database
- AWS IoT Core
- API custom

---

### 🔐 Sécurité BLE?

**Actuel (v1.0):** Aucune sécurité

Risques:
- Autres appareils BLE peuvent se connecter
- Pas d'authentification

**Amélioration v1.1:**
```cpp
// Pairing avec code PIN
// Whitelist des adresses MAC
// Chiffrement des communications
```

**Pour compétition:** Utiliser adresses MAC fixes

---

### ⚙️ Optimisation des performances?

**Déjà optimisé!**

Techniques utilisées:
- ✅ DMA pour refresh LED (pas de CPU)
- ✅ Double buffering
- ✅ Core 0 pour BLE, Core 1 pour LED

**Améliorer encore:**
```cpp
// Réduire la résolution:
#define PANEL_RES_X 32  // Au lieu de 64
#define PANEL_RES_Y 16  // Au lieu de 32

// Augmenter fréquence CPU:
setCpuFrequencyMhz(240);  // Max ESP32
```

---

### 🧪 Tests unitaires?

**Pas encore implémentés.**

**À venir:**
```cpp
// Exemple:
void test_addPoint() {
    Player p1;
    initPlayer(p1);
    addPoint(p1, player2, 1);
    assert(p1.points == 1);
}
```

Framework: Unity Test (PlatformIO)

---

## 🆘 Ma question n'est pas dans la FAQ

**Ressources supplémentaires:**

1. **[INDEX.md](INDEX.md)** - Navigation complète
2. **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Guide de dépannage
3. **[Documentation technique](ARCHITECTURE.md)** - Détails avancés
4. **Moniteur série** - Logs en temps réel
5. **GitHub Issues** - Communauté (si disponible)

**Contacter:**
- Forum ESP32: https://esp32.com
- Reddit: r/esp32
- Discord PadelDisplay (à créer)

---

**Cette FAQ sera mise à jour régulièrement!**

Dernière mise à jour: Avril 2026
