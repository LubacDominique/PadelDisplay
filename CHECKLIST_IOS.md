# ✅ Checklist - Génération App iPhone Padel Display

## 📋 Avant de Commencer

### Matériel Nécessaire
- [ ] Mac avec macOS 12.0+ (obligatoire pour iOS)
- [ ] iPhone pour tester (le simulateur ne supporte pas Bluetooth)
- [ ] Câble USB pour connecter l'iPhone au Mac

### Logiciels Requis
- [ ] Xcode 14.0+ installé (App Store)
- [ ] Flutter installé (https://flutter.dev)
- [ ] CocoaPods installé (`sudo gem install cocoapods`)

### Compte Apple
- [ ] Compte Apple ID (gratuit)
- [ ] Apple Developer Account (99€/an) - seulement pour App Store

## 🔧 Configuration Initiale (Sur Mac)

### 1. Vérification de l'Environnement
```bash
flutter doctor
```
- [ ] Flutter installé correctement
- [ ] Xcode installé et configuré
- [ ] iOS toolchain prête
- [ ] CocoaPods fonctionnel

### 2. Configuration du Projet
- [ ] Copier le dossier `padel_mobile_app` sur le Mac
- [ ] Ouvrir Terminal dans le dossier
- [ ] Exécuter `flutter pub get`
- [ ] Exécuter `cd ios && pod install && cd ..`

### 3. Configuration Xcode
- [ ] Ouvrir `ios/Runner.xcworkspace` dans Xcode
- [ ] Sélectionner "Runner" dans le navigateur
- [ ] Aller dans "Signing & Capabilities"
- [ ] Sélectionner votre "Team"
- [ ] Vérifier le Bundle Identifier (ex: com.yourcompany.padeldisplay)

## 📱 Test sur Simulateur (Sans Bluetooth)

### Compilation
- [ ] Lancer le simulateur: `open -a Simulator`
- [ ] Compiler: `flutter run`
- [ ] L'app se lance sans erreur
- [ ] L'interface s'affiche correctement

⚠️ **Note**: Le Bluetooth ne fonctionnera PAS sur le simulateur!

## 📲 Test sur iPhone Réel (Avec Bluetooth)

### Préparation de l'iPhone
- [ ] Connecter l'iPhone au Mac via USB
- [ ] Déverrouiller l'iPhone
- [ ] Activer "Mode Développeur" (Réglages > Confidentialité et sécurité)
- [ ] Faire confiance à l'ordinateur (popup sur iPhone)

### Première Installation
- [ ] Dans Xcode, sélectionner votre iPhone comme cible
- [ ] Cliquer sur Play (▶️) ou exécuter `flutter run`
- [ ] Accepter les permissions sur l'iPhone
- [ ] L'app s'installe et se lance

### Test Bluetooth
- [ ] ESP32 allumé et en mode publicité
- [ ] Ouvrir l'app sur l'iPhone
- [ ] Accepter les permissions Bluetooth
- [ ] L'app détecte l'ESP32
- [ ] La connexion s'établit
- [ ] Le score peut être envoyé

## 🏗 Build de Release

### Version de Développement
```bash
flutter build ios --release
```
- [ ] Build réussi sans erreur
- [ ] Taille du build acceptable (<100MB)

### Version pour Distribution (.ipa)
```bash
flutter build ipa --release
```
- [ ] Fichier .ipa généré dans `build/ios/ipa/`
- [ ] Taille du fichier notée: _______ MB

## 📤 Distribution

### Option 1: TestFlight (Recommandé)
- [ ] Compte Apple Developer actif
- [ ] App Store Connect configuré
- [ ] Certificats et profils de provisionnement créés
- [ ] Upload du .ipa via Xcode > Organizer
- [ ] Soumission pour review interne
- [ ] Invitations testeurs envoyées
- [ ] Tests effectués par les bêta-testeurs

### Option 2: Installation Directe (Dev uniquement)
- [ ] iPhone connecté en USB
- [ ] `flutter run --release` exécuté
- [ ] App installée sur l'iPhone
- [ ] App fonctionne après déconnexion USB

### Option 3: App Store
- [ ] TestFlight complété avec succès
- [ ] Captures d'écran préparées (tous formats requis)
- [ ] Description de l'app rédigée
- [ ] Mots-clés définis
- [ ] Catégorie choisie
- [ ] Politique de confidentialité publiée
- [ ] Soumission pour review App Store
- [ ] Review approuvée
- [ ] App publiée sur l'App Store

## 🎨 Personnalisation (Optionnel)

### Identité Visuelle
- [ ] Icône de l'app créée (1024x1024)
- [ ] Icône générée pour toutes tailles (appicon.co)
- [ ] Icône installée dans `ios/Runner/Assets.xcassets/`
- [ ] Nom de l'app modifié dans Info.plist
- [ ] Splash screen personnalisé

### Branding
- [ ] Bundle Identifier changé
- [ ] Nom de l'équipe configuré
- [ ] Couleurs de thème ajustées
- [ ] Polices personnalisées ajoutées

## 🐛 Vérifications Finales

### Fonctionnalité
- [ ] Connexion Bluetooth stable
- [ ] Envoi de score fonctionne
- [ ] Base de données sauvegarde correctement
- [ ] Historique s'affiche
- [ ] Pas de crash en utilisation normale

### Performance
- [ ] App se lance en moins de 3 secondes
- [ ] Transitions fluides (60 FPS)
- [ ] Pas de lag lors de l'utilisation
- [ ] Batterie: consommation acceptable
- [ ] Mémoire: pas de fuite détectée

### Compatibilité
- [ ] Testé sur iPhone récent (iOS 16+)
- [ ] Testé sur iPhone ancien si possible (iOS 12+)
- [ ] Testé sur iPad (optionnel)
- [ ] Rotation d'écran fonctionne
- [ ] Mode sombre supporté (si implémenté)

## 📊 Métriques de Succès

### Taille de l'App
- Release Build: _______ MB
- IPA final: _______ MB
- Installation sur iPhone: _______ MB

### Performance
- Temps de lancement: _______ secondes
- Connexion Bluetooth: _______ secondes
- FPS moyen: _______

### Portée Bluetooth
- Distance maximale testée: _______ mètres
- Stabilité de connexion: Excellent / Bon / Moyen / Faible

## 📝 Notes et Problèmes Rencontrés

### Problèmes
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

### Solutions Appliquées
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

## 🎉 Lancement

- [ ] App testée et validée
- [ ] Documentation utilisateur créée
- [ ] Vidéo de démo enregistrée (optionnel)
- [ ] Users beta satisfaits
- [ ] Prêt pour le lancement public

---

**Date de début**: _____________  
**Date de fin**: _____________  
**Version finale**: 1.0.0+1  
**Statut**: ⬜ En cours | ⬜ Complété | ⬜ Bloqué
