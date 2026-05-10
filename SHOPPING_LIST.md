# Liste de Courses - Mesure Batterie LiFePO4

## Composants pour Mesure de Batterie

### Essentiels (Diviseur de Tension)

| Quantité | Composant | Valeur | Puissance | Prix Unit. | Total | Lieu d'achat |
|----------|-----------|--------|-----------|------------|-------|--------------|
| 1 | Résistance | 100kΩ | 1/4W | 0.10€ | 0.10€ | Amazon/AliExpress |
| 1 | Résistance | 30kΩ | 1/4W | 0.10€ | 0.10€ | Amazon/AliExpress |

**Alternatives pour 30kΩ**:
- 3× 10kΩ en série = 30kΩ (⭐ RECOMMANDÉ - résistances communes)
- 2× 15kΩ en série = 30kΩ
- 1× 27kΩ + 1× 3kΩ en série = 30kΩ
- 1× 22kΩ + 1× 8.2kΩ = 30.2kΩ (acceptable)

### Protection (Recommandé)

| Quantité | Composant | Valeur | Type | Prix Unit. | Total |
|----------|-----------|--------|------|------------|-------|
| 1 | Diode Zener | 3.3V | BZX55C3V3 | 0.20€ | 0.20€ |
| 1 | Résistance | 100Ω | 1/4W | 0.10€ | 0.10€ |

⚠️ **Avec R2=30kΩ, la protection Zener est FORTEMENT recommandée** car la tension max (3.18V) est proche de la limite ESP32.

### Câblage

| Quantité | Composant | Longueur | Prix Unit. | Total |
|----------|-----------|----------|------------|-------|
| 1 | Gaine thermorétractable | 10cm (2mm) | 0.50€ | 0.50€ |
| 3 | Fils Dupont M-M | 20cm | 0.30€ | 0.90€ |
| 1 | Mini breadboard | 170 points | 1.00€ | 1.00€ |

## Régulateurs Buck (pour batterie 12.8V)

### Option A: Régulateur Unique (économique)

| Quantité | Composant | Spécifications | Prix Unit. | Total |
|----------|-----------|----------------|------------|-------|
| 1 | Module Buck DC-DC | LM2596 12V→5V 5A | 2.50€ | 2.50€ |

⚠️ **Limitation**: Peut ne pas suffire si panneau LED à pleine luminosité (3A) + ESP32 (0.5A)

### Option B: Deux Régulateurs (recommandé)

| Quantité | Composant | Spécifications | Usage | Prix Unit. | Total |
|----------|-----------|----------------|-------|------------|-------|
| 1 | Module Buck | MP1584EN Mini 12V→5V 3A | ESP32 | 1.50€ | 1.50€ |
| 1 | Module Buck | LM2596 12V→5V 5A | LED | 2.50€ | 2.50€ |

**Total**: 4.00€

### Modèles Recommandés

**LM2596 DC-DC Step Down** (grand format)
- Entrée: 4.5-40V DC
- Sortie: 1.25-37V (ajustable via potentiomètre)
- Courant max: 3A continu, 5A peak
- Efficacité: 92%
- Taille: 43×21×14mm
- **Prix**: 2-3€

**MP1584EN Mini Buck** (petit format)
- Entrée: 4.5-28V DC
- Sortie: 0.8-20V (ajustable)
- Courant max: 3A
- Efficacité: 96%
- Taille: 22×17×4mm (ultra-compact!)
- **Prix**: 1-2€

**XL4015 (alternative haute puissance)**
- Entrée: 8-36V DC
- Sortie: 1.25-36V
- Courant max: 5A continu
- Efficacité: 94%
- Avec dissipateur thermique
- **Prix**: 3-4€

## Batterie et Accessoires

### Batterie LiFePO4

| Quantité | Composant | Spécifications | Prix Unit. | Total |
|----------|-----------|----------------|------------|-------|
| 1 | Batterie LiFePO4 | 12.8V 20Ah 3S (256Wh) | 45-60€ | 50€ |

