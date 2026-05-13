# 🚀 Guide GitHub Actions - Build iOS

## 📋 Vue d'Ensemble

GitHub Actions permet de compiler votre application iOS **automatiquement dans le cloud** avec des runners macOS **gratuits**. Plus besoin de Mac pour générer votre app iPhone!

## ✅ Avantages

- ✨ **Gratuit** pour les repos publics
- 🍎 **macOS avec Xcode** inclus
- ⚡ **Build automatique** à chaque commit
- 📦 **Artifacts téléchargeables** (.ipa)
- 🔄 **CI/CD** intégré
- 💻 **Fonctionne depuis Windows**

## 🎯 Workflows Disponibles

J'ai créé 2 workflows pour vous:

### 1. **build-ios.yml** - Build Simple (Sans Signature)
- ✅ Idéal pour tester et développer
- ✅ Pas besoin de compte Developer
- ✅ Gratuit et simple
- ⚠️ Ne peut pas être installé sur iPhone
- 📦 Génère: Runner.app ou .ipa non signé

### 2. **build-ios-signed.yml** - Build Signé (Pour Distribution)
- ✅ Génère .ipa installable
- ✅ Pour TestFlight et App Store
- 💰 Nécessite Apple Developer ($99/an)
- 🔐 Nécessite certificats et secrets

## 🚀 Démarrage Rapide (Build Simple)

### Étape 1: Pousser sur GitHub

```bash
# Dans le dossier PadelDisplay
git init
git add .
git commit -m "Initial commit - Padel Display"

# Créer un repo sur GitHub puis:
git remote add origin https://github.com/VOTRE_USERNAME/PadelDisplay.git
git push -u origin main
```

### Étape 2: Activer GitHub Actions

1. Allez sur votre repo GitHub
2. Cliquez sur **"Actions"**
3. Les workflows sont automatiquement détectés ✅

### Étape 3: Lancer un Build Manuellement

1. Actions > **"Build iOS App"**
2. Cliquez sur **"Run workflow"**
3. Choisissez le type de build:
   - `debug` - Pour développement
   - `release` - Pour tests
   - `ipa` - Pour générer un fichier .ipa

4. Cliquez **"Run workflow"** ✅

### Étape 4: Attendre le Build

- ⏱️ Temps estimé: **5-10 minutes**
- 📊 Suivez la progression en temps réel
- ✅ Build réussi = check vert ✓

### Étape 5: Télécharger l'App

1. Cliquez sur le workflow terminé
2. Scrollez vers le bas jusqu'à **"Artifacts"**
3. Téléchargez le fichier (`.ipa` ou `.app`)
4. Décompressez le ZIP

## 📦 Utilisation de l'Artifact

### Si vous avez généré un .ipa non signé:
```bash
# Sur Mac, vous pouvez le signer avec vos propres certificats
# Ou l'utiliser pour analyse/tests
```

### Si vous avez généré un .app:
```bash
# Sur Mac, glissez-le dans le simulateur iOS
# Ou analysez-le avec des outils de développement
```

## 🔐 Build Signé (Avancé)

Pour générer un .ipa installable sur iPhone via TestFlight:

### Prérequis
- ✅ Compte Apple Developer actif ($99/an)
- ✅ Certificat de distribution créé
- ✅ Provisioning profile configuré
- ✅ App ID enregistré

### Configuration des Secrets GitHub

1. Allez sur **Settings > Secrets and variables > Actions**
2. Créez ces secrets:

#### Secrets Requis:

| Secret | Description | Comment l'obtenir |
|--------|-------------|-------------------|
| `BUILD_CERTIFICATE_BASE64` | Certificat .p12 encodé | `base64 -i certificate.p12 | pbcopy` |
| `P12_PASSWORD` | Mot de passe du certificat | Défini lors de l'export |
| `BUILD_PROVISION_PROFILE_BASE64` | Provisioning profile encodé | `base64 -i profile.mobileprovision | pbcopy` |
| `KEYCHAIN_PASSWORD` | Mot de passe temporaire | N'importe quel mot de passe fort |

### Créer les Certificats (Sur Mac)

```bash
# 1. Ouvrir Keychain Access
# 2. Certificats > Demander un certificat à une autorité
# 3. Enregistrer le .certSigningRequest

# 4. Sur developer.apple.com:
#    - Certificates > + > Apple Distribution
#    - Uploader le .certSigningRequest
#    - Télécharger le certificat

# 5. Dans Keychain, exporter le certificat:
#    - Clic droit > Exporter > Format .p12
#    - Définir un mot de passe

# 6. Encoder en base64:
base64 -i certificate.p12 | pbcopy
# Coller dans le secret BUILD_CERTIFICATE_BASE64
```

