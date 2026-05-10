# Guide Rapide - Installation Mesure Batterie

## Installation en 5 Étapes ⚡

### Étape 1️⃣ : Assembler le Diviseur de Tension (5 min)

```
Composants:
├─ R1: 100kΩ (Marron-Noir-Jaune-Or)
└─ R2: 30kΩ (Orange-Noir-Orange-Or)
    Alternative: 3× 10kΩ (Marron-Noir-Orange-Or) en série

Schéma:
    R1 (100kΩ)
    ┌────/\/\/\────┐
    │              │
Bat(+)          Point milieu ───► vers GPIO35
                   │              (+ Zener 3.3V recommandée)
              R2 (30kΩ)
              ────/\/\/\────
                   │
                  GND
```

**Assemblage:**
1. Souder R1 et R2 bout à bout (ou 3× 10kΩ pour faire 30kΩ)
2. Le point de jonction = point milieu
3. **[RECOMMANDÉ]** Ajouter diode Zener 3.3V entre GPIO35 et GND
4. Souder 3 fils:
   - Fil 1 (Rouge): Au-dessus de R1 → Batterie (+)
   - Fil 2 (Jaune): Point milieu → GPIO35
   - Fil 3 (Noir): Dessous de R2 → GND
5. Isoler avec gaine thermorétractable

### Étape 2️⃣ : Connexion à l'ESP32 (2 min)

```
┌───────────────────────────────┐
│         ESP32 CH340C          │
│         (30 broches)          │
├───────────────────────────────┤
│                               │
│  VIN ◄──── Buck 5V/2A ◄───┐   │
│                           │   │
│  GPIO35 ◄──── Fil Jaune   │   │ 
│  (ADC)        (Point      │   │
│               milieu)     │   │
│                           │   │
│  GND ◄──── Fil Noir ──────┴───┼─── Batterie (−)
│            (R2 bas)           │
│                               │
└───────────────────────────────┘
         ▲
         │
    Fil Rouge
    (R1 haut)
         │
    Batterie (+) 12.8V
```

**Connexions:**
1. **Fil Rouge** (Batterie +) → Ne PAS connecter directement! Passer par Buck
2. **Fil Jaune** (Point milieu) → GPIO35
3. **Fil Noir** (GND) → GND de l'ESP32

### Étape 3️⃣ : Installer les Régulateurs Buck (10 min)

```
Batterie LiFePO4 12.8V
    │
    ├─────► [Buck #1: 12V→5V/2A] ──► VIN ESP32
    │        (MP1584EN)
    │
    └─────► [Buck #2: 12V→5V/4A] ──► Panneau LED
             (LM2596)
```

**Configuration des Buck:**

**Pour Buck ESP32 (sortie 5V/2A):**
1. NE PAS connecter la sortie
2. Alimenter l'entrée avec la batterie (12.8V)
3. Mesurer la sortie avec multimètre
4. Tourner le potentiomètre jusqu'à lire **5.0V** ±0.1V
5. Déconnecter, puis connecter à VIN ESP32

**Pour Buck LED (sortie 5V/4A):**
1. Répéter le processus ci-dessus
2. Régler également à **5.0V**
3. Connecter au panneau LED

⚠️ **IMPORTANT**: Toujours régler AVANT de connecter la charge!

### Étape 4️⃣ : Calibration ADC (5 min)

**Dans le moniteur série (115200 bauds):**

1. Compiler et uploader le code
2. Observer les messages:
   ```
   [Batterie] Voltage: 12.45V | Charge: 76% | ADC: 3021
   ```

3. **Mesurer avec multimètre** le voltage réel de la batterie:
   - Exemple: Multimètre = **12.85V**
   - Code affiche = **12.45V**

4. **Calculer facteur de correction:**
   ```
   Facteur = Voltage_réel / Voltage_affiché
   Facteur = 12.85 / 12.45 = 1.032
   ```

5. **Modifier le code** (si nécessaire):
   
   Localiser dans [src/main.cpp](src/main.cpp) la fonction `getBatteryVoltage()`:
   ```cpp
   float batteryVoltage = adcVoltage * VOLTAGE_DIVIDER;
   ```
   
   Modifier en:
   ```cpp
   float batteryVoltage = adcVoltage * VOLTAGE_DIVIDER * 1.032;
   //                                                    ^^^^^ votre facteur
   ```

⚠️ **Note avec R2=30kΩ**: Les valeurs ADC seront plus élevées (~2.95V pour 12.8V batterie)

