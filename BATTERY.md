# Mesure Batterie LiFePO4 12.8V 20Ah - Configuration

## Spécifications Batterie

**Modèle**: Batterie LiFePO4 12.8V 20000mAh 3S 12V 20Ah

### Caractéristiques
- **Chimie**: LiFePO4 (Lithium Fer Phosphate)
- **Configuration**: 3S (3 cellules en série)
- **Voltage nominal**: 12.8V (3 × 3.2V par cellule)
- **Voltage max (chargé)**: 13.8V (3 × 4.6V)
- **Voltage min (déchargé)**: 9.0V (3 × 3.0V)
- **Capacité**: 20Ah (20000mAh)
- **Durée de vie**: ~2000-5000 cycles
- **Auto-décharge**: Très faible (<3% par mois)

### Avantages LiFePO4 vs LiPo
✅ Plus sûre (pas de risque d'incendie)
✅ Durée de vie 5× supérieure
✅ Voltage stable sur toute la décharge
✅ Fonctionne par températures extrêmes
✅ Pas de gonflement

## Schéma de Câblage

### 1. Pont Diviseur de Tension

Pour mesurer une tension de 12.8V avec l'ADC de l'ESP32 (max 3.3V), il faut un diviseur de tension.

**Composants nécessaires:**
- Résistance R1: **100kΩ** (1/4W ou 1/8W)
- Résistance R2: **30kΩ** (1/4W ou 1/8W)
  - Alternative: 2× 15kΩ en série = 30kΩ
  - Alternative: 1× 27kΩ + 1× 3kΩ = 30kΩ
  - Alternative: 3× 10kΩ en série = 30kΩ

**Ratio de division**: 4.33:1
```
Vout = Vin × (R2 / (R1 + R2))
Vout = Vin × (30kΩ / 130kΩ)
Vout = Vin / 4.333
```

**Plages de mesure:**
- Batterie à 13.8V → 3.18V sur ADC ⚠️ (proche limite 3.3V, mais acceptable)
- Batterie à 12.8V → 2.95V sur ADC ✅
- Batterie à 9.0V → 2.08V sur ADC ✅

⚠️ **Note**: Avec R2=30kΩ, la tension maximale (3.18V) est proche de la limite ADC (3.3V). C'est fonctionnel mais si vous chargez au-delà de 13.8V, ajoutez une diode Zener 3.3V pour protection.

### 2. Schéma Électrique

```
                             ESP32
                          ┌─────────┐
Batterie LiFePO4          │         │
     12.8V                │  GPIO35 │◄──── Mesure ADC
       │                  │  (ADC1) │
       │                  │         │
       ├──────[+]─────────┤  VIN    │ (Alimentation 5V via régulateur)
       │                  │         │
       │    R1=100kΩ      │         │
       ├─────/\/\/\───┬───┤  GND    │
       │              │   │         │
       │    R2=25kΩ   │   └─────────┘
       └─────/\/\/\───┴──── GND commun
                      │
                   GPIO35
                   (ADC)
```

### 3. Connexions Détaillées

| Point de connexion | Câble | Destination |
|--------------------|-------|-------------|
| Batterie (+) 12.8V | Rouge | → VIN ESP32 via régulateur buck 5V |
| Batterie (+) 12.8V | Orange | → R1 (100kΩ) |
| Entre R1 et R2 | Jaune | → GPIO35 (ADC) |
| Batterie (−) GND | Noir | → GND ESP32 + GND panneau LED |
| R2 (25kΩ) | Noir | → GND commun |

### 4. Protection Circuit (Recommandé)

Pour protéger l'ADC contre les surtensions:

```
                       Diode Zener 3.3V
                            │
    GPIO35 ◄────────────────┼──────/\/\/\──── Diviseur
    (ADC)                   │      100Ω
                           GND
```

**Composants additionnels (FORTEMENT recommandés avec R2=30kΩ):**
- Diode Zener 3.3V (BZX55C3V3 ou similaire) - **IMPORTANT pour protection**
- Résistance de protection 100Ω en série

## Installation Physique

### Étape 1: Assemblage du Diviseur

1. **Souder les résistances**:
   ```
   R1 (100kΩ) ──┬── R2 (30kΩ)
               Point milieu
   ```

2. **Point de mesure**: Souder un fil au point milieu (entre R1 et R2)

3. **Isoler les soudures** avec gaine thermorétractable

### Étape 2: Connexion à l'ESP32

1. **Fil point milieu** → GPIO35 de l'ESP32
2. **Fil haut (R1)** → Borne (+) de la batterie
3. **Fil bas (R2)** → GND commun

### Étape 3: Régulateur Buck (si nécessaire)

Si vous alimentez l'ESP32 directement depuis la batterie 12.8V:

```
Batterie 12.8V ──► [Module Buck] ──► 5V ──► VIN ESP32
                   (LM2596 ou MP1584)
```

**Modules recommandés:**
- LM2596 DC-DC Buck (12V→5V, 3A)
- MP1584EN Mini Buck (12V→5V, 3A)
- Prix: 1-3€

### Étape 4: Alimentation Panneau LED

Le panneau LED P5 nécessite 5V. Deux options:

**Option A: Régulateur partagé (petit panneau)**
```
Batterie 12.8V ──► Buck 5V/5A ──┬──► VIN ESP32
                                └──► Panneau LED 5V
```

**Option B: Régulateurs séparés (recommandé)**
```
Batterie 12.8V ──┬──► Buck 5V/2A ──► VIN ESP32
                 └──► Buck 5V/4A ──► Panneau LED 5V
```

## Configuration Logicielle

Le code dans [src/main.cpp](src/main.cpp) est déjà configuré avec:

```cpp
#define BATTERY_PIN 35              // GPIO35 (ADC1_CHANNEL_7)
#define BATTERY_MAX_VOLTAGE 13.8    // 100% charge
#define BATTERY_NOM_VOLTAGE 12.8    // Nominal
#define BATTERY_MIN_VOLTAGE 9.0     // 0% (critique)
#define VOLTAGE_DIVIDER 4.333       // Ratio 4.33:1 (R1=100k, R2=30k)
```

### Affichage

L'indicateur de batterie s'affiche automatiquement sur le panneau LED:

| Couleur | Niveau | Description |
|---------|--------|-------------|
| 🟢 Vert | 75-100% | Batterie pleine |
| 🔵 Cyan | 50-74% | Bonne charge |
| 🟡 Jaune | 25-49% | Charge moyenne |
| 🟠 Orange | 10-24% | Batterie faible |
| 🔴 Rouge | 0-9% | Critique - Recharger! |

### Monitoring Serial

Ouvrir le moniteur série (115200 bauds) pour voir:

```
[Batterie] Voltage: 12.85V | Charge: 78% | ADC: 2621
[Batterie] Voltage: 12.81V | Charge: 76% | ADC: 2608
⚠️  ATTENTION: Batterie faible!  (si <20%)
🔴 CRITIQUE: Batterie très faible! Rechargez immédiatement. (si <10%)
```

## Calibration (si nécessaire)

Si les lectures semblent incorrectes:

### 1. Vérifier le Voltage Réel

Mesurer avec un multimètre le voltage réel de la batterie.

### 2. Ajuster le Diviseur

Si vous n'avez pas exactement 100kΩ et 30kΩ, recalculer:

```cpp
// Configuration actuelle: R1=100kΩ et R2=30kΩ
// Ratio = (100 + 30) / 30 = 4.333
#define VOLTAGE_DIVIDER 4.333

// Exemple: Si vous avez R1=100kΩ et R2=27kΩ  
// Ratio = (100 + 27) / 27 = 4.704
#define VOLTAGE_DIVIDER 4.704

// Exemple: Si vous avez R1=120kΩ et R2=30kΩ
// Ratio = (120 + 30) / 30 = 5.0
#define VOLTAGE_DIVIDER 5.0
```

### 3. Calibration ADC ESP32

L'ADC de l'ESP32 peut avoir jusqu'à ±10% d'erreur. Pour calibrer:

```cpp
// Mesurer voltage réel avec multimètre: ex 12.85V
// Comparer avec lecture Serial: ex 12.45V
// Facteur de correction: 12.85 / 12.45 = 1.032

float batteryVoltage = adcVoltage * VOLTAGE_DIVIDER * 1.032;
```

## Courbe de Décharge LiFePO4

Tension typique pendant la décharge:

```
Voltage │
13.8V ─┤ ████████████████████ 100%
13.5V ─┤ ███████████████████░  95%
13.2V ─┤ ██████████████████░░  85%
12.8V ─┤ ████████████░░░░░░░░  50% (nominal)
12.4V ─┤ ██████░░░░░░░░░░░░░░  20%
12.0V ─┤ ███░░░░░░░░░░░░░░░░░  10%
11.4V ─┤ █░░░░░░░░░░░░░░░░░░░   5%
10.5V ─┤ ░░░░░░░░░░░░░░░░░░░░   1%
 9.0V ─┤ ░░░░░░░░░░░░░░░░░░░░   0% (STOP!)
      └─┴─────────────────────
        Temps de décharge
```

**Note**: LiFePO4 maintient ~12.8V pendant la majorité de la décharge (plateau), contrairement aux LiPo qui descendent linéairement.

## Autonomie Estimée

Avec batterie 20Ah @ 12.8V = 256Wh:

| Composant | Consommation | Calcul |
|-----------|--------------|--------|
| ESP32 | 0.5W | 12.8V × 0.04A |
| Panneau LED P5 (max) | 15W | 5V × 3A |
| **Total** | **~15.5W** | |

**Autonomie** = 256Wh / 15.5W ≈ **16-17 heures** en usage continu

En usage réel (luminosité réduite, veille):
- **20-30 heures** en usage normal
- **40-50 heures** en mode économie

## Sécurité

⚠️ **Précautions importantes**:

1. ✅ **Ne jamais décharger sous 9.0V** (protection BMS recommandée)
2. ✅ **Utiliser un chargeur spécifique LiFePO4** (14.4V max)
3. ✅ **Isoler toutes les connexions** (gaine thermorétractable)
4. ✅ **Court-circuit**: Ajouter un fusible 5A sur le (+)
5. ✅ **Température**: LiFePO4 fonctionne de -20°C à +60°C
6. ⚠️ **Stockage**: Conserver à ~50% charge (12.8V)

## Dépannage

| Problème | Cause possible | Solution |
|----------|----------------|----------|
| Lecture 0V | Mauvaise connexion | Vérifier soudures du diviseur |
| Lecture >15V | Diviseur incorrect | Vérifier R1=100k, R2=25k |
| Lecture instable | Interférences | Ajouter condensateur 100nF sur ADC |
| Pourcentage bloqué à 100% | Seuil trop bas | Ajuster BATTERY_MAX_VOLTAGE |
| Pourcentage toujours 0% | Diviseur inversé | Inverser R1 et R2 |

## Liste de Courses

Pour implémenter la mesure de batterie:

- [ ] Résistance 100kΩ 1/4W (×1) - 0.10€
- [ ] Résistance 25kΩ 1/4W (×1) ou 22k+3k - 0.10€
- [ ] Diode Zener 3.3V optionnelle (×1) - 0.20€
- [ ] Résistance 100Ω optionnelle (×1) - 0.10€
- [ ] Gaine thermorétractable 2mm (10cm) - 0.50€
- [ ] Module Buck DC-DC 12V→5V 3A+ (×1-2) - 2-5€
- [ ] Fusible 5A en ligne (×1) - 1€

**Total**: ~4-7€

## Test et Validation

Après installation:

1. **Vérifier avec multimètre**:
   - Mesurer batterie: devrait lire ~12.8V
   - Mesurer GPIO35 vs GND: devrait lire ~2.56V

2. **Moniteur série**:
   ```
   [Batterie] Voltage: 12.85V | Charge: 78% | ADC: 2621
   ```

3. **Affichage LED**:
   - Icône batterie visible en haut à droite
   - Couleur correspondant au niveau
   - Pourcentage lisible

4. **Test décharge**:
   - Laisser tourner 1 heure
   - Vérifier que le % diminue lentement

✅ **Système opérationnel!**
