Rédaction du point de vue du concepteur.

---

# Spécifications Chargeur : Plugin Loader

## 1. Vision Conceptuelle
Le chargeur est la "porte d'entrée" du plugin. Son rôle n'est pas de produire de la géométrie, mais d'orchestrer l'initialisation du système. Le concepteur a mis en place un **chargement défensif** : le plugin doit pouvoir échouer partiellement sans faire planter SketchUp, tout en informant le développeur via un système de logs.

## 2. Stratégie d'Initialisation

### Le Système de Logging (Fail-safe)
L'une des priorités du concepteur a été la traçabilité. Le chargeur implémente un système de logging à deux niveaux :
1.  **Le Logger de Secours :** Un module minimaliste défini directement dans le loader.
2.  **Le Logger Externe :** Tentative de chargement de `logger.rb`. Si ce fichier est présent, il remplace le logger de secours pour offrir des fonctionnalités avancées (écriture fichier, niveaux de debug).
*Ceci garantit que même si le système de log externe est corrompu, le plugin peut toujours sortir des messages d'erreur via la console.*

### Vérification de l'Environnement
Avant tout chargement, le plugin vérifie la version de SketchUp :
- **Condition :** `Sketchup.version >= 20.0`.
- **Justification :** L'utilisation de certaines méthodes de manipulation de groupes et de composants, ainsi que la syntaxe Ruby utilisée, nécessitent SketchUp 2020 minimum.

## 3. Gestion du Cycle de Vie des Fichiers

### Chargement Séquentiel et Dépendances
Le plugin est découpé en modules pour éviter la pollution de l'espace de nom global (namespace pollution). L'ordre de chargement est critique car certains fichiers dépendent d'autres :
1. `constants.rb` $\rightarrow$ Définit les valeurs fixes et couleurs.
2. `logic.rb` $\rightarrow$ Définit la classe `Louver` (calculs).
3. `builder.rb` $\rightarrow$ Définit `GeometryBuilder` (dépend de `Louver`).
4. `ui.rb` $\rightarrow$ Définit `UIHandler` (dépend de `Louver` et `GeometryBuilder`).

Chaque fichier est chargé dans un bloc `begin...rescue` individuel. Si `builder.rb` échoue, le menu sera toujours créé, mais l'utilisateur sera averti d'une erreur critique lors du lancement.

## 4. Interface d'Accès (Menu)

### Intégration Native
Le plugin s'intègre dans le menu standard `Plugins` via un sous-menu dédié : **"Olliwa Persienne francaise"**.

### Fonctionnalités du Menu
- **Lancement Dynamique :** L'item de menu récupère la version du plugin (`LouverBlade::VERSION`) pour l'afficher dans le label, permettant à l'utilisateur de savoir instantanément quelle version est installée.
- **Système d'Aide :** Une documentation rapide est intégrée directement dans le menu pour réduire la courbe d'apprentissage sans forcer l'utilisateur à ouvrir un PDF externe.
- **Prévention du Double Chargement :** Utilisation de `file_loaded?(__FILE__)` pour éviter que SketchUp ne crée des menus en double lors du rechargement du script (via un plugin de reload par exemple).

## 5. Résumé du Flux d'Exécution
`Démarrage SketchUp` $\rightarrow$ `Init Logger` $\rightarrow$ `Check Version` $\rightarrow$ `Load Modules (Sequential)` $\rightarrow$ `Inject Menu` $\rightarrow$ `Attente Action Utilisateur`.