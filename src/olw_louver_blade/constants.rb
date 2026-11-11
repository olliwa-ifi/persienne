module LouverBlade
  VERSION = "1.0.8"
 
  # Initialisation de la persistance simple
  @@params = {}

  # Méthode pour récupérer une valeur avec une valeur par défaut si absente
  def self.get(key, default = nil)
    @@params[key] || default
  end

  # Méthode pour enregistrer une valeur
  def self.set(key, value)
    @@params[key] = value
  end

  # CONFIG : Paramètres visuels et matériaux
  # Note : Les couleurs sont en RGB (0-255). 890 était invalide.
  CONFIG = {
    blade: { color: [225, 190, 150], name: "olli_Louver_Blade_Mat" },
    rail:  { color: [150, 50, 30],   name: "olli_Louver_Rail_Mat" }
  }.freeze

  # --- HELPERS DE CONVERSION ---
  # Utilisation de constantes pour plus de précision et de performance
  CM_TO_IN = 0.393701
  IN_TO_CM = 2.54

  def self.cm_to_in(val)
    (val.to_f * CM_TO_IN).round(6)
  end

  def self.in_to_cm(val)
    (val.to_f * IN_TO_CM).round(6)
  end

  # --- GESTION DES MATÉRIAUX ---
  # Cette méthode évite de créer 100 fois le même matériau dans le modèle
  def self.get_or_create_material(config_key)
    mat_cfg = CONFIG[config_key]
    materials = Sketchup.active_model.materials
    
    mat = materials[mat_cfg[:name]]
    if mat.nil?
      LouverLogger.debug("Création du matériau #{mat_cfg[:name]}")
      mat = materials.add(mat_cfg[:name])
      mat.color = mat_cfg[:color]
    end
    mat
  end
end
