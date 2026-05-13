#!/bin/bash

# Script pour lancer un build GitHub Actions depuis la ligne de commande
# Nécessite GitHub CLI: https://cli.github.com/

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════╗"
echo "║  🚀 GitHub Actions Build Launcher     ║"
echo "║     Padel Display iOS App             ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"

# Vérifier que gh est installé
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}⚠️  GitHub CLI n'est pas installé${NC}"
    echo ""
    echo "Installez-le avec:"
    echo "  macOS: brew install gh"
    echo "  Linux: apt install gh"
    echo "  Windows: winget install GitHub.cli"
    echo ""
    echo "Ou téléchargez depuis: https://cli.github.com/"
    exit 1
fi

# Vérifier l'authentification
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}🔐 Authentification GitHub requise${NC}"
    gh auth login
fi

echo -e "${GREEN}✅ GitHub CLI prêt${NC}"
echo ""

# Menu
echo -e "${YELLOW}Quel type de build voulez-vous lancer?${NC}"
echo ""
echo "1) 🐛 Debug - Pour développement"
echo "2) 🚀 Release - Pour tests"
echo "3) 📦 IPA - Fichier .ipa non signé"
echo "4) 🔐 Signed Development - App signée (développement)"
echo "5) 📱 Signed Ad Hoc - App signée (distribution limitée)"
echo "6) 🏪 Signed App Store - App signée (App Store/TestFlight)"
echo "7) 📊 Voir les builds récents"
echo "8) 📥 Télécharger le dernier build"
echo ""
read -p "Votre choix (1-8): " choice

case $choice in
    1)
        echo -e "${BLUE}🐛 Lancement du build Debug...${NC}"
        gh workflow run build-ios.yml -f build_type=debug
        ;;
    2)
        echo -e "${BLUE}🚀 Lancement du build Release...${NC}"
        gh workflow run build-ios.yml -f build_type=release
        ;;
    3)
        echo -e "${BLUE}📦 Lancement du build IPA...${NC}"
        gh workflow run build-ios.yml -f build_type=ipa
        ;;
    4)
        echo -e "${BLUE}🔐 Lancement du build Signé (Development)...${NC}"
        echo -e "${YELLOW}⚠️  Nécessite les secrets configurés dans GitHub${NC}"
        gh workflow run build-ios-signed.yml -f distribution_method=development
        ;;
    5)
        echo -e "${BLUE}📱 Lancement du build Signé (Ad Hoc)...${NC}"
        echo -e "${YELLOW}⚠️  Nécessite les secrets configurés dans GitHub${NC}"
        gh workflow run build-ios-signed.yml -f distribution_method=ad-hoc
        ;;
    6)
        echo -e "${BLUE}🏪 Lancement du build Signé (App Store)...${NC}"
        echo -e "${YELLOW}⚠️  Nécessite les secrets configurés dans GitHub${NC}"
        gh workflow run build-ios-signed.yml -f distribution_method=app-store
        ;;
    7)
        echo -e "${BLUE}📊 Builds récents:${NC}"
        echo ""
        gh run list --limit 10
        echo ""
        echo "Pour voir les détails d'un build:"
        echo "  gh run view <RUN_ID>"
        exit 0
        ;;
    8)
        echo -e "${BLUE}📥 Recherche du dernier build...${NC}"
        RUN_ID=$(gh run list --workflow=build-ios.yml --limit 1 --json databaseId --jq '.[0].databaseId')
        echo ""
        echo "Artifacts disponibles:"
        gh run view $RUN_ID
        echo ""
        read -p "Nom de l'artifact à télécharger: " artifact_name
        gh run download $RUN_ID --name "$artifact_name"
        echo -e "${GREEN}✅ Téléchargé dans le dossier actuel${NC}"
        exit 0
        ;;
    *)
        echo -e "${YELLOW}❌ Choix invalide${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Build lancé avec succès!${NC}"
echo ""
echo "📊 Suivez la progression sur:"
echo "   https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/actions"
echo ""
echo "Ou dans le terminal:"
echo "   gh run watch"
echo ""
echo "Pour télécharger une fois terminé:"
echo "   gh run list"
echo "   gh run download <RUN_ID>"
