require 'sketchup.rb'
require 'extensions.rb'

# Vérification de la version minimale (SketchUp 2020 = version 20)
SKETCHUP_MIN_VERSION = 20.0

if Sketchup.version.to_f < SKETCHUP_MIN_VERSION
  UI.messagebox("Louver Blade Generator nécessite SketchUp 2020 ou une version plus récente.")
else
  unless file_loaded?(__FILE__)
    require_relative 'louver_blade/constants'
    require_relative 'louver_blade/logic'
    require_relative 'louver_blade/builder'
    require_relative 'louver_blade/ui'
    require_relative 'louver_blade/main'
    
    file_loaded(__FILE__)
  end
end
