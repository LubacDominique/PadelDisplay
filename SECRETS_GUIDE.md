# Générer les Secrets pour GitHub Actions

Ce guide vous aide à créer les secrets nécessaires pour signer votre app iOS avec GitHub Actions.

## 🎯 Secrets Nécessaires

1. `BUILD_CERTIFICATE_BASE64` - Certificat de signature (.p12)
2. `P12_PASSWORD` - Mot de passe du certificat
3. `BUILD_PROVISION_PROFILE_BASE64` - Provisioning profile
4. `KEYCHAIN_PASSWORD` - Mot de passe temporaire (au choix)

## 📋 Étape par Étape (Sur Mac)

### 1. Créer une Demande de Certificat

```bash
# Ouvrir Keychain Access (Trousseau d'accès)
# Menu: Certificate Assistant > Request a Certificate from a Certificate Authority
# Remplir:
#   - Email: votre email Apple Developer
#   - Common Name: Votre nom
#   - CA Email: laisser vide
#   - Request: Saved to disk
#   - Cocher: Let me specify key pair information

# Sauvegarder: CertificateSigningRequest.certSigningRequest
```

### 2. Créer le Certificat sur developer.apple.com

```bash
# 1. Aller sur https://developer.apple.com/account/resources/certificates
# 2. Cliquer sur "+" pour créer un certificat
# 3. Choisir selon votre besoin:
#    - iOS App Development (pour tests)
#    - Apple Distribution (pour App Store/TestFlight)
# 4. Uploader le .certSigningRequest
# 5. Télécharger le certificat: ios_distribution.cer
```

### 3. Installer et Exporter le Certificat

```bash
# 1. Double-cliquer sur ios_distribution.cer pour l'installer dans Keychain

# 2. Dans Keychain Access:
#    - Trouver "Apple Distribution: Votre Nom"
#    - Clic droit > Export "Apple Distribution: Votre Nom"
#    - Format: Personal Information Exchange (.p12)
#    - Sauvegarder: Certificates.p12
#    - Entrer un mot de passe FORT (notez-le!)

# 3. Encoder en base64:
base64 -i Certificates.p12 | pbcopy

# 4. Coller dans GitHub:
#    Settings > Secrets > New repository secret
#    Name: BUILD_CERTIFICATE_BASE64
#    Value: Coller (Cmd+V)
```

### 4. Créer l'App ID (Si pas déjà fait)

```bash
# 1. https://developer.apple.com/account/resources/identifiers
# 2. Cliquer sur "+" > App IDs > App
# 3. Remplir:
#    - Description: Padel Display
#    - Bundle ID: Explicit > com.yourcompany.padeldisplay
#    - Capabilities: Cocher "Bluetooth" si nécessaire
# 4. Register
```

### 5. Créer le Provisioning Profile

```bash
# 1. https://developer.apple.com/account/resources/profiles
# 2. Cliquer sur "+" pour créer un profil
# 3. Choisir selon distribution:
#    - iOS App Development (pour tests sur vos devices)
#    - Ad Hoc (pour distribuer à des testeurs spécifiques)
#    - App Store (pour TestFlight et App Store)
# 4. Sélectionner votre App ID
# 5. Sélectionner votre certificat
# 6. Sélectionner les devices (pour Development et Ad Hoc uniquement)
# 7. Donner un nom: "Padel Display Development"
# 8. Télécharger: Padel_Display_Development.mobileprovision
```

### 6. Encoder le Provisioning Profile

```bash
# Encoder en base64:
base64 -i Padel_Display_Development.mobileprovision | pbcopy

# Ajouter dans GitHub:
# Settings > Secrets > New repository secret
# Name: BUILD_PROVISION_PROFILE_BASE64
# Value: Coller (Cmd+V)
```

### 7. Ajouter les Autres Secrets

```bash
# P12_PASSWORD
# Le mot de passe que vous avez choisi à l'étape 3
# GitHub: Settings > Secrets > New repository secret
# Name: P12_PASSWORD
# Value: votre_mot_de_passe

# KEYCHAIN_PASSWORD
# N'importe quel mot de passe fort (juste pour GitHub Actions)
# GitHub: Settings > Secrets > New repository secret
# Name: KEYCHAIN_PASSWORD
# Value: un_mot_de_passe_securise
```

