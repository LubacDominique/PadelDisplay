# Guide de Démarrage Rapide - 5 Minutes

## ⚡ Installation Express

### 1️⃣ Prérequis (2 min)

```powershell
# Vérifier que VS Code et PlatformIO sont installés
code --version
```

Si pas installés:
1. Télécharger [VS Code](https://code.visualstudio.com/)
2. Installer l'extension [PlatformIO](https://platformio.org/install/ide?install=vscode)

### 2️⃣ Ouvrir le Projet (30 sec)

```powershell
# Ouvrir VS Code dans le dossier du projet
cd f:\VsCode\PadelDisplay
code .
```

### 3️⃣ Installation des Librairies (1 min)

PlatformIO télécharge automatiquement les librairies au premier build.

Cliquer sur l'icône PlatformIO (tête d'alien) dans la barre latérale gauche.

### 4️⃣ Connexion ESP32 (30 sec)

1. Brancher l'ESP32 via USB
2. Windows installe automatiquement les drivers CH340
3. Vérifier le port COM dans Device Manager

### 5️⃣ Upload du Code (1 min)

**Méthode 1: Via Interface**
- Cliquer sur l'icône ![Upload](→) en bas de VS Code
- Ou: PlatformIO > Upload

**Méthode 2: Via Raccourci**
- `Ctrl + Alt + U`

## 🔌 Connexion Matérielle - Minimum Viable

### Alimentation Rapide

```
┌──────────────┐
│ Alim 5V/3A+  │
└──┬────────┬──┘
   │        │
   ▼        ▼
[ESP32] [LED Panel]
```

**⚠️ Critique:** Connecter **GND commun** entre ESP32 et Panneau!

### Test Sans Panneau LED

Vous pouvez tester le code sans panneau connecté en mode simulation:

1. Dans `main.cpp`, commenter la ligne:
   ```cpp
   // dma_display->begin();
   ```

2. Utiliser le moniteur série pour tester la logique:
   ```
   Commandes: 1, 2, r, s
   ```

## 🎮 Test des eTags BLE

### Sans eTags Physiques

Contrôle via Moniteur Série (115200 bauds):

| Touche | Action |
|--------|--------|
| `1` | Point J1 |
| `2` | Point J2 |
| `!` | -1 point J1 |
| `@` | -1 point J2 |
| `r` | Reset |
| `s` | Statut |

### Avec eTags

1. Activer les tags (bouton)
2. Observer le moniteur série:
   ```
   BLE Découvert: iTAG, Address: aa:bb:cc:dd:ee:ff
   ```
3. Les tags se connectent automatiquement
4. Tester les clics

## 🔧 Dépannage Express

### ❌ "Upload Failed"

**Solution 1:** Maintenir le bouton BOOT pendant l'upload

**Solution 2:** Vérifier le port COM
```powershell
# Dans PlatformIO Terminal
pio device list
```

**Solution 3:** Installer manuellement le driver CH340
- [Télécharger CH340 Driver](https://sparks.gogo.co.nz/ch340.html)

### ❌ "Library Not Found"

```bash
# Dans PlatformIO Terminal
pio lib install
```

### ❌ Panneau LED Noir

1. ✅ Vérifier alimentation 5V
2. ✅ Vérifier GND commun
3. ✅ Vérifier connexions HUB75 (surtout R1, G1, B1)

### ❌ Compilation Errors

```bash
# Nettoyer et rebuilder
pio run --target clean
pio run
```

## 📊 Vérification Fonctionnelle

### Checklist en 3 Minutes

- [ ] ESP32 s'allume (LED power)
- [ ] Upload réussi (100% complete)
- [ ] Moniteur série affiche "Système prêt"
- [ ] Panneau LED affiche "PADEL" au démarrage
- [ ] Score "0 - 0" visible
- [ ] Commande série '1' incrémente le score
- [ ] eTags détectés (si connectés)

## 🎯 Premier Match de Test

### Scénario Automatique

Teste tous les cas de figure:

```cpp
// Ajouter dans loop() pour démo automatique:
void demoMode() {
    delay(2000);
    addPoint(player1, player2, 1);  // J1: 15-0
    delay(1000);
    addPoint(player1, player2, 1);  // J1: 30-0
    delay(1000);
    addPoint(player2, player1, 2);  // 30-15
    delay(1000);
    addPoint(player2, player1, 2);  // 30-30
    // ... etc
}
```

### Manuel (Moniteur Série)

```
1  → 15-0
1  → 30-0
2  → 30-15
2  → 30-30
1  → 40-30
1  → Jeu J1 (affichage "JEU")
s  → Afficher statut
```

## 📱 Connexion Smartphone (Optionnel)

### Test des eTags via App

**Android: nRF Connect**
1. Installer depuis Play Store
2. Scanner → Voir les iTags
3. Connect → Tester le bouton
4. Observer les notifications

**iOS: LightBlue**
1. Installer depuis App Store
2. Scan for Peripherals
3. Connect to iTAG
4. Monitor notifications

## 🚀 Prêt pour le Premier Match!

Une fois tous les tests validés:

1. ✅ Fixer le panneau au mur/support
2. ✅ Distribuer un eTag par joueur
3. ✅ Expliquer: 1 clic = +1 point, 2 clics = annuler
4. ✅ Lancer le match!

## 📞 Support Rapide

| Problème | Page |
|----------|------|
| Câblage | [WIRING.md](WIRING.md) |
| Utilisation | [USAGE.md](USAGE.md) |
| Configuration | [CONFIG.md](CONFIG.md) |
| Matériel | [HARDWARE.md](HARDWARE.md) |

---

**Temps total: < 5 minutes** ⏱️

**Prêt à jouer!** 🎾
