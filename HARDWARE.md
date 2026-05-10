# Configuration Matérielle - Afficheur Padel

## Liste des Composants

### 1. Panneau LED P5 HUB75
- **Modèle**: Panneau RGB P5 Indoor
- **Résolution**: 32 lignes × 64 colonnes = 2048 LEDs
- **Dimensions physiques**: 320mm × 160mm
- **Pitch**: 5mm entre chaque LED
- **Scan**: 1/16
- **Interface**: HUB75 (connecteur IDC 2×8 broches)
- **Voltage**: 5V DC
- **Consommation max**: ~15W (3A @ 5V)
- **Prix estimé**: 15-25€

### 2. ESP32 Development Board
- **Modèle**: ESP32-DevKitC ou compatible CH340C
- **Broches**: 30 pins
- **Chipset**: ESP32-WROOM-32
- **Bluetooth**: BLE 4.2+
- **Voltage**: 5V via USB ou VIN
- **Prix estimé**: 5-10€

### 3. eTags BLE (x2)
- **Type**: Trackers Bluetooth (iTags, Tiles, ou similaires)
- **Standard**: BLE 4.0+
- **Bouton**: Détection de clics simples/doubles
- **Batterie**: CR2032 (autonomie 6-12 mois)
- **Portée**: 10-30 mètres
- **Prix estimé**: 5-10€ chacun

### 4. Alimentation

#### Option A: Alimentation Secteur (usage fixe)
- **Voltage**: 5V DC
- **Ampérage**: Minimum 3A, recommandé 4-5A
- **Type**: Adaptateur secteur avec connecteur DC
- **Câble**: Adaptateur DC vers bornier à vis ou JST
- **Prix estimé**: 10-15€

#### Option B: Batterie Portable (usage mobile) ⭐ RECOMMANDÉ
- **Type**: Batterie LiFePO4 12.8V 20Ah (3S)
- **Capacité**: 20000mAh / 256Wh
- **Autonomie**: 16-30 heures selon luminosité
- **Régulateur**: Module Buck DC-DC 12V→5V (×2)
  - 1× pour ESP32 (2-3A)
  - 1× pour panneau LED (4-5A)
- **Chargeur**: Chargeur LiFePO4 14.4V (spécifique!)
- **Prix estimé**: 40-60€ (batterie) + 5€ (régulateurs)
- **Avantages**: Portable, sûr, longue durée de vie
- **Documentation**: Voir [BATTERY.md](BATTERY.md)

### 5. Câbles et Connecteurs
- Câble USB Micro-B ou USB-C (selon ESP32)
- Câble d'alimentation 5V pour panneau LED
- Fils de connexion Dupont femelle-femelle (pour HUB75)
- Longueur recommandée: 20cm

## Schéma de Connexion

### Brochage HUB75 vers ESP32

Le connecteur HUB75 standard (vue de face du panneau):

```
HUB75 Connector (16 pins - 2x8):
┌─────────────────────────┐
│ R1  G1  B1  GND  R2  G2  B2  E   │
│ A   B   C   D   CLK  LAT STB GND │
└─────────────────────────┘
```

### Connexions ESP32 ↔ HUB75

| Signal HUB75 | Broche ESP32 | Description |
|--------------|--------------|-------------|
| R1           | GPIO25       | Rouge - rangée haute |
| G1           | GPIO26       | Vert - rangée haute |
| B1           | GPIO27       | Bleu - rangée haute |
| R2           | GPIO14       | Rouge - rangée basse |
| G2           | GPIO12       | Vert - rangée basse |
| B2           | GPIO13       | Bleu - rangée basse |
| A            | GPIO23       | Sélection ligne bit 0 |
| B            | GPIO19       | Sélection ligne bit 1 |
| C            | GPIO5        | Sélection ligne bit 2 |
| D            | GPIO17       | Sélection ligne bit 3 |
| E            | GPIO18       | Sélection ligne bit 4 (pour scan 1/16) |
| CLK          | GPIO16       | Horloge |
| LAT (STB)    | GPIO4        | Latch / Strobe |
| OE           | GPIO15       | Output Enable |
| GND          | GND          | Masse commune |

### Connexions ESP32 ↔ - Alimentation Secteur

