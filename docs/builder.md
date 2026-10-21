# Module : Builder

Le module `Builder` est le pont entre la logique mathématique et l'API SketchUp. Il transforme des données numériques en objets 3D tangibles.

## Responsabilités
- Création des entités SketchUp (Edges, Faces, Groups).
- Gestion des composants et des composants dynamiques.
- Application des transformations spatiales (rotations, translations).

## Flux de travail
1. Reçoit les paramètres validés depuis le `Main` module.
2. Appelle `Logic` pour obtenir les coordonnées.
3. Ouvre une opération (`model.start_operation`) pour permettre l'annulation (Undo).
4. Génère la géométrie dans le modèle.
