# Module : Logic

module LouverBlade
  class Louver
    attr_reader :params, :calc

    def initialize(input_values)
      @params = validate_and_parse(input_values)
      @calc = perform_calculations
    end

    def validate_and_parse(vals)
      raise ArgumentError, "Dimensions doivent être positives" if vals[3..9].any? { |v| v.to_f <= 0 }
      
      Struct.new(
        :origin, :blade_length, :thickness, :angle_deg, 
        :stile_depth, :stile_height, :max_height, :overlap, :integrated_blades
      ).new(
        Geom::Point3d.new(LouverBlade.cm_to_in(vals[0]), LouverBlade.cm_to_in(vals[1]), LouverBlade.cm_to_in(vals[2])),
        LouverBlade.cm_to_in(vals[3]),
        LouverBlade.cm_to_in(vals[4]),
        vals[5].to_f,
        LouverBlade.cm_to_in(vals[6]),
        LouverBlade.cm_to_in(vals[7]),
        LouverBlade.cm_to_in(vals[8]),
        LouverBlade.cm_to_in(vals[9]),
        vals[10].to_s.downcase == 'true'
      )
    end

    def perform_calculations
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

      Struct.new(
        :angle_rad, :cos_a, :sin_a, :tan_a, 
        :blade_bevel, :sloped_depth, :rail_bevel, 
        :vertical_spacing, :num_blades
      ).new(rad, cos_a, sin_a, tan_a, bevel, sloped, rail_b, spacing, num)
    end

    def real_blade_count
      @params.integrated_blades ? (@calc.num_blades - 2) : @calc.num_blades
    end
  end
end
