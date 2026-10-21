module LouverBlade
  def self.setup_menu
    unless file_loaded?(__FILE__)
      main_menu = UI.menu("Plugins") 
      main_menu.add_item("Générer des Persiennes v#{LouverBlade::VERSION}") {
        UIHandler.show_input_dialog
      }
      file_loaded(__FILE__)
    end
  end
end

LouverBlade.setup_menu