**Où acheter**:
- Amazon: "LiFePO4 12V 20Ah battery"
- AliExpress: "Lifepo4 12.8V 20000mAh"
- Banggood
- Sites spécialisés: batteryspace.com

**Caractéristiques à vérifier**:
- ✅ Tension: 12.8V nominal (3S)
- ✅ Capacité: 20Ah minimum
- ✅ BMS intégré (protection décharge)
- ✅ Connecteur: XT60 ou bornier vis
- ✅ Dimensions: ~18×7.5×16.5cm
- ✅ Poids: ~2.5kg

### Chargeur Spécifique

| Quantité | Composant | Spécifications | Prix Unit. | Total |
|----------|-----------|----------------|------------|-------|
| 1 | Chargeur LiFePO4 | 14.4V 5A pour 3S | 15-25€ | 20€ |

⚠️ **IMPORTANT**: Ne PAS utiliser de chargeur LiPo (16.8V) ! Cela endommagerait la batterie.

**Paramètres chargeur**:
- Tension max: 14.4V (4.8V par cellule)
- Courant: 3-5A (charge en 4-6h)
- Connecteur: Compatible avec votre batterie
- Protection: Surcharge, surchauffe

### Protection et Sécurité

| Quantité | Composant | Spécifications | Prix Unit. | Total |
|----------|-----------|----------------|------------|-------|
| 1 | Fusible + porte-fusible | 5A en ligne | 1.50€ | 1.50€ |
| 1 | Interrupteur ON/OFF | 10A 12V | 1.00€ | 1.00€ |
| 1 | Connecteur XT60 | Mâle + femelle | 0.80€ | 0.80€ |
| 2m | Fil électrique | Rouge + Noir 14AWG | 1.50€/m | 3.00€ |

## Récapitulatif des Prix

### Configuration Minimale (mesure seulement, alimentation secteur existante)

| Catégorie | Détail | Prix |
|-----------|--------|------|
| Diviseur tension | 2× résistances | 0.20€ |
| Câblage | Fils + gaine | 1.50€ |
| **Total** | | **1.70€** |

### Configuration Complète Portable (avec batterie)

| Catégorie | Détail | Prix |
|-----------|--------|------|
| Diviseur + protection | Résistances + Zener | 0.50€ |
| Régulateurs Buck | 2× modules | 4.00€ |
| Batterie LiFePO4 | 12.8V 20Ah | 50.00€ |
| Chargeur | 14.4V 5A | 20.00€ |
| Protection | Fusible + switch | 2.50€ |
| Câblage | Fils + connecteurs | 4.00€ |
| **Total** | | **81.00€** |