## 🔄 Script Automatique (macOS)

Voici un script pour automatiser l'encodage:

```bash
#!/bin/bash

echo "🔐 Générateur de Secrets GitHub Actions iOS"
echo "==========================================="

# Certificat
if [ -f "Certificates.p12" ]; then
    echo "📜 Encodage du certificat..."
    CERT_BASE64=$(base64 -i Certificates.p12)
    echo "BUILD_CERTIFICATE_BASE64:"
    echo "$CERT_BASE64"
    echo ""
else
    echo "❌ Certificates.p12 non trouvé"
fi

# Provisioning Profile
if [ -f "*.mobileprovision" ]; then
    echo "📱 Encodage du provisioning profile..."
    PROFILE=$(ls *.mobileprovision | head -n 1)
    PROFILE_BASE64=$(base64 -i "$PROFILE")
    echo "BUILD_PROVISION_PROFILE_BASE64:"
    echo "$PROFILE_BASE64"
    echo ""
else
    echo "❌ .mobileprovision non trouvé"
fi

echo "✅ Terminé!"
echo ""
echo "Copiez ces valeurs dans GitHub:"
echo "Settings > Secrets and variables > Actions > New repository secret"
```

## 🔒 Sécurité

### ⚠️ Important!

- ❌ **NE JAMAIS** commiter les fichiers .p12 ou .mobileprovision
- ❌ **NE JAMAIS** partager les secrets en clair
- ✅ Utiliser **uniquement** les GitHub Secrets
- ✅ Régénérer les secrets si compromis
- ✅ Révoquer les anciens certificats inutilisés

### Fichiers à Ignorer

Ajoutez dans `.gitignore`:
```
# iOS Signing
*.p12
*.cer
*.certSigningRequest
*.mobileprovision
ios/ExportOptions.plist.backup
```

## 🔄 Renouveler les Certificats

Les certificats expirent après 1 an. Pour renouveler:

```bash
# 1. Révoquer l'ancien certificat (developer.apple.com)
# 2. Créer un nouveau certificat (étapes 1-3)
# 3. Mettre à jour BUILD_CERTIFICATE_BASE64 dans GitHub
# 4. Créer un nouveau provisioning profile (étape 5)
# 5. Mettre à jour BUILD_PROVISION_PROFILE_BASE64 dans GitHub
```

## 🧪 Tester les Secrets

Après avoir configuré les secrets:

```bash
# 1. GitHub > Actions > Build iOS App (Signed)
# 2. Run workflow > development
# 3. Attendre le build

# Si succès ✅: Secrets corrects!
# Si échec ❌: Vérifier les logs pour voir quel secret est invalide
```

## 📝 Checklist

- [ ] Compte Apple Developer actif
- [ ] Certificat créé et exporté (.p12)
- [ ] Mot de passe P12 noté
- [ ] App ID créé sur developer.apple.com
- [ ] Provisioning profile téléchargé
- [ ] BUILD_CERTIFICATE_BASE64 ajouté dans GitHub
- [ ] P12_PASSWORD ajouté dans GitHub
- [ ] BUILD_PROVISION_PROFILE_BASE64 ajouté dans GitHub
- [ ] KEYCHAIN_PASSWORD ajouté dans GitHub
- [ ] Test build lancé avec succès

## 🆘 Problèmes Courants

### "Certificate identity not found"
- Le certificat n'est pas valide ou mal encodé
- Vérifiez que vous avez bien exporté le certificat avec sa clé privée

### "Provisioning profile doesn't match"
- Le Bundle ID ne correspond pas
- Créez un nouveau profile avec le bon Bundle ID

### "Invalid P12 password"
- Le mot de passe P12_PASSWORD est incorrect
- Vérifiez que vous avez bien copié le bon mot de passe

### "Unable to install provisioning profile"
- Le profile est expiré ou révoqué
- Créez un nouveau profile sur developer.apple.com

---

**Besoin d'aide?** Consultez la [documentation Apple](https://developer.apple.com/support/certificates/) ou ouvrez une issue.
