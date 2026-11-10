# Module : UIHandler

Ce document détaille la stratégie d'interface utilisateur, mettant l'accent sur la modularité et l'expérience utilisateur (UX) au sein de l'écosystème SketchUp.

---

# Spécifications Interface Utilisateur (UI) : LouverBlade

## 1. Vision Conceptuelle
L'interface ne doit pas être une simple boîte de dialogue, mais une couche dynamique capable de s'adapter aux changements de paramètres sans nécessiter une réécriture du code de l'interface. 

Le principe directeur est le **"Data-Driven UI"** : l'interface est générée automatiquement à partir d'une structure de données (`SCHEMA`), plutôt que d'être codée en dur.

## 2. Architecture du Système d'Input

### Le SCHEMA : Source Unique de Vérité
L'utilisation d'un Hash `SCHEMA` permet de centraliser la définition de chaque paramètre. Chaque entrée définit :
- **Le Prompt :** Le texte affiché à l'utilisateur.
- **La Clé :** L'identifiant unique utilisé pour le stockage et le calcul.
- **Le Type :** (`:float`, `:int`, `:bool`, `:string`) pour automatiser la validation.
- **La Liste :** Définition des menus déroulants (ex: `"Oui|Non"`).

### Cycle de vie d'une saisie
1.  **Initialisation :** Le système récupère les dernières valeurs sauvegardées dans `Config`. Si aucune donnée n'existe, il utilise `DEFAULT_VALUES`.
2.  **Affichage :** Utilisation de `UI::inputbox` pour une intégration native et légère dans SketchUp.
3.  **Mapping :** Les résultats (retournés par SketchUp sous forme de tableau) sont immédiatement transformés en Hash via `SCHEMA.keys.zip(input).to_h`. Cela élimine les erreurs d'indexation.

## 3. Expérience Utilisateur (UX) et Ergonomie

### Gestion des types de saisie
- **Valeurs Numériques :** Saisie libre, convertie et validée en temps réel.
- **Valeurs Booléennes :** Pour éviter la confusion "True/False" (trop technique), l'interface utilise des listes déroulantes avec des termes naturels : **"Oui | Non"**.

### Feedback et Communication
L'utilisateur est guidé par des messages d'erreur explicites :
- **Erreurs de saisie :** Si une valeur est hors plage ou négative, un `ArgumentError` est intercepté et affiché via une `UI.messagebox` indiquant précisément quel champ est en cause.
- **Rapport de succès :** À la fin de la génération, un rapport détaillé est affiché, confirmant le nombre de lames créées et la hauteur totale finale, validant ainsi le résultat visuel.

## 4. Robustesse et Sécurité

### Isolation des Erreurs
Toute l'interaction UI est encapsulée dans des blocs `begin...rescue`. Cela garantit que :
- Un plantage de l'interface ne fait pas planter SketchUp.
- Les erreurs de conversion de type (ex: texte saisi dans un champ numérique) sont gérées gracieusement.

### Persistance des Données
L'interface est couplée à un module `Config`. Chaque validation réussie entraîne l'enregistrement des paramètres. Ainsi, l'utilisateur retrouve ses réglages lors de la prochaine session, réduisant la friction de saisie pour des projets répétitifs.

## 5. Évolutivité
L'architecture permet d'ajouter un nouveau paramètre (ex: "Couleur des lames") en une seule ligne dans le `SCHEMA`. Le système se chargera automatiquement de :
1. L'ajouter à la boîte de dialogue.
2. Le valider selon son type.
3. Le sauvegarder dans la configuration.
4. Le transmettre au moteur de calcul.