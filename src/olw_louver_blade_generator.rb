require 'sketchup.rb'
require 'extensions.rb'

module OlliwaLouverBlade
  # 1. Configuration et Logger
  plugin_dir = File.join(File.dirname(__FILE__), 'olw_louver_blade')
  
  # On définit d'abord le module de secours pour être sur qu'il existe
  module LouverLogger
    def self.log(msg, lvl=:info); puts "[#{lvl.to_s.upcase}] #{msg}"; end
    def self.debug(msg); log(msg, :debug); end
    def self.error(msg); log(msg, :error); end
  end

  begin
    # On tente de charger le logger.rb externe
    # S'il est chargé, il écrasera le module LouverLogger défini ci-dessus
    require File.join(plugin_dir, 'logger.rb')
    LouverLogger.log("Début du chargement du plugin OlliwaLouverBlade (LouverLogger)", :info)
  rescue LoadError
    LouverLogger.log("Utilisation du logger de secours (logger.rb introuvable)", :info)
  rescue => e
    LouverLogger.log("Erreur lors du chargement du logger : #{e.message}", :error)
  end


  # 2. Vérification de la version minimale
  SKETCHUP_MIN_VERSION = 20.0
  
  if Sketchup.version.to_f < SKETCHUP_MIN_VERSION
    UI.messagebox("OlliwaLouverBlade nécessite SketchUp 2020 ou une version plus récente.")
  else
    # 3. Chargement séquentiel des fichiers
    files = ['constants.rb', 'logic.rb', 'builder.rb', 'ui.rb']

    files.each do |file|
      begin
        path = File.join(plugin_dir, file)
        require path
        LouverLogger.log("Chargement réussi : #{file}", :debug)
      rescue LoadError => e
        LouverLogger.log("Impossible de charger #{file}. Détails : #{e.message}", :error)
      rescue StandardError => e
        LouverLogger.log("Erreur critique dans #{file} : #{e.message}", :error)
      end
    end # Fin de la boucle files.each

    # 4. Création des menus
    unless file_loaded?(__FILE__)
      begin
        # Extraction de la version depuis le module LouverBlade
        version_label = (LouverBlade::VERSION rescue "1.0.0")

        main_menu = UI.menu('Plugins').add_submenu("Olliwa Persienne francaise")
        
        main_menu.add_item("Lancer l'outil v#{version_label}") {
          LouverLogger.log("Bouton Lancement cliqué", :info)
          LouverBlade::UIHandler.show_input_dialog rescue LouverLogger.log("Erreur : Interface non trouvée", :error)
        }
        
        main_menu.add_separator
        
        main_menu.add_item("Aide / Documentation") {
          LouverLogger.log("Bouton Aide cliqué", :info)
          
          help_text = <<~TEXT
            Guide d'utilisation du générateur de Persienne francaise :

              - ORIGINE
                 - positionner le coin inférieur gauche X,Y,Z
                 - saisir la hauteur totale de la persienne
              - LAMES
                 - saisir la longueur et l'épaisseur des lames
                 - l'angle d'inclinaison des lames
                 - et le recouvrement minimum souhaité entre chaque lame.
              - TRAVERSES
                 - définir la profondeur et la hauteur 
              - OPTION
                - Intégrer la première et dernière lame dans les traverses.

              Cliquer sur OK pour fermer l'aide et ouvrir l'interface de création.
          TEXT
          
          UI.messagebox(help_text, 64, "Guide d'utilisation")
          
          LouverLogger.log("Lancement automatique après aide", :info)
          LouverBlade::UIHandler.show_input_dialog rescue LouverLogger.log("Erreur : Interface non trouvée", :error)
        }
        
        file_loaded(__FILE__)
        LouverLogger.log("Menu 'Plugins' ajouté avec succès", :info)
      rescue => e
        LouverLogger.log("Erreur lors de la création du menu : #{e.message}", :error)
      end
    end # Fin unless file_loaded?
  end # ferme le 'if' de la version
end # Fin du module OlliwaLouverBlade
