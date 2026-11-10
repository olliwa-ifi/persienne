# Module : Logic

Ce document est conçu comme une spécification technique, expliquant le **pourquoi** et le **comment** du point de vue du concepteur.

---

# Spécifications Logiques : LouverBlade (Persienne Française)

## 1. Philosophie de Conception
L'objectif est de séparer strictement la **saisie des données** (UI), le **traitement mathématique** (Logic) et la **génération géométrique** (Builder). 

L'approche repose sur un système de "Pipeline" :
`User Input` $\rightarrow$ `UIHandler (Validation)` $\rightarrow$ `Louver Class (Conversion/Calcul)` $\rightarrow$ `GeometryBuilder (Création)`

## 2. Gestion des Données et Paramètres
Pour éviter les erreurs liées aux index de tableaux (courantes dans les scripts SketchUp basiques), le plugin utilise un **mapping par clés (Hash)**.

### Le Schema de Vérité
Toutes les variables sont définies dans un `SCHEMA` centralisé. Cela permet de :
- Modifier un libellé ou une unité sans toucher au code de calcul.
- Garantir que la clé utilisée dans l'interface (`:blade_length`) est la même que celle utilisée dans le moteur de calcul.

### Conversion d'Unités
SketchUp travaille nativement en pouces (inches). Le concepteur a choisi l'expérience utilisateur en **centimètres**.
- **Flux :** Saisie (cm) $\rightarrow$ Conversion (`cm_to_in`) $\rightarrow$ Calculs internes (inches) $\rightarrow$ Géométrie (inches).

## 3. Moteur de Calcul (`Louver` Class)

Le cœur logique transforme des dimensions nominales en coordonnées géométriques réelles en tenant compte de l'inclinaison des lames.

### Trigonométrie Appliquée
L'angle de la lame ($\alpha$) impacte toutes les dimensions verticales et la profondeur :
- **Biseau de lame (Bevel) :** L'épaisseur réelle de la lame vue de profil augmente avec l'angle. 
  $$\text{bevel} = \frac{\text{thickness}}{\cos(\alpha)}$$
- **Profondeur projetée :** La profondeur du cadre est ajustée pour accueillir la lame inclinée.
- **Espacement vertical :** Le calcul du nombre de lames est dynamique. Il prend en compte le recouvrement (`overlap`) et le biseau pour s'assurer que la hauteur totale (`max_height`) est respectée.

### Structure de Données (Struct)
L'utilisation de `Struct` pour `@params` et `@calc` permet un accès rapide et lisible (ex: `@params.blade_length` au lieu de `@params[:blade_length]`), tout en restant léger en mémoire.

## 4. Stratégie de Validation

La robustesse du plugin repose sur une validation à deux niveaux :

1.  **Validation d'Interface (UIHandler) :**
    - **Types :** Conversion forcée en `float`, `int` ou `bool`.
    - **Positivité :** Blocage immédiat si une dimension est $\le 0$.
    - **Plages (Ranges) :** Vérification via `VALIDATION_RULES` pour éviter des valeurs aberrantes (ex: un angle de 120° qui briserait la géométrie).
2.  **Protection Logique (Louver) :**
    - **Clamping :** L'angle est contraint entre $0.1^\circ$ et $89.9^\circ$ pour éviter les divisions par zéro ($\tan(90^\circ)$).

## 5. Complexité Algorithmique
- **Temps :** $O(1)$ pour les calculs, $O(n)$ pour la génération des lames où $n$ est le nombre de lames.
- **Espace :** $O(1)$ car nous ne stockons que des primitives numériques avant la création des entités SketchUp.