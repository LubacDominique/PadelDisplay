# Guide d'Utilisation - Afficheur de Score Padel

## Démarrage Rapide

### Première Utilisation

1. **Mise sous tension**
   ```
   ┌─────────────────────────────────┐
   │ 1. Brancher alimentation 5V     │
   │ 2. Connecter ESP32 (USB ou 5V)  │
   │ 3. Attendre 5 secondes          │
   └─────────────────────────────────┘
   ```

2. **Écran de démarrage**
   - Le panneau affiche brièvement : `PADEL`
   - Puis: `BLE...` (recherche des tags)
   - Enfin: `0 - 0` (partie prête)

3. **Connexion des eTags**
   - Appuyer sur le bouton de chaque eTag
   - LED du tag clignote (mode appairage)
   - ESP32 détecte et connecte automatiquement
   - Confirmation sur l'afficheur

## Contrôle des Scores

### Joueur 1 (Gauche)

**eTag Joueur 1** contrôle le score de gauche

| Action | Résultat |
|--------|----------|
| **1 clic simple** | +1 point au joueur 1 |
| **2 clics rapides** | -1 point au joueur 1 |

### Joueur 2 (Droite)

**eTag Joueur 2** contrôle le score de droite

| Action | Résultat |
|--------|----------|
| **1 clic simple** | +1 point au joueur 2 |
| **2 clics rapides** | -1 point au joueur 2 |

### Timing des Clics

- **Simple clic**: Appui bref (< 500ms)
- **Double clic**: 2 appuis rapides espacés de < 400ms
- **Délai entre actions**: Minimum 100ms

## Affichage des Scores

### Format 1: Jeu en cours

```
┌─────────────────────────┐
│                         │
│    15  -  30            │
│                         │
│   [1]    [2]            │
└─────────────────────────┘
```

- Ligne du haut: Points actuels (0, 15, 30, 40, ADV)
- Ligne du bas: Nombre de jeux gagnés

### Format 2: Égalité (Deuce)

```
┌─────────────────────────┐
│                         │
│    40  -  40            │
│                         │
│   [3]    [3]            │
└─────────────────────────┘
```

### Format 3: Avantage

```
┌─────────────────────────┐
│                         │
│   ADV  -  40            │
│                         │
│   [5]    [4]            │
└─────────────────────────┘
```

### Format 4: Fin de jeu

```
┌─────────────────────────┐
│                         │
│    JEU      ✓           │
│                         │
│   [4]    [2]            │
└─────────────────────────┘
```

Affichage pendant 2 secondes, puis nouveau jeu.

### Format 5: Fin de set

```
┌─────────────────────────┐
│                         │
│    SET      ✓           │
│                         │
│   [6]    [4]            │
└─────────────────────────┘
```

Affichage pendant 3 secondes, puis nouveau set.

## Règles du Padel

### Système de Points

| Points | Affichage |
|--------|-----------|
| 0 point | `0` |
| 1 point | `15` |
| 2 points | `30` |
| 3 points | `40` |

### Égalité à 40-40 (Deuce)

- Affichage: `40 - 40`
- Un joueur doit gagner 2 points consécutifs
- Premier point après deuce: `ADV - 40` ou `40 - ADV`
- Deuxième point: Jeu gagné
- Si égalisation: Retour à deuce

### Jeux

- Premier à 4 points gagne le jeu
- Avec 2 points d'écart minimum
- Compteur de jeux: affichage en bas `[X]`

### Sets

- Premier à 6 jeux gagne le set
- Avec 2 jeux d'écart minimum
- Si 6-6: Tie-break (à implémenter selon règles locales)

### Match

- Best of 3 sets (2 sets gagnants)
- Possibilité de configuration best of 5

## Situations de Jeu

### Scénario 1: Début de partie

```
Action: Aucune
Affichage: 0 - 0
Jeux: [0] [0]
```

### Scénario 2: Premier point

```
Action: Joueur 1 clique 1×
Affichage: 15 - 0
Jeux: [0] [0]
```

### Scénario 3: Égalisation

```
Avant: 30 - 15
Action: Joueur 2 clique 1×
Affichage: 30 - 30
```

### Scénario 4: Deuce

```
Avant: 40 - 30
Action: Joueur 2 clique 1×
Affichage: 40 - 40 (DEUCE)
```

### Scénario 5: Avantage

```
Avant: 40 - 40
Action: Joueur 1 clique 1×
Affichage: ADV - 40
```

### Scénario 6: Jeu gagné

```
Avant: ADV - 40
Action: Joueur 1 clique 1×
Affichage: JEU ✓ (2 sec)
Puis: 0 - 0, [1] [0]
```

### Scénario 7: Correction d'erreur

```
Avant: 30 - 15
Action: Joueur 1 double-clique
Affichage: 15 - 15
```

## Fonctions Avancées

### Réinitialisation Manuelle

**Méthode 1**: Via bouton physique (si ajouté)
- Appuyer 3 secondes sur bouton RESET