6. Re-compiler et vérifier que les valeurs correspondent

### Étape 5️⃣ : Test Final (5 min)

**Checklist de validation:**

✅ **Test voltage:**
```
Serial Monitor:
[Batterie] Voltage: 12.85V | Charge: 78% | ADC: 3021
                    ^^^^^^                   ^^^^
                    Proche du   ADC entre
                    multimètre  2400-3200 (avec R2=30k)
```

✅ **Test affichage LED:**
- Icône batterie visible en haut à droite
- Couleur cohérente avec le pourcentage:
  - 🟢 Vert si >75%
  - 🔵 Cyan si 50-75%
  - 🟡 Jaune si 25-50%
  - 🟠 Orange si 10-25%
  - 🔴 Rouge si <10%

✅ **Test décharge:**
1. Noter le pourcentage actuel
2. Laisser fonctionner 30 minutes
3. Vérifier que le % a légèrement diminué (normal)

✅ **Test alertes:**
1. Dans le Serial Monitor, simuler batterie faible
2. Vérifier les messages d'alerte

---

## Schéma Complet Final

```
╔═══════════════════════════════════════════════════════════════╗
║           SYSTÈME COMPLET AVEC BATTERIE LiFePO4               ║
╚═══════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────┐
│  BATTERIE LiFePO4 12.8V 20Ah (256Wh)                        │
│  Autonomie: 20-30 heures                                    │
└──┬──────────────────┬───────────────────┬──────────────────┘
   │ (+) 12.8V        │ (+) 12.8V         │ (+) 12.8V
   │                  │                   │
┌──▼────────────┐  ┌──▼────────────┐     │   Diviseur 4.33:1
│ Buck DC-DC    │  │ Buck DC-DC    │     │   ┌────/\/\/\─── R1=100kΩ
│  MP1584EN     │  │  LM2596       │     ├───┤
│  12V → 5V/2A  │  │  12V → 5V/4A  │     │   ├────/\/\/\─── R2=30kΩ
│               │  │               │     │   │    │
└──┬────────────┘  └──┬────────────┘     │   └────┬────────
   │ 5V               │ 5V                │        │ Point milieu (+ Zener 3.3V)
   │                  │                   │        │
┌──▼──────────────────┴───────────────────┴──┐   ┌▼─────────────────┐
│           ESP32 CH340C (30 pins)           │   │ Fil vers GPIO35  │
│  ┌──────────────────────────────────────┐  │   └──────────────────┘
│  │ • VIN ◄─── 5V Buck #1                │  │   │
│  │ • GPIO35 ◄─── Mesure batterie ───────┼──┼───┘
│  │ • GPIO16-27 ──► Signaux HUB75        │  │
│  │ • BLE ◄──► eTags Joueurs 1 & 2      │  │
│  └──────────────────────────────────────┘  │
└──────────────┬─────────────────────────────┘
               │ Signaux HUB75
               │ (R1,G1,B1,R2,G2,B2,A-E,CLK,LAT,OE)
               │
         ┌─────▼──────────────────┐
         │  Panneau LED P5        │    ┌──────────────┐
         │  32×64 pixels          │◄───┤ Buck #2      │
         │  320×160mm             │    │ 5V/4A        │
         │  Indoor RGB            │    └──────────────┘
         └────────────────────────┘

    ┌──────────┐         Bluetooth        ┌──────────┐
    │ eTag BLE │◄────────────────────────► │          │
    │ Joueur 1 │          Low Energy       │  ESP32   │
    │ 1 clic   │                           │          │
    │ 2 clics  │                           │          │
    └──────────┘                           │          │
                                           │          │
    ┌──────────┐                           │          │
    │ eTag BLE │◄──────────────────────────┤          │
    │ Joueur 2 │                           └──────────┘
    └──────────┘

┌──────────────────────────────────────────────────────────────┐
│  AFFICHAGE PANNEAU LED                                       │
│  ┌────────────────────────────────────────────────────────┐  │
│  │   15 - 30          [Joueur 1] - [Joueur 2]            │  │
│  │                                                        │  │
│  │   [2] - [1]            Jeux du set              🔋 78 │  │
│  │    ●       ●       BLE connectés                      │  │
│  └────────────────────────────────────────────────────────┘  │
│  Points   Jeux   Indicateur BLE   Batterie avec couleur    │
└──────────────────────────────────────────────────────────────┘
```

---

## Dépannage Rapide

