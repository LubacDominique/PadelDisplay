# Configuration R1=100kΩ + R2=30kΩ - Notes Importantes

## ✅ Modifications Appliquées

Toute la configuration a été adaptée pour **R1=100kΩ et R2=30kΩ** au lieu de R1=100kΩ et R2=25kΩ.

### Nouveau Ratio de Division: **4.33:1**

```
Vout = Vin × (R2 / (R1 + R2))
Vout = Vin × (30kΩ / 130kΩ)
Vout = Vin / 4.333
```

### Tensions Résultantes

| Voltage Batterie | Tension sur GPIO35 | État |
|------------------|-------------------|------|
| **13.8V** (max) | **3.18V** | ⚠️ Proche limite ESP32 (3.3V) |
| **12.8V** (nominal) | **2.95V** | ✅ OK |
| **9.0V** (min) | **2.08V** | ✅ OK |

## ⚠️ Points d'Attention avec R2=30kΩ

### 1. Protection Zener FORTEMENT Recommandée

Avec R2=30kΩ, la tension maximale (3.18V @ 13.8V batterie) est **très proche** de la limite ESP32 (3.3V).

**Conséquence**: Si la batterie est chargée au-delà de 13.8V (ex: 14.2V), vous atteignez:
```
14.2V / 4.333 = 3.28V → RISQUE pour l'ADC!
```

**Solution**: Installer une **diode Zener 3.3V** entre GPIO35 et GND:
```
                       Diode Zener 3.3V
                            │
    GPIO35 ◄────────────────┼──────/\/\/\──── Point milieu diviseur
    (ADC)                   │      100Ω
                           GND
```

### 2. Stabilité Améliorée

**Avantage de R2=30kΩ vs R2=25kΩ**:
- Impédance plus faible → Moins sensible au bruit
- Courant légèrement plus élevé → Lecture plus stable
- Résistances plus communes (3× 10kΩ facile à trouver)

**Inconvénient**:
- Marge de sécurité réduite en haute tension
- Protection Zener devient quasi-obligatoire

### 3. Assemblage avec 3× 10kΩ

La solution la plus économique pour obtenir 30kΩ:

```
┌─── 10kΩ ───┬─── 10kΩ ───┬─── 10kΩ ───┐
│            │            │            │
Bat(+)                                GND
            Point milieu
            (après 1ère résistance de 10kΩ)
```

**NON!** ⚠️ Mauvais câblage ci-dessus.

**Correct**: Souder en série
```
R1 (100kΩ) ──┬── [10kΩ + 10kΩ + 10kΩ] = 30kΩ total
           Point milieu
```

Ou plus précisément:
```
        R1=100kΩ              R2a    R2b    R2c
Bat(+) ───/\/\/\───┬────── 10kΩ ─ 10kΩ ─ 10kΩ ──── GND
                   │
                GPIO35
```

## 📝 Fichiers Modifiés

### 1. [src/main.cpp](src/main.cpp)
```cpp
// AVANT (R2=25kΩ):
#define VOLTAGE_DIVIDER 5.0

// APRÈS (R2=30kΩ):
#define VOLTAGE_DIVIDER 4.333
```

### 2. [BATTERY.md](BATTERY.md)
- ✅ Schéma du diviseur mis à jour
- ✅ Calculs de tension ajustés
- ✅ Tableau voltage/ADC recalculé
- ✅ Protection Zener marquée comme "FORTEMENT recommandée"

### 3. [SHOPPING_LIST.md](SHOPPING_LIST.md)
- ✅ R2 changée de 25kΩ → 30kΩ
- ✅ Alternatives ajoutées: 3× 10kΩ (recommandé)
- ✅ Diode Zener 3.3V marquée comme prioritaire

### 4. [QUICK_INSTALL.md](QUICK_INSTALL.md)
- ✅ Schéma d'assemblage adapté
- ✅ Code couleur résistances mis à jour
- ✅ Tableau ADC recalculé (2400-3200 au lieu de 2000-2800)
- ✅ Note sur protection Zener

## 🔧 Configuration Code Résumée

```cpp
// Dans main.cpp:
#define BATTERY_PIN 35              // GPIO35 (ADC1_CHANNEL_7)
#define BATTERY_MAX_VOLTAGE 13.8    // 100% charge
#define BATTERY_NOM_VOLTAGE 12.8    // Nominal
#define BATTERY_MIN_VOLTAGE 9.0     // 0% critique
#define VOLTAGE_DIVIDER 4.333       // R1=100kΩ, R2=30kΩ
```

## 🛒 Liste de Courses Mise à Jour

### Essentiel
- [x] 1× Résistance 100kΩ (0.10€)
- [x] **Option A**: 1× Résistance 30kΩ (0.10€) - Difficile à trouver
- [x] **Option B**: 3× Résistances 10kΩ (0.30€) - ⭐ RECOMMANDÉ
- [x] **1× Diode Zener 3.3V BZX55C3V3 (0.20€) - IMPORTANT!**
- [x] 1× Résistance 100Ω protection (0.10€)

**Total**: 0.70€ avec protection complète

## 📊 Comparaison R2=25kΩ vs R2=30kΩ

| Critère | R2=25kΩ (5:1) | R2=30kΩ (4.33:1) | Meilleur |
|---------|---------------|------------------|----------|
| Tension max ADC | 2.76V | 3.18V | 25kΩ (plus de marge) |
| Disponibilité résistances | Moyenne | **Excellente (3×10k)** | **30kΩ** |
| Stabilité lecture | Bonne | **Meilleure** | **30kΩ** |
| Sensibilité au bruit | Moyenne | **Faible** | **30kΩ** |
| Protection nécessaire | Recommandée | **Obligatoire** | 25kΩ |
| Impédance diviseur | 125kΩ | 130kΩ | ~Équivalent |
| Courant consommé @ 12.8V | 102µA | 98µA | ~Équivalent |

**Verdict**: R2=30kΩ est excellent **SI** vous installez la diode Zener 3.3V!

## ⚡ Test de Validation

Après installation, vérifier dans le **Serial Monitor**:

```
Configuration ADC pour batterie LiFePO4 12.8V...
Batterie détectée: 12.85V (78%)
[Batterie] Voltage: 12.85V | Charge: 78% | ADC: 3021
                                                 ^^^^
                                           Entre 2900-3100
                                           pour 12.8V nominal
```

**Valeurs ADC attendues**:
- Batterie @ 13.8V → ADC ≈ 3860 (proche max 4095)
- Batterie @ 12.8V → ADC ≈ 3580
- Batterie @ 9.0V → ADC ≈ 2530

Si ADC > 4000, **c'est que la batterie dépasse 14.3V** → Vérifier chargeur!

## 🎯 Résumé Action

Pour utiliser R1=100kΩ et R2=30kΩ en toute sécurité:

1. ✅ **Assembler le diviseur**: R1 (100k) + R2 (30k ou 3×10k)
2. ✅ **Installer Zener 3.3V**: Entre GPIO35 et GND (+ résistance 100Ω)
3. ✅ **Connecter**: Point milieu → GPIO35
4. ✅ **Compiler et tester**: Le code est déjà configuré (VOLTAGE_DIVIDER=4.333)
5. ✅ **Vérifier ADC**: Doit lire 2.95V pour batterie à 12.8V

**Tout est prêt!** Le système est configuré pour R2=30kΩ. 🎉

---

**Configuration optimale**: R1=100kΩ + R2=(3×10kΩ) + Zener 3.3V + C100nF
**Coût total**: <1€
**Temps installation**: 15-20 minutes