```
┌──────────────────┐
│   Alimentation   │
│      5V/4A       │
└────┬────────┬────┘
     │        │
     │        └──────────────┐
     │                       │
     │                  ┌────▼────┐
     │                  │  ESP32  │
     │                  │ CH340C  │
     │                  │ 30-pin  │
     │                  └────┬────┘
     │                       │ GPIO (HUB75)
     │                       │
     │                  ┌────▼────────┐
     └─────────────────►│  Panneau    │
       (5V Power)       │  LED P5     │
                        │  32x64px    │
                        │  HUB75      │
                        └─────────────┘

    ┌─────────┐              ┌─────────┐
    │ eTag BLE│◄────BLE─────►│         │
    │ Joueur 1│              │  ESP32  │
    └─────────┘              │         │
                             │         │
    ┌─────────┐              │         │
    │ eTag BLE│◄────BLE─────►│         │
    │ Joueur 2│              └─────────┘
    └─────────┘
```

### Schéma de Principe - Batterie LiFePO4 (Portable)

```
  ┌─────────────────────────────────────────┐
  │   Batterie LiFePO4 12.8V 20Ah (3S)      │
  │         256Wh - Autonomie 20h+          │
  └──┬─────────────┬────────────────┬───────┘
     │             │                │
     │ 12.8V       │ 12.8V          │ Mesure
     │             │                │
┌────▼─────┐  ┌───▼──────┐    ┌────▼─────────────┐
│Buck 5V/2A│  │Buck 5V/4A│    │Pont Diviseur 5:1 │
│ (ESP32)  │  │ (LED)    │    │ R1=100kΩ         │
└────┬─────┘  └───┬──────┘    │ R2=25kΩ          │
     │ 5V         │ 5V        └────┬─────────────┘
     │            │                │ ~2.56V
     │       ┌────▼────────┐       │
     │       │  Panneau    │       │
     │       │  LED P5     │       │
     │       │  32x64px    │       │
     │       │  HUB75      │       │
     │       └────▲────────┘       │
     │            │ GPIO(HUB75)    │ GPIO35(ADC)
     │       ┌────┴────────────────┴─┐
     └──────►│      ESP32 CH340C     │
       5V    │       30-pin          │
             │   + Mesure Batterie   │
             └────▲──────────▲───────┘
                  │BLE       │BLE
           ┌──────┴───┐  ┌───┴──────┐
           │eTag BLE  │  │eTag BLE  │
           │Joueur 1  │  │Joueur 2  │
           └──────────┘  └──────────┘

Indicateur batterie affiché sur LED:
🟢 75-100%  🔵 50-74%  🟡 25-49%  🟠 10-24%  🔴 0-9%────────►│  Panneau    │
       (5V Power)       │  LED P5     │
                        │  32x64px    │
                        │  HUB75      │
                        └─────────────┘

    ┌─────────┐              ┌─────────┐
    │ eTag BLE│◄────BLE─────►│         │
    │ Joueur 1│              │  ESP32  │
    └─────────┘              │         │
                             │         │
    ┌─────────┐              │         │
    │ eTag BLE│◄────BLE─────►│         │
    │ Joueur 2│              └─────────┘
    └─────────┘
```

## Montage Physique

### Étape 1: Connexion du Panneau LED

1. **Identifier le connecteur HUB75** sur le panneau LED (généralement marqué "INPUT")

2. **Câblage GPIO → HUB75**:
   - Option A: Utiliser un câble HUB75 femelle et souder/connecter aux GPIO
   - Option B: Créer un adaptateur PCB (recommandé pour installation permanente)
   - Option C: Utiliser un shield ESP32-HUB75 (disponible sur AliExpress/Amazon)

3. **Connexion de masse**: 
   - Relier GND de l'ESP32 à GND du panneau LED
   - Important pour éviter les problèmes de référence de tension

### Étape 2: Alimentation

⚠️ **IMPORTANT**: Le panneau LED nécessite une alimentation **séparée** de l'ESP32

1. **Panneau LED**:
   - Connecter le 5V/GND au bornier d'alimentation du panneau
   - Vérifier la polarité (rouge = +5V, noir = GND)

2. **ESP32**:
   - Alimentation via port USB (développement)
   - OU via broche VIN (5V) pour utilisation permanente
   - Partager le GND avec l'alimentation principale

