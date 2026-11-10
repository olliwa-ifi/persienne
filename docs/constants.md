# 📐 Note de Conception : Constantes et Utilitaires

Ce document expose la stratégie de conception adoptée pour la gestion des paramètres globaux et des conversions d'unités du plugin LouverBlade.

## 🎯 Objectifs de Conception
L'objectif est de centraliser tous les paramètres "statiques" pour éviter la dispersion de valeurs magiques (*magic numbers*) dans le code. Cette approche permet :
1. Une modification rapide de l'esthétique (couleurs) sans fouiller dans la logique de construction.
2. Une garantie de cohérence des unités entre l'interface utilisateur (métrique) et le moteur SketchUp (impérial).

## 🎨 Stratégie Visuelle (`CONFIG`)

Plutôt que de définir les matériaux à la volée dans le `GeometryBuilder`, il a été opté pour un dictionnaire de configuration centralisé.

- **Standardisation** : Chaque élément (lame, traverse) possède un couple `nom` / `couleur`. Cela permet au plugin de vérifier si le matériau existe déjà dans le modèle avant d'en créer un nouveau, évitant ainsi de polluer la palette de matériaux de l'utilisateur avec des doublons.
- **Immuabilité** : L'utilisation de `.freeze` empêche toute modification accidentelle des couleurs durant le cycle de vie de l'application.

## 📏 Gestion des Unités et Précision

Le défi majeur de l'API SketchUp est l'utilisation forcée du pouce. Pour l'utilisateur final (architecte/menuisier), le centimètre est la norme.

### Choix des Helpers
J'ai implémenté des méthodes de classe (`self`) pour encapsuler la logique de conversion. 

- **Facteur de conversion** : L'utilisation de `0.393701`, pour le passage CM $\rightarrow$ IN, offre une précision suffisante pour le prototypage.
- **Abstraction** : En utilisant `LouverBlade.cm_to_in(val)`, le code devient auto-documenté. On comprend immédiatement que la valeur entrante est en centimètres, ce qui réduit drastiquement les risques d'erreurs de calcul lors de l'ajout de nouvelles fonctionnalités.

## 🚀 Évolutivité
Cette structure permet d'envisager facilement les évolutions suivantes :
- **Customisation** : Ajouter un menu de configuration permettant à l'utilisateur de modifier les couleurs du `CONFIG` via l'interface.
- **Internationalisation** : Adapter les helpers si le plugin doit supporter d'autres unités (ex: millimètres) sans modifier la logique du `GeometryBuilder`.
