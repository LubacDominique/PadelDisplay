# 🎥 Guide Visuel - GitHub Actions pour iOS

Ce guide explique visuellement comment utiliser GitHub Actions pour compiler votre app iOS.

## 📍 Étape 1: Accéder à GitHub Actions

1. Allez sur votre repository GitHub
2. Cliquez sur l'onglet **"Actions"** en haut

```
┌─────────────────────────────────────────────────────────┐
│  <> Code    Issues    Pull requests    [Actions]        │
└─────────────────────────────────────────────────────────┘
```

## 📍 Étape 2: Sélectionner le Workflow

Vous verrez une liste de workflows sur la gauche:

```
┌──────────────────────┐
│ All workflows        │
├──────────────────────┤
│ • Build iOS App      │  ← Cliquez ici
│ • Build iOS (Signed) │
│ • Tests              │
└──────────────────────┘
```

## 📍 Étape 3: Lancer le Build

1. Cliquez sur le bouton **"Run workflow"** (en haut à droite)

```
┌────────────────────────────────────────────────┐
│  Build iOS App                                  │
│                                                 │
│  ─────────────────────        [Run workflow ▼] │
└────────────────────────────────────────────────┘
```

2. Une fenêtre s'ouvre avec des options:

```
┌────────────────────────────────┐
│ Use workflow from              │
│ Branch: main            ▼      │
│                                │
│ Type de build                  │
│ ○ debug                        │  ← Sélectionnez
│ ○ release                      │
│ ○ ipa                          │
│                                │
│         [Run workflow]         │  ← Cliquez
└────────────────────────────────┘
```

## 📍 Étape 4: Suivre la Progression

Le build apparaît en haut avec un point orange 🟠 (en cours):

```
┌────────────────────────────────────────────────┐
│ 🟠 Build iOS App #42                           │
│    main                                        │
│    Started 5 seconds ago                       │
└────────────────────────────────────────────────┘
```

Cliquez dessus pour voir les détails:

```
┌────────────────────────────────────────────────┐
│ Build iOS App                                  │
│                                                │
│ Jobs                                           │
│ 🟠 Build iOS Application          Running      │
│    ├─ 📥 Checkout repository      ✓           │
│    ├─ 🍎 Setup Xcode              ✓           │
│    ├─ 📱 Setup Flutter             ✓           │
│    ├─ 🔍 Flutter Doctor            ✓           │
│    ├─ 📦 Get Dependencies          ⟳ Running  │
│    ├─ 🔧 Install CocoaPods         ⏸ Queued   │
│    └─ 🏗️ Build iOS                 ⏸ Queued   │
└────────────────────────────────────────────────┘
```

## 📍 Étape 5: Build Terminé

Quand le build est terminé, vous verrez un ✓ vert:

```
┌────────────────────────────────────────────────┐
│ ✓ Build iOS App #42                            │
│   main                                         │
│   Completed in 8m 23s                          │
└────────────────────────────────────────────────┘
```

Ou une ✗ rouge si échec:

```
┌────────────────────────────────────────────────┐
│ ✗ Build iOS App #42                            │
│   main                                         │
│   Failed after 3m 45s                          │
└────────────────────────────────────────────────┘
```

## 📍 Étape 6: Télécharger l'App

Scrollez vers le bas jusqu'à la section **"Artifacts"**:

```
┌────────────────────────────────────────────────┐
│ Artifacts                                      │
│                                                │
│ 📦 ios-app-release-2024-05-13_10-30-45         │
│    Expires in 30 days                          │
│    Size: 45.2 MB                               │
│                                [Download ⬇️]    │
└────────────────────────────────────────────────┘
```

Cliquez sur **Download** pour télécharger un ZIP.

## 📍 Étape 7: Décompresser et Utiliser

1. Téléchargez le ZIP
2. Décompressez-le
3. Vous trouverez:
   - `Runner.app` (si build debug/release)
   - `padel_mobile_app.ipa` (si build ipa)

## 🔔 Notifications par Email

GitHub peut vous envoyer un email quand le build est terminé:

