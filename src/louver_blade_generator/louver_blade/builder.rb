module LouverBlade
  class GeometryBuilder
    def initialize(louver_obj)
      @louver = louver_obj
      @params = louver_obj.params
      @calc = louver_obj.calc
      @model = Sketchup.active_model
      @run_id = Time.now.to_i.to_s
    end

    def build
      @model.start_operation("Louver Generator v#{LouverBlade::VERSION}", true)
      begin
        group = @model.active_entities.add_group
        group.name = "Louver_Assembly_#{@run_id}"

        blade_def = create_blade_def
        rail_bottom_def = create_rail_def("Bottom")
        rail_top_def = create_rail_def("Top", @calc.rail_bevel)

        [rail_bottom_def, rail_top_def].each_with_index do |def_obj, i|
          pos = Geom::Point3d.new(
            @params.origin.x, 
            @params.origin.y + i * @params.stile_depth, 
            @params.origin.z + i * (@params.max_height + 2 * @params.stile_height)
          )
          rot = Geom::Transformation.rotation(Geom::Point3d.new(0,0,0), [1,0,0], i * Math::PI)
          group.entities.add_instance(def_obj, Geom::Transformation.new(pos) * rot)
        end

        range = @params.integrated_blades ? (1...@calc.num_blades - 1) : (0...@calc.num_blades)
        start_z = @params.stile_height - @calc.blade_bevel
        
        range.each do |i|
          pt = Geom::Point3d.new(@params.origin.x, @params.origin.y, @params.origin.z + start_z + i * @calc.vertical_spacing)
          group.entities.add_instance(blade_def, Geom::Transformation.new(pt))
        end

        @model.commit_operation
        true
      rescue => e
        @model.abort_operation
        raise e
      end
    end

    private

    def create_blade_def
      def_obj = @model.definitions.add("LouverBlade/Blade_#{@run_id}")
      pts = [
        [0, 0, 0],
        [0, 0, @calc.blade_bevel],
        [0, @calc.sloped_depth * @calc.cos_a, @calc.blade_bevel + @calc.sloped_depth * @calc.sin_a],
        [0, @calc.sloped_depth * @calc.cos_a, @calc.sloped_depth * @calc.sin_a]
      ].map { |p| Geom::Point3d.new(*p) }
      
      finalize_component(def_obj, pts, -@params.blade_length, CONFIG[:blade])
      def_obj
    end

    def create_rail_def(type, reduction = 0)
      def_obj = @model.definitions.add("LouverBlade/Rail_#{type}_#{@run_id}")
      offset = @params.integrated_blades ? @calc.blade_bevel : 0
      top_z = -@calc.blade_bevel + @params.stile_height - reduction + offset
      
      pts = [
        [0, 0, 0],
        [0, @params.stile_depth, 0],
        [0, @params.stile_depth, top_z + @params.stile_depth * @calc.tan_a],
        [0, 0, top_z]
      ].map { |p| Geom::Point3d.new(*p) }
      
      finalize_component(def_obj, pts, @params.blade_length, CONFIG[:rail])
      def_obj
    end

    def finalize_component(definition, points, dist, cfg)
      face = definition.entities.add_face(points)
      mat = get_or_create_material(cfg[:name], cfg[:color])
      face.material = mat
      face.pushpull(dist)
      definition.entities.each { |e| e.material = mat if e.is_a?(Sketchup::Face) }
    end

    def get_or_create_material(name, color)
      mats = @model.materials
      mat = mats[name] || mats.add(name)
      mat.color = Sketchup::Color.new(*color)
      mat
    end
  end
end
