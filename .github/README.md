# GitHub Actions - Status des Builds

[![Build iOS App](https://github.com/VOTRE_USERNAME/PadelDisplay/actions/workflows/build-ios.yml/badge.svg)](https://github.com/VOTRE_USERNAME/PadelDisplay/actions/workflows/build-ios.yml)
[![Tests](https://github.com/VOTRE_USERNAME/PadelDisplay/actions/workflows/test.yml/badge.svg)](https://github.com/VOTRE_USERNAME/PadelDisplay/actions/workflows/test.yml)

## 🎯 Workflows Disponibles

| Workflow | Description | Status | Déclenchement |
|----------|-------------|--------|---------------|
| **Build iOS App** | Compile l'app iOS (sans signature) | [![Status](https://github.com/VOTRE_USERNAME/PadelDisplay/actions/workflows/build-ios.yml/badge.svg)](https://github.com/VOTRE_USERNAME/PadelDisplay/actions/workflows/build-ios.yml) | Manuel ou push |
| **Build iOS Signed** | Compile et signe pour distribution | [![Status](https://github.com/VOTRE_USERNAME/PadelDisplay/actions/workflows/build-ios-signed.yml/badge.svg)](https://github.com/VOTRE_USERNAME/PadelDisplay/actions/workflows/build-ios-signed.yml) | Manuel uniquement |
| **Tests** | Tests et analyse du code | [![Status](https://github.com/VOTRE_USERNAME/PadelDisplay/actions/workflows/test.yml/badge.svg)](https://github.com/VOTRE_USERNAME/PadelDisplay/actions/workflows/test.yml) | Pull requests |

## 📊 Derniers Builds

Consultez la page [Actions](../../actions) pour voir tous les builds.

## 🚀 Lancer un Build

### Option 1: Interface GitHub
1. Allez dans [Actions](../../actions)
2. Sélectionnez le workflow souhaité
3. Cliquez sur "Run workflow"
4. Choisissez les options
5. Cliquez "Run workflow"

### Option 2: GitHub CLI
```bash
# Installer GitHub CLI
# https://cli.github.com/

# Build debug
gh workflow run build-ios.yml -f build_type=debug

# Build release
gh workflow run build-ios.yml -f build_type=release

# Build IPA
gh workflow run build-ios.yml -f build_type=ipa

# Build signé
gh workflow run build-ios-signed.yml -f distribution_method=ad-hoc
```

### Option 3: Git Push
```bash
# Les builds se lancent automatiquement sur push vers main
git add .
git commit -m "Update app"
git push origin main
```

## 📥 Télécharger les Artifacts

### Via Interface Web
1. Cliquez sur le build terminé
2. Scrollez vers "Artifacts"
3. Cliquez pour télécharger

### Via GitHub CLI
```bash
# Lister les artifacts
gh run list --workflow=build-ios.yml

# Télécharger le dernier artifact
gh run download --name "nom-de-lartifact"
```

## ⏱️ Temps de Build Moyen

| Type | Temps Estimé |
|------|--------------|
| Debug | ~5 minutes |
| Release | ~7 minutes |
| IPA | ~10 minutes |
| Signé | ~12 minutes |

## 💰 Utilisation des Minutes

Consultez: Settings > Billing > Actions minutes

- **Repos publics**: Gratuit
- **Repos privés**: Minutes limitées (macOS = 10x)

## 🔔 Notifications

Activez les notifications pour être alerté:
1. Profile > Settings > Notifications
2. GitHub Actions > ✅ Activer

## 📈 Historique

Voir tous les builds: [Actions History](../../actions)

---

⚠️ **Remplacez** `VOTRE_USERNAME` par votre nom d'utilisateur GitHub dans tous les liens.