**Méthode 2**: Via code (re-upload)
- Redémarrer l'ESP32

**Méthode 3**: Via double-clic simultané
- Joueur 1 et 2 cliquent 3× en même temps
- Affichage: `RESET`, puis `0 - 0`

### Mode Démo

Pour tester l'affichage sans eTags:

1. Ouvrir le moniteur série
2. Envoyer des commandes:
   - `+1` : Point joueur 1
   - `+2` : Point joueur 2
   - `-1` : Retire point joueur 1
   - `-2` : Retire point joueur 2
   - `R` : Reset

### Changement de Luminosité

La luminosité peut être ajustée dans le code:

```cpp
// Dans main.cpp, ligne ~50
dma_display->setBrightness8(128); // 0-255
```

- `0` : Éteint
- `64` : 25% (économie d'énergie)
- `128` : 50% (recommandé intérieur)
- `192` : 75%
- `255` : 100% (maximum)

## Dépannage Utilisateur

### ❌ Score ne change pas

**Symptôme**: Clic sur eTag sans effet

**Solutions**:
1. Vérifier connexion BLE (voyant sur tag)
2. Rapprocher le tag de l'ESP32
3. Remplacer la pile du tag (CR2032)
4. Redémarrer le système

### ❌ Double-clic non détecté

**Symptôme**: 2 clics = 2 incrémentations au lieu de 1 décrémentation

**Solutions**:
1. Cliquer plus rapidement (< 400ms entre clics)
2. Ajuster `DOUBLE_CLICK_DELAY` dans le code
3. Vérifier la batterie du tag

### ❌ Affichage gelé

**Symptôme**: Le score ne se met plus à jour

**Solutions**:
1. Vérifier alimentation 5V
2. Redémarrer l'ESP32
3. Vérifier moniteur série pour erreurs

### ❌ Tags inversés

**Symptôme**: Le tag de gauche contrôle le score de droite

**Solutions**:
1. Échanger physiquement les tags
2. OU modifier les adresses MAC dans le code

### ❌ Connexion BLE perdue

**Symptôme**: Affichage `BLE ERR`

**Solutions**:
1. Activer/désactiver les tags
2. Rapprocher les tags
3. Éliminer sources d'interférence (WiFi 2.4GHz)
4. Redémarrer ESP32

## Maintenance

### Quotidien
- ✅ Vérifier connexion BLE avant chaque partie
- ✅ Nettoyer le panneau LED (chiffon doux, sec)

### Hebdomadaire
- ✅ Vérifier les piles des eTags
- ✅ Vérifier toutes les connexions
- ✅ Nettoyer la poussière

### Mensuel
- ✅ Vérifier le firmware ESP32 (mises à jour)
- ✅ Tester tous les scénarios de jeu
- ✅ Vérifier alimentation (voltage, ampérage)

### Remplacement des Piles

**eTags BLE**: Pile CR2032

**Signes de pile faible**:
- Portée BLE réduite
- Déconnexions fréquentes
- LED tag faible/absente

**Procédure**:
1. Ouvrir le compartiment pile
2. Respecter la polarité (+ vers le haut)
3. Refermer et tester

## Personnalisation

### Couleurs d'Affichage

Modifier dans `main.cpp`:

```cpp
// Couleur des scores
uint16_t COLOR_PLAYER1 = dma_display->color565(255, 0, 0);    // Rouge
uint16_t COLOR_PLAYER2 = dma_display->color565(0, 255, 0);    // Vert
uint16_t COLOR_GAMES = dma_display->color565(255, 255, 0);    // Jaune
```

### Timing

```cpp
const int GAME_WON_DISPLAY_TIME = 2000;  // 2 secondes
const int SET_WON_DISPLAY_TIME = 3000;   // 3 secondes
const int DOUBLE_CLICK_DELAY = 400;      // 400ms
```

### Format d'Affichage

Changer la taille de la police ou la position des scores en modifiant les coordonnées X/Y dans les fonctions `displayScore()`.

## FAQ

**Q: Puis-je utiliser d'autres tags BLE?**
R: Oui, tout tag BLE compatible avec détection de bouton.

**Q: Quelle est la portée maximum?**
R: 10-30 mètres en intérieur, selon obstacles et interférences.

**Q: Le panneau peut-il être plus grand?**
R: Oui, il faut chaîner plusieurs panneaux et adapter le code.

**Q: Puis-je afficher d'autres infos?**
R: Oui, le code est personnalisable (chronomètre, noms, etc.).

**Q: Consommation électrique?**
R: Environ 15-20W en fonctionnement normal.

**Q: Compatible avec batterie portable?**
R: Oui, avec une batterie 5V 4A+ type powerbank.

## Support

Pour toute question ou problème:
1. Consulter ce guide
2. Vérifier HARDWARE.md
3. Consulter les issues GitHub
4. Forum ESP32: https://esp32.com

---

**Bon match de padel! 🎾**
