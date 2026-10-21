# Module : UIHandler

Ce module gère l'interaction avec l'utilisateur et la persistance des données durant la session.

## Responsabilités
- Création et affichage des boîtes de dialogue (HtmlDialog).
- Récupération des saisies utilisateur.
- Stockage temporaire des paramètres.

## Persistance de session
Le module utilise une variable de classe `@@last_params` pour mémoriser les derniers réglages utilisés par l'utilisateur. Contrairement à `Sketchup.write_default`, ces données sont effacées à la fermeture de SketchUp, garantissant une session propre à chaque lancement.
