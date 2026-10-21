# Module : Constants

Ce module centralise toutes les configurations immuables du plugin. L'objectif est d'éviter les "magic numbers" dans le code et de faciliter la mise à jour globale des paramètres.

## Responsabilités
- Définition de la version du plugin (`VERSION`).
- Stockage des constantes géométriques et physiques.
- Définition des valeurs par défaut pour l'interface utilisateur.

## Structure
- `LouverBlade::VERSION` : Version actuelle pour le build et le gestionnaire d'extensions.
- `LouverBlade::DEFAULTS` : Hash contenant les valeurs initiales des lames.
