# Script PowerShell pour lancer un build GitHub Actions
# Nécessite GitHub CLI: https://cli.github.com/

$ErrorActionPreference = "Stop"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

Write-ColorOutput "╔═══════════════════════════════════════╗" -Color Cyan
Write-ColorOutput "║    GitHub Actions Build Launcher      ║" -Color Cyan
Write-ColorOutput "║     Padel Display iOS App             ║" -Color Cyan
Write-ColorOutput "╚═══════════════════════════════════════╝" -Color Cyan
Write-Host ""

# Vérifier que gh est installé
if (!(Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-ColorOutput "GitHub CLI n'est pas installe" -Color Yellow
    Write-Host ""
    Write-Host "Installez-le avec:"
    Write-Host "  winget install GitHub.cli"
    Write-Host ""
    Write-Host "Ou telechargez depuis: https://cli.github.com/"
    exit 1
}

# Vérifier l'authentification
try {
    gh auth status 2>&1 | Out-Null
    Write-ColorOutput "GitHub CLI pret" -Color Green
} catch {
    Write-ColorOutput "Authentification GitHub requise" -Color Yellow
    gh auth login
}

Write-Host ""

# Menu
Write-ColorOutput "Quel type de build voulez-vous lancer?" -Color Yellow
Write-Host ""
Write-Host "1) Debug - Pour developpement"
Write-Host "2) Release - Pour tests"
Write-Host "3) IPA - Fichier .ipa non signe"
Write-Host "4) Signed Development - App signee (developpement)"
Write-Host "5) Signed Ad Hoc - App signee (distribution limitee)"
Write-Host "6) Signed App Store - App signee (App Store/TestFlight)"
Write-Host "7) Voir les builds recents"
Write-Host "8) Telecharger le dernier build"
Write-Host ""
$choice = Read-Host "Votre choix (1-8)"

switch ($choice) {
    "1" {
        Write-ColorOutput "Lancement du build Debug..." -Color Cyan
        gh workflow run build-ios.yml -f build_type=debug
    }
    "2" {
        Write-ColorOutput "Lancement du build Release..." -Color Cyan
        gh workflow run build-ios.yml -f build_type=release
    }
    "3" {
        Write-ColorOutput "Lancement du build IPA..." -Color Cyan
        gh workflow run build-ios.yml -f build_type=ipa
    }
    "4" {
        Write-ColorOutput "Lancement du build Signe (Development)..." -Color Cyan
        Write-ColorOutput "ATTENTION: Necessite les secrets configures dans GitHub" -Color Yellow
        gh workflow run build-ios-signed.yml -f distribution_method=development
    }
    "5" {
        Write-ColorOutput "Lancement du build Signe (Ad Hoc)..." -Color Cyan
        Write-ColorOutput "ATTENTION: Necessite les secrets configures dans GitHub" -Color Yellow
        gh workflow run build-ios-signed.yml -f distribution_method=ad-hoc
    }
    "6" {
        Write-ColorOutput "Lancement du build Signe (App Store)..." -Color Cyan
        Write-ColorOutput "ATTENTION: Necessite les secrets configures dans GitHub" -Color Yellow
        gh workflow run build-ios-signed.yml -f distribution_method=app-store
    }
    "7" {
        Write-ColorOutput "Builds recents:" -Color Cyan
        Write-Host ""
        gh run list --limit 10
        Write-Host ""
        Write-Host "Pour voir les détails d'un build:"
        Write-Host "  gh run view <RUN_ID>"
        exit 0
    }
    "8" {
        Write-ColorOutput "Recherche du dernier build..." -Color Cyan
        $runId = (gh run list --workflow=build-ios.yml --limit 1 --json databaseId | ConvertFrom-Json)[0].databaseId
        Write-Host ""
        Write-Host "Artifacts disponibles:"
        gh run view $runId
        Write-Host ""
        $artifactName = Read-Host "Nom de l'artifact a telecharger"
        gh run download $runId --name $artifactName
        Write-ColorOutput "Telecharge dans le dossier actuel" -Color Green
        exit 0
    }
    default {
        Write-ColorOutput "Choix invalide" -Color Red
        exit 1
    }
}

Write-Host ""
Write-ColorOutput "Build lance avec succes!" -Color Green
Write-Host ""
Write-Host "Suivez la progression sur:"

# Obtenir l'URL du repo
$repoInfo = gh repo view --json nameWithOwner | ConvertFrom-Json
$repoUrl = "https://github.com/$($repoInfo.nameWithOwner)/actions"
Write-Host "   $repoUrl"

Write-Host ""
Write-Host "Ou dans le terminal:"
Write-Host "   gh run watch"
Write-Host ""
Write-Host "Pour télécharger une fois terminé:"
Write-Host "   gh run list"
Write-Host "   gh run download <RUN_ID>"
Write-Host ""
Write-ColorOutput "Appuyez sur Entree pour ouvrir GitHub Actions dans le navigateur..." -Color Yellow
Read-Host
Start-Process $repoUrl
