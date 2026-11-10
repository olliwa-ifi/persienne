module LouverBlade
  module UIHandler
    # 1. LE SCHEMA : Source unique de vérité pour l'interface
    SCHEMA = {
      origin_x:           { prompt: "[ORIGINE]   X (cm):",              default_key: :origin_x,           list: nil, type: :float },
      origin_y:           { prompt: "            Y (cm):",              default_key: :origin_y,           list: nil, type: :float },
      origin_z:           { prompt: "            Z (cm):",              default_key: :origin_z,           list: nil, type: :float },
      max_height:         { prompt: "            Hauteur totale (cm):",    default_key: :max_height,         list: nil, type: :float },
      blade_length:       { prompt: "[LAMES]     Longueur (cm):",       default_key: :blade_length,       list: nil, type: :float },
      blade_thickness:    { prompt: "            Épaisseur (cm):",      default_key: :blade_thickness,    list: nil, type: :float },
      blade_angle:        { prompt: "            Angle (°):",           default_key: :blade_angle,        list: nil, type: :float },
      overlap:            { prompt: "            Recouvrement (cm):",   default_key: :overlap,            list: nil, type: :float },     
      stile_depth:        { prompt: "[TRAVERSES] Profondeur (cm):",     default_key: :stile_depth,        list: nil, type: :float },
      rail_height:        { prompt: "            Hauteur (cm):",   default_key: :rail_height,             list: nil, type: :float },
      integrate_blades:   { prompt: "[OPTION]    Intégrer extrémités:", default_key: :integrate_blades,   list: "Oui|Non", type: :bool }
    }.freeze

    # 2. RÈGLES DE VALIDATION
    VALIDATION_RULES = {
      blade_length:    { min: 1, max: 1000 },
      blade_thickness: { min: 0.1, max: 100 },
      blade_angle:     { min: 0, max: 89 },
      max_height:      { min: 10, max: 10000 },
      overlap:         { min: 0, max: 10 }
    }.freeze

    DEFAULT_VALUES = {
      origin_x: "60.0", origin_y: "60.0", origin_z: "60.0",
      blade_length: "30.0", blade_thickness: "1.2", blade_angle: "48.192",
      stile_depth: "3.5", rail_height: "10.0", max_height: "67.5",
      overlap: "0.7", integrate_blades: "true"
    }

    def self.show_input_dialog
      begin
        LouverLogger.debug("Ouverture de la boîte de dialogue de saisie")
        
        prompts = SCHEMA.values.map { |v| v[:prompt] }
        lists    = SCHEMA.values.map { |v| v[:list] }
        
        defaults = SCHEMA.keys.map do |key|
          val = (LouverBlade::Config.get(key) rescue DEFAULT_VALUES[key])
          if SCHEMA[key][:list]
            (val == true || val.to_s.downcase == "true") ? "Oui" : "Non"
          else
            val.to_s
          end
        end
        
        input = UI.inputbox(prompts, defaults, lists, "Persienne francaise v#{LouverBlade::VERSION}")
        return unless input

        user_data = SCHEMA.keys.zip(input).to_h
        validated_params = validate_and_sanitize(user_data)
        
        apply_configuration(validated_params)
        execute_generation(validated_params) 
        
      rescue ArgumentError => e
        LouverLogger.error("Erreur de saisie : #{e.message}")
        UI.messagebox("Erreur de saisie : #{e.message}", MB_OK)
      rescue => e
        # Remplacement du puts par LouverLogger.debug pour la trace technique
        LouverLogger.debug("Critical Error: #{e.message}\n#{e.backtrace.join("\n")}")
        LouverLogger.error("Erreur système : #{e.message}")
        UI.messagebox("Erreur système : #{e.message}", MB_OK)
      end
    end

    private

    def self.validate_and_sanitize(user_data)
      validated = {}

      user_data.each do |key, value|
        config = SCHEMA[key]
        label = config[:prompt].split(':').first

        case config[:type]
        when :float
          num = value.to_f
          raise ArgumentError, "Les dimensions doivent être positives" if num <= 0
          check_range(num, key, label)
          validated[key] = num
        when :integer
          num = value.to_i
          raise ArgumentError, "Les dimensions doivent être positives" if num <= 0
          check_range(num, key, label)
          validated[key] = num
        when :bool
          validated[key] = (value.to_s.downcase == "oui")
        when :string
          validated[key] = value.to_s.strip
        end
      end
      validated
    end

    def self.check_range(val, key, label)
      rule = VALIDATION_RULES[key]
      return if rule.nil?
      if val < rule[:min] || val > rule[:max]
        raise ArgumentError, "#{label} : doit être entre #{rule[:min]} et #{rule[:max]} (reçu #{val})"
      end
    end

    def self.apply_configuration(params)
      LouverLogger.debug("Enregistrement de la configuration utilisateur")
      params.each do |key, value|
        LouverBlade::Config.set(key, value) rescue nil
      end
    end

    def self.execute_generation(params)
      begin
        LouverLogger.info("Lancement de la génération avec les paramètres validés")
        louver_data = Louver.new(params: params) 
        builder = GeometryBuilder.new(louver_data)
        
        if builder.build
          show_report(louver_data)
        end
      rescue => e
        LouverLogger.error("Erreur lors de la génération : #{e.message}")
        UI.messagebox("Erreur lors de la génération : #{e.message}")
      end
    end

    def self.show_report(l)
      c = l.calc
      total_h = LouverBlade.in_to_cm(((c.num_blades - 1) * c.vertical_spacing - c.blade_bevel).round(2))
      
      msg = "✓ Louver créé avec succès !\n"
      msg += "Version: #{LouverBlade::VERSION}\n\n"
      msg += "Lames créées: #{l.real_blade_count}\n"
      msg += "Biseau lame: #{LouverBlade.in_to_cm(c.blade_bevel).round(2)} cm\n"
      msg += "Espacement vertical: #{LouverBlade.in_to_cm(c.vertical_spacing).round(2)} cm\n"
      msg += "Hauteur totale: #{total_h} cm\n"
      msg += "Angle lame: #{l.params.angle_deg.round(3)}°"
      
      LouverLogger.info("Rapport de génération généré")
      UI.messagebox(msg, MB_OK, "Louver Blade Generator v#{LouverBlade::VERSION}")
    end
  end
end
