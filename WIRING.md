# Schéma de Connexion Détaillé

## Vue d'Ensemble du Système

```
                               ┌─────────────────────────────────────┐
                               │    Alimentation AC 220V             │
                               └──────────┬──────────────────────────┘
                                          │
                                          ▼
                               ┌─────────────────────┐
                               │  Adaptateur 5V/4A   │
                               │  (DC Power Supply)  │
                               └──────┬──────────────┘
                                      │
                         ┌────────────┼────────────┐
                         │            │            │
                         │            │            │
                         ▼            ▼            │
                  ┌──────────┐  ┌──────────┐      │
                  │  ESP32   │  │ Panneau  │──────┘
                  │ DevKit   │  │ LED P5   │   (Power)
                  │ 30-pin   │  │ 32x64px  │
                  └─────┬────┘  └────┬─────┘
                        │            │
                        └────────────┘
                          (Signal HUB75)

                  ┌──────────┐              ┌──────────┐
                  │  eTag    │              │  eTag    │
                  │ Joueur 1 │◄────BLE────► │ Joueur 2 │
                  │ (Gauche) │     ESP32    │ (Droite) │
                  └──────────┘              └──────────┘
```

## Brochage Détaillé ESP32 → HUB75

### Vue du Connecteur HUB75 (côté panneau)

```
┌─────────────────────────────────────────────┐
│  Connecteur HUB75 - Vue de Face du Panneau  │
│                    (16 pins)                │
└─────────────────────────────────────────────┘

Pin Layout (2x8 IDC Connector):

Rangée Supérieure:
┌────┬────┬────┬────┬────┬────┬────┬────┐
│ R1 │ G1 │ B1 │GND │ R2 │ G2 │ B2 │ E  │
└────┴────┴────┴────┴────┴────┴────┴────┘
  1    2    3    4    5    6    7    8

Rangée Inférieure:
┌────┬────┬────┬────┬────┬────┬────┬────┐
│ A  │ B  │ C  │ D  │CLK │LAT │ OE │GND │
└────┴────┴────┴────┴────┴────┴────┴────┘
  9   10   11   12   13   14   15   16
```

### Tableau de Connexion Complet

| Pin HUB75 | N° Pin | Couleur Câble | GPIO ESP32 | Fonction |
|-----------|--------|---------------|------------|----------|
| R1 | 1 | Rouge | GPIO 25 | Rouge - Moitié haute |
| G1 | 2 | Vert | GPIO 26 | Vert - Moitié haute |
| B1 | 3 | Bleu | GPIO 27 | Bleu - Moitié haute |
| GND | 4 | Noir | GND | Masse (rangée haute) |
| R2 | 5 | Rouge/Blanc | GPIO 14 | Rouge - Moitié basse |
| G2 | 6 | Vert/Blanc | GPIO 12 | Vert - Moitié basse |
| B2 | 7 | Bleu/Blanc | GPIO 13 | Bleu - Moitié basse |
| E | 8 | Gris | GPIO 18 | Adresse ligne E (scan 1/16) |
| A | 9 | Jaune | GPIO 23 | Adresse ligne A (bit 0) |
| B | 10 | Orange | GPIO 19 | Adresse ligne B (bit 1) |
| C | 11 | Marron | GPIO 5 | Adresse ligne C (bit 2) |
| D | 12 | Violet | GPIO 17 | Adresse ligne D (bit 3) |
| CLK | 13 | Blanc | GPIO 16 | Horloge (Clock) |
| LAT | 14 | Gris | GPIO 4 | Latch / Strobe |
| OE | 15 | Vert foncé | GPIO 15 | Output Enable (actif bas) |
| GND | 16 | Noir | GND | Masse (rangée basse) |

## Schéma de Câblage Électrique

### Alimentation du Panneau LED

```
Adaptateur 5V/4A
┌─────────────┐
│   ○ AC IN   │    ← Prise 220V secteur
│             │
│   +  5V  -  │    ← Sortie DC
└──┬───────┬──┘
   │       │
   │+ 5V   │- GND
   │       │
   │       │
   ▼       ▼
┌──────────────────┐
│  Panneau LED P5  │
│                  │
│  ┌────────────┐  │
│  │ Bornier DC │  │
│  │  +    -    │  │
│  └────────────┘  │
└──────────────────┘
```

