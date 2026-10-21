#!/bin/bash

# ==============================================================================
# Script de build pour Louver Blade Generator (.rbz)
# ==============================================================================

PLUGIN_BASE_NAME="louver_blade_generator"
SOURCE_DIR="src/louver_blade_generator"
CONSTANTS_FILE="$SOURCE_DIR/louver_blade/constants.rb"

echo "------------------------------------------------------------"
echo "📦 Building $PLUGIN_BASE_NAME"
echo "------------------------------------------------------------"

# 1. Extraction de la version
# - On cherche la ligne VERSION =
# - On découpe par les guillemets avec awk et on prend la 2ème colonne
# - On nettoie les espaces et retours chariots Windows avec tr
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

# Noms de fichiers

echo "Version detected: $VERSION"
final_filename="${PLUGIN_BASE_NAME}_v${VERSION}.rbz"
# 3. Création du dossier release au même niveau que src et assets
mkdir -p release

# 4. Compression (7z via PATH)
# On entre dans le dossier spécifique pour que le loader soit à la racine du .rbz
echo "Compressing..."
# On compresse le loader et le dossier source
(
    cd "$SOURCE_DIR" && \
    7z a -tzip "../../../release/$FINAL_FILENAME" "louver_blade_generator.rb" "louver_blade/"
)

# 4. Finalisation
if [ $? -eq 0 ]; then
    mv "$TEMP_ZIP" "$FINAL_FILENAME"
    echo "------------------------------------------------------------"
    echo "✅ Success! Generated: $FINAL_FILENAME"
    echo "------------------------------------------------------------"
else
    echo "❌ Error: Compression failed."
    rm -f "$TEMP_ZIP"
    exit 1
fi
