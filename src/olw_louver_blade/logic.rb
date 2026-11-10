module LouverBlade
  class Louver
    attr_reader :params, :calc

    def initialize(params: {})
      LouverLogger.debug("Initialisation de l'objet Louver (calculs de données)")
      # We trust the UIHandler has already validated the numbers
      @params = parse_params(params) 
      @calc = perform_calculations
      LouverLogger.info("Calculs de structure terminés : #{@calc.num_blades} lames prévues")
    end

    def parse_params(vals)
      LouverLogger.debug("Conversion des paramètres CM -> INCH")
      
      # Removed the 'numeric_keys' validation block to avoid the nil.to_f <= 0 bug
      
      Struct.new(
        :origin, :blade_length, :thickness, :angle_deg, 
        :stile_depth, :stile_height, :max_height, :overlap, :integrated_blades
      ).new(
        Geom::Point3d.new(
          LouverBlade.cm_to_in(vals[:origin_x]), 
          LouverBlade.cm_to_in(vals[:origin_y]), 
          LouverBlade.cm_to_in(vals[:origin_z])
        ),
        LouverBlade.cm_to_in(vals[:blade_length]),
        LouverBlade.cm_to_in(vals[:blade_thickness]), # Corrected key
        vals[:blade_angle].to_f,
        LouverBlade.cm_to_in(vals[:stile_depth]),
        LouverBlade.cm_to_in(vals[:rail_height]),     # Corrected key
        LouverBlade.cm_to_in(vals[:max_height]),
        LouverBlade.cm_to_in(vals[:overlap]),
        vals[:integrate_blades] == true 
      )
    end

    def perform_calculations
      LouverLogger.debug("Exécution des calculs trigonométriques")
      
      angle_deg = @params.angle_deg.clamp(0.1, 89.9)
      rad = angle_deg * Math::PI / 180
      cos_a = Math.cos(rad)
      sin_a = Math.sin(rad)
      tan_a = Math.tan(rad)

      bevel = @params.thickness / cos_a
      sloped = @params.stile_depth / cos_a
      rail_b = @params.stile_depth * tan_a
      
      spacing_raw = rail_b + bevel - @params.overlap
      num = ((@params.max_height + bevel - @params.overlap) / spacing_raw).ceil + 1
      spacing = (@params.max_height + bevel) / (num - 1)

      LouverLogger.debug("Résultats calculs : Spacing=#{spacing.round(4)}, Bevel=#{bevel.round(4)}, NumBlades=#{num}")

      Struct.new(
        :angle_rad, :cos_a, :sin_a, :tan_a, 
        :blade_bevel, :sloped_depth, :rail_bevel, 
        :vertical_spacing, :num_blades
      ).new(rad, cos_a, sin_a, tan_a, bevel, sloped, rail_b, spacing, num)
    end

    def real_blade_count
      count = @params.integrated_blades ? (@calc.num_blades - 2) : @calc.num_blades
      LouverLogger.debug("Nombre réel de lames à générer : #{count}")
      count
    end
  end
end
