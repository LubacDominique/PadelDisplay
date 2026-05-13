#!/bin/bash

# Script de Build iOS pour Padel Display App
# À exécuter sur un Mac avec Xcode installé

set -e

echo "🚀 Build iOS - Padel Display"
echo "=============================="
echo ""

# Couleurs pour le terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Vérifier Flutter
echo -e "${YELLOW}1. Vérification de Flutter...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter n'est pas installé!${NC}"
    echo "Installez Flutter: https://docs.flutter.dev/get-started/install"
    exit 1
fi
echo -e "${GREEN}✅ Flutter trouvé${NC}"
flutter --version
echo ""

# Vérifier Xcode
echo -e "${YELLOW}2. Vérification de Xcode...${NC}"
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode n'est pas installé!${NC}"
    echo "Installez Xcode depuis l'App Store"
    exit 1
fi
echo -e "${GREEN}✅ Xcode trouvé${NC}"
xcodebuild -version
echo ""

# Vérifier CocoaPods
echo -e "${YELLOW}3. Vérification de CocoaPods...${NC}"
if ! command -v pod &> /dev/null; then
    echo -e "${RED}❌ CocoaPods n'est pas installé!${NC}"
    echo "Installation de CocoaPods..."
    sudo gem install cocoapods
fi
echo -e "${GREEN}✅ CocoaPods trouvé${NC}"
pod --version
echo ""

# Flutter doctor
echo -e "${YELLOW}4. Diagnostic Flutter...${NC}"
flutter doctor
echo ""

# Nettoyer le projet
echo -e "${YELLOW}5. Nettoyage du projet...${NC}"
flutter clean
echo -e "${GREEN}✅ Projet nettoyé${NC}"
echo ""

# Installer les dépendances Flutter
echo -e "${YELLOW}6. Installation des dépendances Flutter...${NC}"
flutter pub get
echo -e "${GREEN}✅ Dépendances Flutter installées${NC}"
echo ""

# Installer les pods iOS
echo -e "${YELLOW}7. Installation des CocoaPods...${NC}"
cd ios
pod deintegrate || true
pod install
cd ..
echo -e "${GREEN}✅ CocoaPods installés${NC}"
echo ""

# Menu de choix
echo -e "${YELLOW}8. Que voulez-vous faire?${NC}"
echo "1) Compiler pour le simulateur"
echo "2) Compiler pour un iPhone (Debug)"
echo "3) Compiler pour un iPhone (Release)"
echo "4) Générer un fichier .ipa pour distribution"
echo "5) Ouvrir dans Xcode"
echo ""
read -p "Votre choix (1-5): " choice

case $choice in
    1)
        echo -e "${YELLOW}Compilation pour le simulateur...${NC}"
        flutter build ios --simulator
        echo -e "${GREEN}✅ Build terminé!${NC}"
        echo ""
        echo "Pour lancer sur le simulateur:"
        echo "  flutter run"
        ;;
    2)
        echo -e "${YELLOW}Compilation pour iPhone (Debug)...${NC}"
        flutter build ios --debug
        echo -e "${GREEN}✅ Build terminé!${NC}"
        echo ""
        echo "Pour installer sur votre iPhone connecté:"
        echo "  flutter run"
        ;;
    3)
        echo -e "${YELLOW}Compilation pour iPhone (Release)...${NC}"
        flutter build ios --release
        echo -e "${GREEN}✅ Build terminé!${NC}"
        echo ""
        echo "Pour installer sur votre iPhone connecté:"
        echo "  flutter run --release"
        ;;
    4)
        echo -e "${YELLOW}Génération du fichier .ipa...${NC}"
        flutter build ipa --release
        echo -e "${GREEN}✅ Fichier .ipa généré!${NC}"
        echo ""
        echo "Le fichier se trouve dans:"
        echo "  build/ios/ipa/padel_mobile_app.ipa"
        echo ""
        echo "Vous pouvez maintenant:"
        echo "  - L'uploader sur TestFlight"
        echo "  - Le soumettre à l'App Store"
        echo "  - Le distribuer en entreprise"
        ;;
    5)
        echo -e "${YELLOW}Ouverture dans Xcode...${NC}"
        open ios/Runner.xcworkspace
        echo -e "${GREEN}✅ Xcode ouvert!${NC}"
        echo ""
        echo "N'oubliez pas de:"
        echo "  1. Sélectionner votre équipe dans Signing & Capabilities"
        echo "  2. Connecter votre iPhone si nécessaire"
        echo "  3. Sélectionner votre appareil cible"
        ;;
    *)
        echo -e "${RED}Choix invalide${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}=============================="
echo "🎉 Terminé!${NC}"
echo "=============================="
