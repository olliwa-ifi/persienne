# Module : Builder
 Ce document explique la stratégie de construction géométrique, l'optimisation des performances et la gestion des entités SketchUp.

---

# Spécifications Construction : GeometryBuilder

## 1. Vision Conceptuelle
Le `GeometryBuilder` est le moteur d'exécution final. Son rôle est de traduire les données mathématiques abstraites fournies par la classe `Louver` en entités physiques (faces, groupes, composants) dans l'espace 3D de SketchUp.

Le concepteur a privilégié une approche basée sur les **Composants (`ComponentDefinitions`)** plutôt que sur la géométrie brute. Cette méthode permet d'optimiser la mémoire et facilite la modification ultérieure du modèle par l'utilisateur.

## 2. Stratégie de Construction

### Optimisation par Instanciation
Au lieu de créer chaque lame comme une géométrie unique, le builder utilise un processus en deux étapes :
1.  **Définition (`Definition`) :** Une seule lame et un seul rail sont dessinés dans l'espace de définition.
2.  **Instanciation (`Instance`) :** Le builder place des copies (instances) de ces définitions aux coordonnées calculées.
    *   *Avantage :* Si l'utilisateur modifie une seule lame, toutes les autres sont mises à jour instantanément. Le poids du fichier `.skp` est drastiquement réduit.

### Gestion des Hiérarchies
Pour éviter de polluer l'espace de travail de l'utilisateur, toute la structure est encapsulée :
`Active Entities` $\rightarrow$ `Group (Louver_Assembly)` $\rightarrow$ `Component Instances`.

## 3. Détails Techniques de l'Implémentation

### Flux de Création
Le processus suit un ordre strict pour garantir l'alignement :
1.  **Création des Definitions :** Génération des profils de la lame et des rails (haut/bas).
2.  **Placement des Rails :** Positionnement des cadres structurels.
3.  **Distribution des Lames :** Placement itératif des lames selon l'espacement vertical (`vertical_spacing`), avec une gestion spécifique des extrémités si l'option `integrated_blades` est activée.

### Traitement Géométrique
- **PushPull :** Les profils 2D sont dessinés sur le plan YZ, puis extrudés via la méthode `pushpull` pour créer le volume.
- **Transformations :** Utilisation de `Geom::Transformation` pour positionner et orienter précisément chaque instance dans l'espace.
- **Matériaux :** Un système de gestion des matériaux (`get_or_create_material`) assure que les couleurs définies dans la configuration sont appliquées uniformément à toutes les faces du composant.

## 4. Robustesse et Intégrité du Modèle

### Gestion des Transactions (`Operations`)
Toute la génération est enveloppée dans une opération SketchUp :
`@model.start_operation("Louver Generator", true)`

C'est un point critique pour deux raisons :
1.  **Annulation Unique :** L'utilisateur peut annuler la création complète d'un persienne en un seul `Ctrl+Z`, au lieu de devoir supprimer chaque lame individuellement.
2.  **Performance :** SketchUp ne rafraîchit pas l'affichage à chaque face créée, mais seulement une fois à la fin de l'opération (`commit_operation`), ce qui accélère considérablement la génération.

### Gestion des Erreurs
En cas de plantage durant la construction (ex: erreur de mémoire), le bloc `rescue` déclenche un `abort_operation`. Cela nettoie instantanément toutes les entités partiellement créées, laissant le modèle de l'utilisateur dans son état initial, sans débris géométriques.

## 5. Complexité et Performance
- **Complexité Temporelle :** $O(N)$ où $N$ est le nombre de lames. L'utilisation de composants rend le placement des instances quasi instantané.
- **Complexité Spatiale :** Optimisée grâce aux définitions partagées. La consommation mémoire est constante quelle que soit la longueur de la persienne, seule la liste des instances augmente.