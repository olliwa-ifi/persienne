module LouverBlade
  module UIHandler
    # Variable de classe pour mémoriser les derniers choix durant la session
    @@last_params = ["60", "60", "60", "30", "1.2", "48.192", "3.5", "10", "67.5", "0.7", "False"]

    def self.show_input_dialog
      prompts = [
        "Origin X (cm):", "Origin Y (cm):", "Origin Z (cm):",
        "Blade Length (cm):", "Blade Thickness (cm):", "Blade Angle (deg):",
        "Stile Depth (cm):", "Rail Height (cm):", "Max Height (cm):", "Overlap (cm):",
        "Integrate first/last blades (True/False):"
      ]
      
      # On utilise la mémoire @@last_params
      results = UI.inputbox(prompts, @@last_params, "Louver Blade Generator v#{LouverBlade::VERSION}")
      return unless results

      # Mise à jour de la mémoire pour le prochain appel
      @@last_params = results

      begin
        louver_data = Louver.new(results)
        builder = GeometryBuilder.new(louver_data)
        if builder.build
          show_report(louver_data)
        end
      rescue ArgumentError => e
        UI.messagebox("Input Error: #{e.message}")
      rescue => e
        UI.messagebox("Critical Error: #{e.message}\n#{e.backtrace.first}")
      end
    end

    def self.show_report(l)
      c = l.calc
      total_h = LouverBlade.in_to_cm(((c.num_blades - 1) * c.vertical_spacing - c.blade_bevel).round(2))
      
      msg = "✓ Louver created successfully!\n"
      msg += "Version: #{LouverBlade::VERSION}\n\n"
      msg += "Blades Created: #{l.real_blade_count}\n"
      msg += "Blade Bevel: #{LouverBlade.in_to_cm(c.blade_bevel).round(2)} cm\n"
      msg += "Vertical Spacing: #{LouverBlade.in_to_cm(c.vertical_spacing).round(2)} cm\n"
      msg += "Total Height: #{total_h} cm\n"
      msg += "Blade Angle: #{l.params.angle_deg.round(3)}°"
      
      UI.messagebox(msg, MB_OK, "Louver Blade Generator v#{LouverBlade::VERSION}")
    end
  end
end
