# Module : Logic

Le module `Logic` contient toute l'intelligence mathématique et les conversions du plugin. Il est totalement indépendant de l'interface utilisateur et de l'API graphique de SketchUp.

## Responsabilités
- Calculs de trigonométrie pour l'inclinaison des lames.
- Gestion des conversions d'unités.
- Validation des paramètres d'entrée.

## Méthodes Clés
- `LouverBlade.cm_to_in(val)` : Convertit les centimètres en pouces.
- `LouverBlade.in_to_cm(val)` : Convertit les pouces en centimètres.
- `calculate_blade_geometry(...)` : Retourne les coordonnées et vecteurs nécessaires à la construction.
