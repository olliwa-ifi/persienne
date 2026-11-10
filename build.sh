#!/bin/bash

# ==============================================================================
# Script de build et d'installation locale pour Louver Blade Generator
# ==============================================================================
# On définit la racine du projet (le dossier qui contient src et release)
# On remonte d'un niveau car ce script est dans le dossier racine du plugin
echo "------------------------------------------------------------"
echo "📦 Building & Installing Olliwa Louver Blade Generator"
echo "------------------------------------------------------------"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$ROOT_DIR/src"
PLUGIN_LOADER="$SOURCE_DIR/olw_louver_blade_generator"
PLUGIN_DIR_NAME="olw_louver_blade"
RELEASE_DIR="$ROOT_DIR/release"
CONSTANTS_FILE="$SOURCE_DIR/$PLUGIN_DIR_NAME/constants.rb"
echo "CONSTANTS_FILE path: $CONSTANTS_FILE"

# --- CONFIGURATION DU CHEMIN SKETCHUP (Windows via Git Bash) ---
# On utilise la variable d'environnement APPDATA pour trouver le chemin dynamiquement
SKETCHUP_PLUGINS_DIR="$APPDATA/SketchUp/SketchUp 2020/SketchUp/Plugins"
# --------------------------------------------------------------


# 1. Extraction de la version
echo "1. Extracting version from $CONSTANTS_FILE..."
if [ -f "$CONSTANTS_FILE" ]; then
    echo "✅ Found $CONSTANTS_FILE"
    VERSION=$(grep "VERSION =" "$CONSTANTS_FILE" | awk -F'"' '{print $2}' | tr -d '\r\n ')
else
    echo "❌ Error: $CONSTANTS_FILE not found."
    exit 1
fi

if [ -z "$VERSION" ]; then
    echo "❌ Error: Could not extract VERSION from $CONSTANTS_FILE"
    exit 1
fi

echo "Version detected: $VERSION"
FINAL_FILENAME="${PLUGIN_DIR_NAME}_v${VERSION}.rbz"

# 2. Création du dossier release
echo "2.Creating release directory... dans $(pwd)"
mkdir -p ${RELEASE_DIR}

# 3. Compression pour créer le .rbz (pour distribution)
echo "---------------------------------------------"
echo "🚀 Compressing with 7-Zip..."
echo "--------------------------------------------"
echo "3.Compressing into .rbz..."
echo "Current directory: $(pwd)"
echo "Final filename will be: $FINAL_FILENAME"
echo "RELEASE_DIR is: $RELEASE_DIR"
echo "Plugin loader name is: $PLUGIN_LOADER"
echo "Plugin directory name is: $PLUGIN_DIR_NAME"
echo "$RELEASE_DIR/$FINAL_FILENAME" "$PLUGIN_LOADER.rb" "$SOURCE_DIR/$PLUGIN_DIR_NAME/"

7z a -tzip "$RELEASE_DIR/$FINAL_FILENAME" "$PLUGIN_LOADER.rb" "$SOURCE_DIR/$PLUGIN_DIR_NAME/"

if [ $? -eq 0 ]; then
    echo "✅ Success! Generated: release/$FINAL_FILENAME"
else
    echo "❌ Error: Compression failed."
    exit 1
fi


# 4. INSTALLATION LOCALE (Déploiement direct dans SketchUp 2020)
echo "------------------------------------------------------------"
echo "🚀 Installing to SketchUp 2020 Plugins folder..."
echo "------------------------------------------------------------"

if [ -d "$SKETCHUP_PLUGINS_DIR" ]; then
    echo "Target directory found: $SKETCHUP_PLUGINS_DIR"
    
    # On extrait le .rbz directement dans le dossier plugins de SketchUp
    # -y force l'écrasement des fichiers existants
    7z x "$RELEASE_DIR/$FINAL_FILENAME" "-o$SKETCHUP_PLUGINS_DIR" -y
    
    if [ $? -eq 0 ]; then
        echo "✅ Plugin successfully installed (forced) to: $SKETCHUP_PLUGINS_DIR"
    else
        echo "❌ Error: Extraction failed during installation."
    fi
    echo "✅ Installation complete! Please restart SketchUp 2020."
else
    echo "❌ Error: SketchUp 2020 Plugins directory not found at $SKETCHUP_PLUGINS_DIR"
    exit 1
fi

echo "------------------------------------------------------------"
echo "📦 Build and installation process completed successfully!"
echo "------------------------------------------------------------"