**⚠️ Important:**
- Respecter la polarité: Rouge = +5V, Noir = GND
- Vérifier la tension avant connexion (5V ± 0.25V)
- Ne pas dépasser 5.5V (risque de destruction)

### Alimentation de l'ESP32

**Option 1: Via USB (Développement)**
```
PC/Laptop
    │ USB
    └──────► [ESP32] ──► Programmation + Alimentation
```

**Option 2: Via VIN (Production)**
```
Alimentation 5V
    │
    ├──► Panneau LED (direct)
    │
    └──► ESP32 VIN pin ──► Régulateur interne 3.3V
```

**Option 3: Alimentation Commune (Recommandé)**
```
Alimentation 5V/4A
    │
    ├───► Panneau LED (+, -)
    │
    └───► ESP32 VIN (+) et GND (-)
          (Partage du GND obligatoire)
```

## Connexion des Signaux GPIO

### Méthode A: Fils Dupont (Prototype)

```
ESP32                          Panneau HUB75
┌────────┐                    ┌──────────────┐
│        │                    │              │
│ GPIO25 ├────────────────────┤ R1           │
│ GPIO26 ├────────────────────┤ G1           │
│ GPIO27 ├────────────────────┤ B1           │
│ GPIO14 ├────────────────────┤ R2           │
│ GPIO12 ├────────────────────┤ G2           │
│ GPIO13 ├────────────────────┤ B2           │
│ GPIO23 ├────────────────────┤ A            │
│ GPIO19 ├────────────────────┤ B            │
│ GPIO5  ├────────────────────┤ C            │
│ GPIO17 ├────────────────────┤ D            │
│ GPIO18 ├────────────────────┤ E            │
│ GPIO16 ├────────────────────┤ CLK          │
│ GPIO4  ├────────────────────┤ LAT          │
│ GPIO15 ├────────────────────┤ OE           │
│ GND    ├────────────────────┤ GND          │
│        │                    │              │
└────────┘                    └──────────────┘
```

**Matériel requis:**
- 15x fils Dupont femelle-femelle (20cm)
- Ou 1x nappe de 16 fils

### Méthode B: Shield PCB (Production)

Pour une installation permanente, créer un PCB avec:
- Connecteur femelle pour ESP32 (30 pins)
- Connecteur IDC 2x8 pour câble HUB75
- Pistes de connexion selon le tableau ci-dessus
- Condensateurs de découplage (100nF sur chaque VCC)

## Configuration BLE - eTags

### Identification des eTags

Chaque eTag doit être identifiable. Deux méthodes:

**Méthode 1: Auto-détection**
```cpp
// Dans main.cpp, laisser vides:
String PLAYER1_MAC = "";
String PLAYER2_MAC = "";
```
Le système détectera automatiquement les 2 premiers iTags.

**Méthode 2: Adresses MAC fixées**
```cpp
// Dans main.cpp, spécifier les adresses:
String PLAYER1_MAC = "AA:BB:CC:DD:EE:FF";
String PLAYER2_MAC = "11:22:33:44:55:66";
```

### Trouver l'Adresse MAC d'un eTag

1. Téléverser le programme
2. Ouvrir le moniteur série (115200 bauds)
3. Activer l'eTag (appui sur bouton)
4. Observer le log:
```
BLE Découvert: Name: iTAG, Address: aa:bb:cc:dd:ee:ff
```
5. Noter l'adresse et la copier dans le code

### Portée BLE

```
Distance Recommandée:
┌──────────┐
│  eTag    │ ─── 0-10m ───┐
└──────────┘              │  (Optimal)
                          │
                     ┌────▼────┐
┌──────────┐         │  ESP32  │
│  eTag    │ ─── 0-10m ───┤         │
└──────────┘         └─────────┘
                          │
                     10-30m max
                     (Avec obstacles)
```

