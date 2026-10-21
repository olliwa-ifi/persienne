# Module : Main

Le module `Main` agit comme l'orchestrateur du plugin. C'est le point d'entrée qui coordonne les autres modules.

## Responsabilités
- Initialisation du plugin.
- Gestion du menu SketchUp et des raccourcis.
- Coordination du flux : `UI` $\rightarrow$ `Logic` $\rightarrow$ `Builder`.

## Cycle d'exécution
1. L'utilisateur clique sur le menu "Louver Blade Generator".
2. `Main` appelle `UIHandler` pour afficher les paramètres.
3. Lors de la validation, `Main` transmet les données à `Logic` pour calcul.
4. Les résultats sont envoyés à `Builder` pour la génération 3D.