**Alternative économique (batterie d'occasion)**: ~50€ total

### Configuration Semi-Portable (avec batterie, sans chargeur neuf)

Si vous avez déjà un chargeur LiFePO4 compatible:

| Catégorie | Détail | Prix |
|-----------|--------|------|
| Diviseur + protection | Résistances + Zener | 0.50€ |
| Régulateurs Buck | 2× modules | 4.00€ |
| Batterie LiFePO4 | 12.8V 20Ah | 50.00€ |
| Protection + câblage | Fusible + fils | 6.50€ |
| **Total** | | **61.00€** |

## Liens d'Achat Recommandés

### Amazon France
```
🔍 Recherche: "résistance 100k"
🔍 Recherche: "résistance 30k" ou "résistance 10k" (×3 pour faire 30k)
🔍 Recherche: "kit résistances 600pcs" (contient toutes les valeurs)
🔍 Recherche: "diode zener 3.3v" (IMPORTANT avec R2=30k!)
🔍 Recherche: "LM2596 dc dc buck"
🔍 Recherche: "MP1584EN mini buck"
🔍 Recherche: "batterie lifepo4 12v 20ah"
🔍 Recherche: "chargeur lifepo4 12v"
```

### AliExpress
```
🔍 "1/4W resistor kit" (kit 600pcs: 3-5€)
🔍 "LM2596 adjustable step down"
🔍 "MP1584EN DC-DC buck converter"
🔍 "12V 20Ah lifepo4 battery with BMS"
🔍 "14.4V lifepo4 charger"
```

### Gotronic / Conrad (France)
- Composants électroniques individuels
- Livraison rapide
- Prix légèrement plus élevés

## Outils Nécessaires

| Outil | Usage | Nécessaire? | Prix si achat |
|-------|-------|-------------|---------------|
| Fer à souder | Assembler diviseur | ✅ Oui | 15-30€ |
| Multimètre | Vérifier tensions | ✅ Oui | 10-20€ |
| Tournevis cruciforme | Régler Buck modules | ✅ Oui | 5€ |
| Pince coupante | Couper fils | Optionnel | 8€ |
| Pince à dénuder | Préparer câbles | Optionnel | 10€ |
| Pistolet à colle chaude | Fixer composants | Optionnel | 12€ |

## Timeline d'Achat

### Semaine 1
- ✅ Commander batterie LiFePO4 (délai: 3-7j Amazon, 15-30j AliExpress)
- ✅ Commander régulateurs Buck (délai: 2-5j Amazon, 10-20j AliExpress)

### Semaine 2
- ✅ Acheter résistances en magasin local ou Amazon Prime (24h)
- ✅ Commander chargeur LiFePO4

### Semaine 3
- ✅ Tous les composants reçus
- ✅ Assembler le diviseur de tension
- ✅ Tester avec multimètre
- ✅ Installer dans le système

## Notes d'Achat

### ⚠️ Points d'Attention

1. **Batterie LiFePO4 vs LiPo**
   - ✅ LiFePO4: Plus sûre, longue durée (préférer)
   - ⚠️ LiPo: Dangereuse si mal utilisée (éviter)

2. **Tension batterie**
   - ✅ 12.8V nominal = 3S LiFePO4 (correct)
   - ❌ 11.1V = 3S LiPo (NE PAS utiliser avec ce code!)
   - ❌ 12V plomb = Trop lourd, courte durée

3. **Régulateurs Buck**
   - ✅ Vérifier tension d'entrée max (>15V pour sécurité)
   - ✅ Courant suffisant (LED: 3-4A, ESP32: 0.5A)
   - ✅ Avec dissipateur thermique

4. **Chargeur**
   - ⚠️ IMPÉRATIF: Chargeur LiFePO4 14.4V (pas LiPo 16.8V!)
   - ✅ Avec coupure automatique en fin de charge
   - ✅ Indicateurs LED charge/fin

### 💡 Conseils Économiques

1. **Acheter un kit de résistances** (3-5€)
   - 600 pièces de toutes valeurs
   - Utile pour futurs projets
   
2. **Batterie d'occasion**
   - Vérifier cycles restants
   - Tester voltage (doit être 12.8V ±0.5V)
   - Prix: -40% vs neuf

3. **Grouper les achats**
   - Amazon: Profiter de la livraison gratuite
   - AliExpress: Regrouper plusieurs articles d'un vendeur

4. **Alternative temporaire**
   - Utiliser alimentation secteur 5V
   - Ajouter batterie plus tard

## Checklist Avant Achat

Avant de commander, vérifier:

- [ ] Tension batterie: 12.8V (3S LiFePO4)
- [ ] Capacité batterie: ≥20Ah pour autonomie suffisante
- [ ] BMS intégré dans la batterie
- [ ] Chargeur compatible LiFePO4 14.4V (pas LiPo!)
- [ ] Régulateurs Buck: tension d'entrée ≥15V
- [ ] Résistances: précision ±5% minimum
- [ ] Fusible: 5A adapté à la batterie
- [ ] Outils disponibles: fer à souder + multimètre

---

**Mise à jour**: Avril 2026
**Budget total estimé**: 60-85€ (configuration complète portable)
**Temps d'installation**: 2-3 heures (avec assemblage et tests)
