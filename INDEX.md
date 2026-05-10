# 📚 Index de la Documentation - PadelDisplay

## 🚀 Démarrage Rapide

Vous êtes pressé? Commencez ici:

1. **[QUICKSTART.md](QUICKSTART.md)** - Installation en 5 minutes
2. **[README.md](README.md)** - Vue d'ensemble du projet

## 📖 Documentation Complète

### Pour les Nouveaux Utilisateurs

| Document | Description | Temps de lecture |
|----------|-------------|------------------|
| [README.md](README.md) | Introduction générale et features | 5 min |
| [QUICKSTART.md](QUICKSTART.md) | Installation express | 5 min |
| [HARDWARE.md](HARDWARE.md) | Liste des composants et achats | 10 min |
| [WIRING.md](WIRING.md) | Schémas de connexion détaillés | 15 min |

**Total: 35 minutes pour comprendre et démarrer**

### Pour l'Installation

| Étape | Document | Actions |
|-------|----------|---------|
| 1️⃣ | [HARDWARE.md](HARDWARE.md) | Acheter les composants |
| 2️⃣ | [WIRING.md](WIRING.md) | Câbler le système |
| 3️⃣ | [QUICKSTART.md](QUICKSTART.md) | Installer le logiciel |
| 4️⃣ | [CONFIG.md](CONFIG.md) | Configurer les eTags |
| 5️⃣ | [USAGE.md](USAGE.md) | Premier match! |

### Pour l'Utilisation

| Document | Contenu |
|----------|---------|
| [USAGE.md](USAGE.md) | Guide complet d'utilisation |
| [CONFIG.md](CONFIG.md) | Personnalisation et réglages |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | Résolution de problèmes |

### Pour les Développeurs

| Document | Contenu |
|----------|---------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Architecture technique complète |
| [src/main.cpp](src/main.cpp) | Code source principal (commenté) |
| [platformio.ini](platformio.ini) | Configuration PlatformIO |
| [ROADMAP.md](ROADMAP.md) | Évolutions futures |

### Informations Légales

| Document | Contenu |
|----------|---------|
| [LICENSE](LICENSE) | Licence MIT du projet |

## 🎯 Navigation par Besoin

### "Je veux juste voir si ça marche"
→ [QUICKSTART.md](QUICKSTART.md) (Section test sans matériel)

### "Je dois acheter les composants"
→ [HARDWARE.md](HARDWARE.md) (Section liste des composants)

### "Je suis prêt à câbler"
→ [WIRING.md](WIRING.md) (Schémas de connexion)

### "Ça ne fonctionne pas"
→ [TROUBLESHOOTING.md](TROUBLESHOOTING.md) (Guide de dépannage)

### "Je veux personnaliser"
→ [CONFIG.md](CONFIG.md) (Personnalisation avancée)

### "Je veux contribuer"
→ [ROADMAP.md](ROADMAP.md) (Évolutions futures)

### "Je veux comprendre le code"
→ [ARCHITECTURE.md](ARCHITECTURE.md) (Architecture détaillée)

## 🔍 Recherche Rapide

### Matériel