### Créer le Provisioning Profile

```bash
# 1. Sur developer.apple.com:
#    - Profiles > + > Ad Hoc (ou App Store)
#    - Sélectionner App ID
#    - Sélectionner certificat
#    - Sélectionner devices (pour Ad Hoc)
#    - Télécharger le .mobileprovision

# 2. Encoder en base64:
base64 -i profile.mobileprovision | pbcopy
# Coller dans le secret BUILD_PROVISION_PROFILE_BASE64
```

### Lancer le Build Signé

1. Actions > **"Build iOS App (Signed)"**
2. Run workflow > Choisir la méthode:
   - `development` - Pour développement
   - `ad-hoc` - Pour distribution limitée
   - `app-store` - Pour App Store/TestFlight
3. Run workflow ✅

## 🔄 Build Automatique

Les builds se lancent automatiquement si vous modifiez:
- `padel_mobile_app/**` (code de l'app)
- `.github/workflows/build-ios.yml` (workflow)

Pour désactiver, commentez la section `push:` dans le workflow.

## 📊 Monitoring

### Voir les Builds
```
https://github.com/VOTRE_USERNAME/PadelDisplay/actions
```

### Statut du Build
- 🟢 Vert = Succès
- 🔴 Rouge = Échec
- 🟡 Jaune = En cours

### Notifications
- GitHub > Settings > Notifications
- Activez "Actions" pour recevoir des emails

## 🐛 Dépannage

### ❌ Build échoue à "Get Dependencies"
**Solution**: Vérifiez que `pubspec.yaml` est valide
```bash
cd padel_mobile_app
flutter pub get  # Tester localement
```

### ❌ Build échoue à "Install CocoaPods"
**Solution**: Problème iOS, vérifiez `Podfile`
```bash
cd padel_mobile_app/ios
pod install  # Tester sur Mac
```

### ❌ "No space left on device"
**Solution**: Le build est trop gros
- Réduisez les assets
- Nettoyez les dépendances inutiles

### ❌ Certificat invalide (Build signé)
**Solution**: 
- Vérifiez que le certificat est valide (developer.apple.com)
- Vérifiez que le base64 est correct
- Vérifiez le mot de passe P12

### ❌ Provisioning profile ne correspond pas
**Solution**:
- Vérifiez le Bundle ID dans Xcode
- Créez un nouveau profile pour le bon Bundle ID

## 💰 Limites et Quotas

### Repos Publics
- ✅ **2000 minutes/mois** gratuites macOS
- ✅ Largement suffisant (20 builds de 10 min)
- ✅ Illimité si Open Source

### Repos Privés
- ⚠️ Minutes limitées selon votre plan
- macOS: **10x multiplicateur** (10 min réelles = 100 min facturées)
- Solution: Rendre le repo public

## 📈 Optimisation

### Réduire le Temps de Build

1. **Activer le cache**
```yaml
- uses: subosito/flutter-action@v2
  with:
    cache: true  # ✅ Déjà activé
```

2. **Pas de tests inutiles**
```yaml
# Commentez si pas de tests
# - run: flutter test
```

3. **Build seulement sur certains chemins**
```yaml
paths:
  - 'padel_mobile_app/**'  # ✅ Déjà configuré
```

## 🎨 Personnalisation

### Changer la Version de Flutter
```yaml
- uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.0'  # Changez ici
```

### Changer la Version d'Xcode
```yaml
- uses: maxim-lobanov/setup-xcode@v1
  with:
    xcode-version: '15.0'  # Spécifiez la version
```

### Ajouter des Tests
```yaml
- name: 🧪 Run Tests
  working-directory: ./padel_mobile_app
  run: flutter test
```

### Upload vers TestFlight (Automatique)
```yaml
- name: 📤 Upload to TestFlight
  env:
    APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_KEY }}
  run: |
    xcrun altool --upload-app \
      -f build/ios/ipa/*.ipa \
      -t ios \
      --apiKey $APP_STORE_CONNECT_API_KEY
```

## 📚 Ressources

- [GitHub Actions Docs](https://docs.github.com/actions)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [Apple Certificates](https://developer.apple.com/account/resources/certificates)
- [Fastlane](https://fastlane.tools/) - Alternative pour builds complexes

## 🎉 Félicitations!

Vous pouvez maintenant générer votre application iOS depuis Windows grâce à GitHub Actions! 🚀

### Prochaines Étapes

1. ✅ Pousser votre code sur GitHub
2. ✅ Lancer un premier build test
3. ✅ Télécharger l'artifact
4. 📱 Configurer les certificats pour build signé
5. 🚀 Publier sur TestFlight

---

**Questions?** Consultez la section Dépannage ou ouvrez une Issue sur GitHub.
