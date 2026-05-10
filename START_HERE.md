# 🎯 Pour Commencer - Guide Visuel

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│              🎾 AFFICHEUR DE SCORE DE PADEL 🎾                   │
│                   Bienvenue dans le projet!                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## 📍 Vous êtes ici

Vous venez de recevoir un projet complet avec **15 fichiers** documentant 
et implémentant un afficheur de score professionnel pour le padel.

## 🛣️ Votre Parcours en 3 Étapes

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   ÉTAPE 1   │  →   │   ÉTAPE 2   │  →   │   ÉTAPE 3   │
│             │      │             │      │             │
│  Comprendre │      │  Construire │      │   Utiliser  │
│  le projet  │      │   le setup  │      │  et jouer!  │
└─────────────┘      └─────────────┘      └─────────────┘
     15 min               2-3h                5 min
```

## 📚 ÉTAPE 1: Comprendre (15 minutes)

### À Lire MAINTENANT:

```
1️⃣  README.md          ← Commencez ICI
    │ 
    ├─ Qu'est-ce que c'est?
    ├─ Comment ça fonctionne?
    └─ De quoi ai-je besoin?

2️⃣  INDEX.md           ← Guide de navigation
    │
    └─ Où trouver chaque info?

3️⃣  QUICKSTART.md      ← Installation en 5 min
    │
    └─ Les étapes essentielles
```

### ✅ Après cette lecture, vous saurez:
- [ ] Le concept et l'objectif du projet
- [ ] Les composants nécessaires
- [ ] Le coût total (~50-80€)
- [ ] Le temps requis (~2-3h)
- [ ] Si c'est adapté à votre niveau

## 🛠️ ÉTAPE 2: Construire (2-3 heures)

### Phase A: Achats (selon stock)

```
🛒 HARDWARE.md
   │
   ├─ Liste complète des composants
   ├─ Où acheter (liens)
   ├─ Critères de compatibilité
   └─ Budget détaillé

💡 Conseil: Commander sur AliExpress = économie
            Mais délai 2-4 semaines
```

### Phase B: Câblage (1-2h)

```
🔌 WIRING.md
   │
   ├─ Schémas de connexion détaillés
   ├─ Tableau de brochage complet
   ├─ Photos/diagrammes
   └─ Checklist de vérification

⚠️  IMPORTANT: Bien suivre les couleurs!
    Vérifier 2× avant d'alimenter
```

### Phase C: Installation Logiciel (30 min)

```
💻 QUICKSTART.md
   │
   ├─ Installer VS Code + PlatformIO
   ├─ Ouvrir le projet
   ├─ Upload sur ESP32
   └─ Premier test

🔧 CONFIG.md
   │
   └─ Configuration des eTags BLE
```

## 🎮 ÉTAPE 3: Utiliser (5 minutes)

### Premier Match!

```
📖 USAGE.md
   │
   ├─ Démarrage du système
   ├─ Connexion des eTags
   ├─ Contrôle des scores
   │  ├─ 1 clic = +1 point
   │  └─ 2 clics = -1 point
   ├─ Règles du padel
   └─ Maintenance

🎾 C'est parti pour jouer!
```

## 🆘 En Cas de Problème

```
                    Un problème?
                         │
                         ▼
            ┌────────────┴────────────┐
            │                         │
         Matériel                 Logiciel
            │                         │
            ▼                         ▼
   TROUBLESHOOTING.md           FAQ.md
            │                         │
            ├─ Panneau noir           ├─ Upload failed
            ├─ Couleurs KO            ├─ Library error
            ├─ Scintillement          └─ Compilation error
            └─ BLE non détecté