```
┌────────────────────────────────────────────────┐
│ ✉️  GitHub Actions                              │
│                                                │
│ Build iOS App completed successfully           │
│                                                │
│ Workflow: Build iOS App                        │
│ Status: Success ✓                              │
│ Duration: 8 minutes 23 seconds                 │
│                                                │
│ [View workflow run →]                          │
└────────────────────────────────────────────────┘
```

Pour activer:
1. GitHub > Settings > Notifications
2. Cochez "Actions"

## 📊 Dashboard des Builds

La page principale des Actions montre tous vos builds:

```
┌────────────────────────────────────────────────────────┐
│ All workflows                                          │
│                                                        │
│ ✓ Build iOS App #45    main    8m 23s    2 hours ago  │
│ ✓ Tests #44            main    3m 12s    4 hours ago  │
│ ✗ Build iOS App #43    main    5m 44s    1 day ago    │
│ ✓ Build iOS App #42    main    7m 56s    2 days ago   │
└────────────────────────────────────────────────────────┘
```

Légende:
- ✓ = Succès (vert)
- ✗ = Échec (rouge)
- 🟠 = En cours (orange)

## 🎮 Utilisation Avancée

### Via GitHub CLI

Si vous préférez la ligne de commande:

```powershell
# Lancer un build
gh workflow run build-ios.yml -f build_type=release

# Voir les builds récents
gh run list

# Suivre la progression
gh run watch

# Télécharger un artifact
gh run download 12345
```

### Via le Script Automatique

Utilisez le script fourni:

```powershell
# Sur Windows
.\trigger-build.ps1

# Sur Mac/Linux
./trigger-build.sh
```

Le script affiche un menu interactif:

```
╔═══════════════════════════════════════╗
║  🚀 GitHub Actions Build Launcher     ║
║     Padel Display iOS App             ║
╚═══════════════════════════════════════╝

Quel type de build voulez-vous lancer?

1) 🐛 Debug - Pour développement
2) 🚀 Release - Pour tests
3) 📦 IPA - Fichier .ipa non signé
4) 🔐 Signed Development
5) 📱 Signed Ad Hoc
6) 🏪 Signed App Store
7) 📊 Voir les builds récents
8) 📥 Télécharger le dernier build

Votre choix (1-8):
```

## 📈 Badges de Statut

Ajoutez un badge dans votre README pour montrer le statut:

```markdown
[![Build iOS](https://github.com/USERNAME/REPO/actions/workflows/build-ios.yml/badge.svg)](https://github.com/USERNAME/REPO/actions)
```

Résultat:
- ![passing](https://img.shields.io/badge/build-passing-brightgreen) si succès
- ![failing](https://img.shields.io/badge/build-failing-red) si échec

## 🔍 Voir les Logs Détaillés

Pour déboguer un build échoué:

1. Cliquez sur le build rouge ✗
2. Cliquez sur "Build iOS Application"
3. Cliquez sur l'étape qui a échoué
4. Les logs s'affichent:

```
┌────────────────────────────────────────────────┐
│ 🏗️ Build iOS Release                           │
│                                                │
│ Run flutter build ios --release --no-codesign  │
│                                                │
│ Building Runner.app...                         │
│ Compiling Swift sources...                    │
│ ❌ Error: Module 'flutter_blue_plus' not found │
│                                                │
│ Exit code: 1                                   │
└────────────────────────────────────────────────┘
```

## 💡 Astuces

### 🚀 Builds Plus Rapides
- Activez le cache (déjà fait ✓)
- Buildez seulement quand nécessaire
- Utilisez `--no-codesign` pour les builds de test

### 💰 Économiser les Minutes
- Désactivez les builds automatiques sur push
- Lancez manuellement quand prêt
- Rendez le repo public (minutes illimitées)

### 🔔 Rester Informé
- Activez les notifications email
- Utilisez `gh run watch` dans le terminal
- Ajoutez un badge dans le README

---

**Questions?** Consultez [GITHUB_ACTIONS_IOS.md](GITHUB_ACTIONS_IOS.md) pour plus de détails.