### Problème: Lecture 0.00V

**Causes possibles:**
- ❌ Diviseur mal connecté
- ❌ GPIO35 non connecté
- ❌ Batterie déconnectée

**Solutions:**
1. Vérifier continuité avec multimètre:
   - Batterie (+) → R1 haut
   - R1-R2 jonction → GPIO35
   - R2 bas → GND
2. Mesurer au point milieu: Devrait lire ~2.56V avec batterie 12.8V

### Problème: Lecture >15V affichée

**Cause:**
- ❌ Diviseur inversé (R1 et R2 échangés)

**Solution:**
1. Vérifier: R1 (100kΩ) est côté batterie
2. Vérifier: R2 (25kΩ) est côté GND
3. Inverser si nécessaire

### Problème: Pourcentage toujours 100% ou 0%

**Causes:**
- ❌ `BATTERY_MAX_VOLTAGE` incorrect
- ❌ `BATTERY_MIN_VOLTAGE` incorrect
- ❌ Diviseur mal calculé

**Solutions:**
1. Vérifier dans le code:
   ```cpp
   #define BATTERY_MAX_VOLTAGE 13.8
   #define BATTERY_MIN_VOLTAGE 9.0
   #define VOLTAGE_DIVIDER 5.0
   ```
2. Mesurer résistances réelles avec multimètre
3. Recalculer ratio si différent

### Problème: Valeurs qui sautent (instables)

**Causes:**
- ❌ Interférences électromagnétiques
- ❌ Câbles trop longs
- ❌ Pas de filtrage
- ❌ Pas de protection Zener (avec R2=30kΩ)

**Solutions:**
1. **Installer diode Zener 3.3V** entre GPIO35 et GND (stabilise la tension)
2. Ajouter condensateur 100nF entre GPIO35 et GND
3. Raccourcir le fil entre diviseur et GPIO35 (<15cm)
4. Torsader les fils du diviseur ensemble
5. Éloigner du panneau LED et régulateurs Buck

### Problème: ESP32 ne démarre pas

**Causes:**
- ❌ Buck mal réglé (>5.5V détruit l'ESP32!)
- ❌ Polarité inversée
- ❌ Court-circuit

**Solutions:**
1. **AVANT** de connecter: Mesurer sortie Buck = 5.0V ±0.1V
2. Vérifier polarité avec multimètre
3. Déconnecter tout, tester ESP32 seul via USB

---

## Tableau de Référence Voltage ↔ Pourcentage

| Voltage Batterie | ADC GPIO35 | Pourcentage | État | Couleur LED |
|------------------|------------|-------------|------|-------------|
| 13.8V | 3.18V | 100% | Pleine charge | 🟢 Vert |
| 13.5V | 3.12V | 95% | Excellente | 🟢 Vert |
| 13.2V | 3.05V | 85% | Très bonne | 🟢 Vert |
| 13.0V | 3.00V | 75% | Bonne | 🟢 Vert |
| 12.8V | 2.95V | 65% | Normale | 🔵 Cyan |
| 12.5V | 2.88V | 50% | Moyenne | 🔵 Cyan |
| 12.2V | 2.82V | 35% | Acceptable | 🟡 Jaune |
| 12.0V | 2.77V | 25% | Faible | 🟡 Jaune |
| 11.5V | 2.65V | 15% | Très faible | 🟠 Orange |
| 11.0V | 2.54V | 10% | Critique | 🔴 Rouge |
| 10.0V | 2.31V | 5% | Arrêt imminent | 🔴 Rouge |
| 9.0V | 2.08V | 0% | ⚠️ ARRÊTER! | 🔴 Rouge |

⚠️ **Note**: Avec R2=30kΩ, les tensions ADC sont plus élevées. La diode Zener 3.3V protège contre les dépassements.

---

## Temps d'Installation Total

| Étape | Durée | Compétence |
|-------|-------|------------|
| Assemblage diviseur | 5-10 min | Facile |
| Connexion ESP32 | 2 min | Facile |
| Réglage Buck modules | 10-15 min | Moyen |
| Calibration ADC | 5-10 min | Facile |
| Tests finaux | 5 min | Facile |
| **TOTAL** | **30-45 min** | **Débutant OK** |

Avec expérience: **15-20 minutes**

---

**🎯 Objectif:** Système autonome 20h+ avec monitoring précis de batterie!

**✅ Prêt à assembler?** Suivez les étapes dans l'ordre et vérifiez à chaque fois!