### Étape 3: Appairage des eTags BLE

1. **Activation**:
   - Insérer la pile CR2032
   - Appuyer sur le bouton pour activer le mode découverte

2. **Identification**:
   - Utiliser le moniteur série de l'ESP32
   - Scanner les appareils BLE disponibles
   - Noter les adresses MAC des eTags

3. **Configuration**:
   - Éditer le fichier `main.cpp`
   - Renseigner les adresses MAC dans `PLAYER1_MAC` et `PLAYER2_MAC`

## Boîtier et Installation (Optionnel)

### Recommandations

- **Matériau**: Plastique ou aluminium pour dissipation thermique
- **Ventilation**: Prévoir des aérations pour l'ESP32 et l'alimentation
- **Fixation**: Supports muraux ou sur pied
- **Protection**: IP20 minimum (intérieur)

### Dimensions minimales du boîtier

- Largeur: 340mm (320 + 20mm marges)
- Hauteur: 180mm (160 + 20mm marges)
- Profondeur: 40mm (panneau + ESP32 + câbles)

## Sécurité

⚠️ **Précautions**:

1. ✅ Toujours débrancher l'alimentation avant manipulation
2. ✅ Vérifier la polarité avant connexion (risque de destruction)
3. ✅ Ne pas dépasser 5.5V (risque de destruction des LEDs)
4. ✅ Utiliser une alimentation avec protection contre les courts-circuits
5. ✅ Ne pas regarder directement les LEDs à pleine intensité
6. ✅ Respecter les normes électriques locales

## Tests et Validation

### Test 1: Alimentation
```
1. Brancher uniquement l'alimentation 5V au panneau
2. Le panneau doit rester éteint (normal)
3. Vérifier avec un multimètre: 5V ± 0.25V
```

### Test 2: ESP32
```
1. Connecter l'ESP32 via USB au PC
2. Ouvrir le moniteur série (115200 bauds)
3. Vérifier les messages de démarrage
```

### Test 3: Affichage
```
1. Téléverser le code de test
2. Le panneau doit afficher des patterns de test
3. Vérifier toutes les couleurs (R, G, B, blanc)
```

### Test 4: BLE
```
1. Activer les eTags
2. Vérifier la détection dans le moniteur série
3. Tester les clics simples et doubles
4. Vérifier l'incrémentation/décrémentation des scores
```

## Dépannage Matériel

| Problème | Cause possible | Solution |
|----------|----------------|----------|
| Panneau noir | Pas d'alimentation | Vérifier 5V |
| Panneau noir | Pas de signal | Vérifier connexions HUB75 |
| Couleurs incorrectes | Fils RGB inversés | Vérifier R1, G1, B1, R2, G2, B2 |
| Scintillement | Mauvaise masse | Connecter GND ESP32 ↔ Panneau |
| Lignes décalées | Adressage incorrect | Vérifier A, B, C, D, E |
| Pas de BLE | Tags éteints | Remplacer piles CR2032 |
| BLE instable | Portée insuffisante | Rapprocher les tags |
| ESP32 chauffe | Court-circuit | Vérifier toutes les connexions |

## Améliorations Possibles

1. **Shield PCB personnalisé**: Créer un PCB pour connexions propres
2. **Connecteur RJ45**: Utiliser un câble Ethernet pour HUB75 (8 paires)
3. **Boutons physiques**: Ajouter des boutons backup en cas de problème BLE
4. **Écran OLED**: Afficher l'état de connexion BLE
5. **ESP32-S3**: Version avec plus de RAM pour panneaux plus grands
6. **Batterie**: Ajout d'une batterie Li-Po pour portabilité

## Fournisseurs Recommandés

- **Panneaux LED**: AliExpress, BTF-Lighting, Adafruit
- **ESP32**: Amazon, AliExpress, Mouser, Digikey
- **eTags BLE**: Amazon, AliExpress (rechercher "iTAG" ou "BLE tracker")
- **Alimentation**: Meanwell (LRS-150-5), alimentation générique 5V

## Support Technique

Pour toute question sur le câblage ou le matériel, consulter:
- Forum ESP32: https://esp32.com
- GitHub ESP32-HUB75: https://github.com/mrfaptastic/ESP32-HUB75-MatrixPanel-DMA