## Liste de Vérification du Câblage

### ✅ Avant la Première Mise Sous Tension

- [ ] Tous les fils GPIO sont connectés aux bonnes broches
- [ ] Les GND sont connectés (ESP32 ⇄ Panneau)
- [ ] L'alimentation 5V est correctement polarisée
- [ ] Aucun court-circuit entre +5V et GND
- [ ] Les fils sont bien insérés (pas de faux contact)
- [ ] Le câble USB de l'ESP32 est connecté
- [ ] Les eTags ont des piles neuves

### ✅ Test de Continuit (Multimètre)

1. **Mode ohmmètre**: Vérifier chaque connexion
2. **ESP32 GPIO → HUB75 Pin**: < 1Ω (bon contact)
3. **GND ESP32 → GND Panneau**: 0Ω (obligatoire)
4. **+5V → GND**: ∞Ω (pas de court-circuit)

### ✅ Test de Tension (Multimètre)

1. **Alimentation non connectée au panneau**
2. Mesurer sortie adaptateur: 5.0V ± 0.2V
3. Si OK, connecter au panneau
4. Mesurer tension aux bornes du panneau: 4.8-5.2V
5. Si OK, connecter l'ESP32

## Dépannage des Connexions

| Symptôme | Cause Probable | Solution |
|----------|----------------|----------|
| Panneau noir | Pas de 5V | Vérifier alimentation |
| Panneau noir | Signaux HUB75 KO | Vérifier GPIO R1,G1,B1... |
| Couleurs erronées | RGB inversés | Permuter R1/G1/B1 et R2/G2/B2 |
| Moitié d'écran OK | R2/G2/B2 déconnectés | Vérifier câblage moitié basse |
| Lignes clignotent | Pas de GND commun | Relier GND ESP32 ↔ Panneau |
| Affichage décalé | A/B/C/D/E erronés | Vérifier adressage |
| M'affiche rien | OE déconnecté | Vérifier GPIO15 → OE |
| Affichage figé | CLK déconnecté | Vérifier GPIO16 → CLK |
| Affichage flou | LAT déconnecté | Vérifier GPIO4 → LAT |

## Améliorations Possibles

### 1. PCB Personnalisé

Créer un shield ESP32 avec:
- Connecteur femelle 30 pins pour ESP32
- Connecteur IDC 2x8 pour HUB75
- Bornier alimentation 5V
- LED de status
- Bouton reset
- Régulateur 3.3V (optionnel)

### 2. Câble HUB75 Professionnel

Utiliser un câble IDC 2x8 avec connecteurs:
- Longueur: 30-50cm
- Couleurs standards pour chaque signal
- Meilleure fiabilité que fils Dupont

### 3. Boîtier avec Connecteurs

```
┌─────────────────────────────────┐
│  Boîtier Personnalisé           │
│                                 │
│  [USB] ←── ESP32                │
│  [RJ45] ←── HUB75 (optionnel)   │
│  [DC 5V] ←── Alimentation       │
│  [ON/OFF] ←── Interrupteur      │
│                                 │
└─────────────────────────────────┘
```

### 4. Protection

- **Diode de protection**: Anti-retour sur 5V
- **Fusible**: 5A sur alimentation
- **TVS**: Protection ESD sur signaux
- **Condensateurs**: 100µF sur 5V, 100nF par IC

## Ressources Additionnelles

### Datasheets
- ESP32-WROOM-32: [Espressif](https://espressif.com/documentation)
- HUB75 Protocol: [GitHub Pixelmatix](https://github.com/pixelmatix/SmartMatrix/wiki)

### Outils Utiles
- Multimètre: Vérification tensions et continuité
- Pince ampèremétrique: Mesure consommation
- Oscilloscope: Debug signaux (avancé)

### Fournisseurs de Composants
- **France**: GoTronic, Lextronic, Conrad
- **International**: Mouser, DigiKey, Farnell
- **Chine**: AliExpress, Banggood (délai 2-4 semaines)

---

**Bonne construction! En cas de doute, toujours débrancher l'alimentation avant manipulation.**