- **ESP32** → [HARDWARE.md](HARDWARE.md#2-esp32-development-board)
- **Panneau LED** → [HARDWARE.md](HARDWARE.md#1-panneau-led-p5-hub75)
- **eTags BLE** → [HARDWARE.md](HARDWARE.md#3-etags-ble-x2)
- **Alimentation** → [HARDWARE.md](HARDWARE.md#4-alimentation)
- **Câblage** → [WIRING.md](WIRING.md)

### Logiciel

- **Installation** → [QUICKSTART.md](QUICKSTART.md#️-installation-express)
- **Upload code** → [QUICKSTART.md](QUICKSTART.md#5️⃣-upload-du-code-1-min)
- **Configuration BLE** → [CONFIG.md](CONFIG.md#configuration-ble---personnalisation-des-etags)
- **Commandes série** → [CONFIG.md](CONFIG.md#codes-de-commande-série)

### Utilisation

- **Démarrage** → [USAGE.md](USAGE.md#démarrage-rapide)
- **Contrôle des scores** → [USAGE.md](USAGE.md#contrôle-des-scores)
- **Règles du padel** → [USAGE.md](USAGE.md#règles-du-padel)
- **Dépannage** → [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

### Développement

- **Architecture** → [ARCHITECTURE.md](ARCHITECTURE.md)
- **Code source** → [src/main.cpp](src/main.cpp)
- **Librairies** → [platformio.ini](platformio.ini)
- **Roadmap** → [ROADMAP.md](ROADMAP.md)

## 📊 Structure du Projet

```
PadelDisplay/
│
├── 📄 README.md                 # Entrée principale
├── 🚀 QUICKSTART.md            # Installation rapide
├── 📚 INDEX.md                 # Ce fichier (navigation)
│
├── 🔧 HARDWARE.md              # Composants
├── 🔌 WIRING.md                # Connexions
├── ⚙️ CONFIG.md                # Configuration
├── 📖 USAGE.md                 # Guide d'utilisation
├── 🛠️ TROUBLESHOOTING.md      # Dépannage
│
├── 🏗️ ARCHITECTURE.md          # Architecture technique
├── 🗺️ ROADMAP.md               # Évolutions futures
│
├── 📜 LICENSE                  # Licence MIT
├── 🚫 .gitignore               # Git ignore
├── ⚙️ platformio.ini           # Config PlatformIO
│
└── 📁 src/
    └── 💻 main.cpp             # Code principal
```

## 🎓 Parcours d'Apprentissage

### Niveau Débutant (Utilisateur)

1. Lire [README.md](README.md) pour comprendre le concept
2. Suivre [QUICKSTART.md](QUICKSTART.md) pour l'installation
3. Consulter [USAGE.md](USAGE.md) pour l'utilisation
4. En cas de problème: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

**Temps total: 1-2 heures**

### Niveau Intermédiaire (Maker)

1. Tout le niveau débutant
2. Étudier [HARDWARE.md](HARDWARE.md) en détail
3. Suivre [WIRING.md](WIRING.md) pour le câblage
4. Personnaliser via [CONFIG.md](CONFIG.md)

**Temps total: 4-6 heures**

### Niveau Avancé (Développeur)

1. Tout le niveau intermédiaire
2. Lire [ARCHITECTURE.md](ARCHITECTURE.md)
3. Analyser le code [src/main.cpp](src/main.cpp)
4. Contribuer selon [ROADMAP.md](ROADMAP.md)

**Temps total: 8-12 heures**

## 🆘 Support

### En Cas de Problème

1. **Consulter** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. **Vérifier** les logs du moniteur série
3. **Relire** la section correspondante de la doc
4. **Chercher** dans les issues GitHub (si disponible)

### Signaler un Bug

Inclure les informations suivantes:
- Document consulté
- Étape problématique
- Message d'erreur
- Configuration matérielle
- Logs du moniteur série

### Poser une Question

Consulter d'abord:
1. [FAQ.md](FAQ.md) (si créé)
2. [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
3. Les commentaires dans [src/main.cpp](src/main.cpp)

## 🔄 Mises à Jour

Ce projet est en développement actif. Consultez [ROADMAP.md](ROADMAP.md) pour:
- Fonctionnalités prévues
- Timeline de développement
- Comment contribuer

## 📝 Glossaire

- **BLE**: Bluetooth Low Energy
- **eTag**: Tracker Bluetooth avec bouton
- **HUB75**: Protocole d'affichage pour panneaux LED
- **P5**: Pitch de 5mm entre LEDs
- **DMA**: Direct Memory Access (performance)
- **GPIO**: General Purpose Input/Output
- **ESP32**: Microcontrôleur avec WiFi/Bluetooth

## 🌐 Ressources Externes

### Documentation Officielle

- [ESP32 Documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/)
- [PlatformIO Docs](https://docs.platformio.org/)
- [HUB75 MatrixPanel Library](https://github.com/mrfaptastic/ESP32-HUB75-MatrixPanel-DMA)

### Communautés

- [ESP32 Forum](https://esp32.com/)
- [PlatformIO Community](https://community.platformio.org/)
- [Reddit r/esp32](https://reddit.com/r/esp32)

### Tutorials Vidéo

(À ajouter: liens vers tutoriels YouTube si créés)

## ✅ Checklist Complète

Avant de commencer:
- [ ] J'ai lu [README.md](README.md)
- [ ] J'ai tous les composants ([HARDWARE.md](HARDWARE.md))
- [ ] J'ai installé PlatformIO ([QUICKSTART.md](QUICKSTART.md))

Installation:
- [ ] Câblage terminé ([WIRING.md](WIRING.md))
- [ ] Code uploadé ([QUICKSTART.md](QUICKSTART.md))
- [ ] eTags configurés ([CONFIG.md](CONFIG.md))
- [ ] Tests réussis ([USAGE.md](USAGE.md))

Utilisation:
- [ ] Je sais ajouter un point
- [ ] Je sais corriger une erreur
- [ ] Je sais réinitialiser le match
- [ ] Je sais où chercher en cas de problème

## 🎉 Prêt à Démarrer!

**Première fois?** → [QUICKSTART.md](QUICKSTART.md)

**Bon match de padel!** 🎾

---

**Dernière mise à jour:** Avril 2026  
**Version de la documentation:** 1.0