```

## 📋 Checklist Avant de Commencer

Vérifiez que vous avez bien:

### Matériel (à acheter)
- [ ] Panneau LED P5 32x64 pixels HUB75
- [ ] ESP32 DevKit (30 broches, CH340C)
- [ ] 2× eTags BLE (iTAG ou compatible)
- [ ] Alimentation 5V 4A minimum
- [ ] Câbles Dupont femelle-femelle (~15)
- [ ] Câble USB pour ESP32

### Logiciel (gratuit)
- [ ] Visual Studio Code installé
- [ ] Extension PlatformIO installée
- [ ] Ce projet ouvert dans VS Code

### Compétences
- [ ] Lecture de schémas basique
- [ ] Câblage de composants
- [ ] Utilisation d'un éditeur de code
- [ ] Patience et précision! 🙂

## 🎯 Navigation Rapide

Selon votre besoin:

| Je veux... | Aller à... |
|------------|------------|
| 👀 Voir le résultat final | [Photos dans README.md](README.md) |
| 💰 Connaître le coût | [HARDWARE.md - Budget](HARDWARE.md#liste-des-composants) |
| ⏱️ Savoir le temps requis | [FAQ.md - Timing](FAQ.md#️-combien-de-temps-pour-le-construire) |
| 🛒 Acheter les composants | [HARDWARE.md - Fournisseurs](HARDWARE.md#fournisseurs-recommandés) |
| 🔌 Câbler le système | [WIRING.md - Schémas](WIRING.md#brochage-détaillé-esp32--hub75) |
| 💻 Installer le code | [QUICKSTART.md](QUICKSTART.md) |
| 🎮 Utiliser l'afficheur | [USAGE.md](USAGE.md) |
| 🛠️ Résoudre un problème | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |
| ❓ Poser une question | [FAQ.md](FAQ.md) |
| 🏗️ Comprendre l'architecture | [ARCHITECTURE.md](ARCHITECTURE.md) |

## 💡 Conseils de Pro

### ✅ À FAIRE

1. **Lire la doc avant d'acheter**
   - Vérifier la compatibilité des composants
   - Comparer les prix

2. **Tester étape par étape**
   - Panneau seul d'abord
   - Puis avec ESP32
   - Enfin les eTags

3. **Prendre des photos du câblage**
   - Facilite le dépannage
   - Utile pour refaire

4. **Sauvegarder vos modifications**
   - Ne pas modifier main.cpp directement
   - Utiliser config.h

### ❌ À ÉVITER

1. **Brancher sans vérifier**
   - Toujours vérifier la polarité
   - Double-check le brochage

2. **Ignorer les warnings**
   - Les logs du moniteur série sont utiles
   - Debugger dès qu'un problème apparaît

3. **Acheter n'importe quel panneau**
   - Vérifier: P5, 32x64, HUB75, indoor, 1/16 scan
   - Sinon le code ne marchera pas!

## 🚀 Prêt? Action!

```
┌─────────────────────────────────────────┐
│  Étape suivante recommandée:            │
│                                         │
│  1. Ouvrir README.md                    │
│  2. Lire les 5 premières minutes        │
│  3. Décider si le projet vous convient  │
│                                         │
│  Puis si OK:                            │
│  4. Acheter les composants              │
│  5. Suivre QUICKSTART.md               │
│  6. Jouer au padel! 🎾                  │
└─────────────────────────────────────────┘
```

## 📞 Besoin d'Aide?

1. **[INDEX.md](INDEX.md)** - Navigation complète
2. **[FAQ.md](FAQ.md)** - Questions fréquentes
3. **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Dépannage
4. Moniteur série - Logs en temps réel (115200 bauds)

## 🎓 Niveau de Difficulté

```
Débutant    ████░░░░░░  40%  ← Vous pouvez le faire!
Technique   ██████░░░░  60%
Code        ██░░░░░░░░  20%  ← Code fourni
Temps       ████░░░░░░  40%  ← 2-3 heures
Coût        ███░░░░░░░  30%  ← 50-80€
```

**Verdict:** Projet **accessible** pour débutant motivé!

## ⭐ Ce que vous allez apprendre

- ✅ Utiliser ESP32 et BLE
- ✅ Piloter un panneau LED HUB75
- ✅ PlatformIO et VS Code
- ✅ Câblage de composants
- ✅ Debug et dépannage
- ✅ Électronique pratique

**Bonus:** Projet impressionnant pour votre portfolio! 🎉

---

# 🎯 MAINTENANT: Ouvrez [README.md](README.md)

**Bon courage et amusez-vous bien!** 🎾

---

**Version:** 1.0  
**Date:** Avril 2026  
**Temps de lecture:** 5 minutes
