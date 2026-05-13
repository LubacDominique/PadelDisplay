# 🚀 Démarrage Rapide - GitHub Actions iOS

## 📱 Générer votre App iPhone en 3 Étapes

### Étape 1️⃣: Créer un Repo GitHub

```bash
# Votre Git local existe déjà avec tous les fichiers ✅
# Pas besoin de git init!

# 1. Créer un nouveau repo VIDE sur https://github.com/new
#    - Nom: "PadelDisplay"
#    - Type: Public (pour GitHub Actions gratuit)
#    - ⚠️ NE PAS cocher "Initialize with README"

# 2. Configurer le remote et pousser
git remote add origin https://github.com/VOTRE_USERNAME/PadelDisplay.git
git branch -M main
git push -u origin main
```

### Étape 2️⃣: Lancer le Build

1. 🌐 Allez sur votre repo GitHub
2. 📂 Cliquez sur **"Actions"**
3. ▶️ Sélectionnez **"Build iOS App"**
4. 🎮 Cliquez **"Run workflow"** (bouton à droite)
5. 🎯 Choisissez le type:
   - **debug** - Pour développement
   - **release** - Pour tests
   - **ipa** - Pour fichier .ipa
6. ✅ Cliquez **"Run workflow"**

### Étape 3️⃣: Télécharger l'App

1. ⏱️ Attendez 5-10 minutes (suivez la progression)
2. ✅ Une fois terminé (check vert)
3. 📥 Scrollez vers le bas > **"Artifacts"**
4. 💾 Téléchargez le ZIP
5. 📦 Décompressez et utilisez!

## 🎉 C'est Tout!

Votre application iOS est générée automatiquement dans le cloud macOS!

---

## 📚 Guides Détaillés

- 📖 **[Guide Complet GitHub Actions](GITHUB_ACTIONS_IOS.md)** - Tout savoir sur les workflows
- 🔐 **[Guide des Secrets](SECRETS_GUIDE.md)** - Pour builds signés (TestFlight/App Store)
- ✅ **[Checklist iOS](CHECKLIST_IOS.md)** - Suivre votre progression
- 🍎 **[Build iOS Manuel](BUILD_IOS.md)** - Si vous avez un Mac

## 🔄 Builds Automatiques

Les workflows se lancent automatiquement quand vous modifiez:
- `padel_mobile_app/**` - Code de l'application
- `.github/workflows/build-ios.yml` - Configuration du workflow

Pour désactiver: commentez la section `push:` dans le workflow.

## 💰 C'est Gratuit?

✅ **OUI** pour les repos publics!
- 2000 minutes macOS/mois gratuites
- ~20 builds de 10 minutes
- Largement suffisant pour développement

## 🐛 Problème?

Consultez la section **Dépannage** dans [GITHUB_ACTIONS_IOS.md](GITHUB_ACTIONS_IOS.md)

## 🔐 Build Signé (Avancé)

Pour installer sur iPhone ou publier sur App Store:

1. Obtenez un compte Apple Developer ($99/an)
2. Suivez le [Guide des Secrets](SECRETS_GUIDE.md)
3. Utilisez le workflow **"Build iOS App (Signed)"**

---

**Questions?** Ouvrez une issue sur GitHub!
