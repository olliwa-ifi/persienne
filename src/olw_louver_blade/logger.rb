module LouverBlade
  module LouverLogger
    def self.log(message, level = :info)
      timestamp = Time.now.strftime("%H:%M:%S")
      formatted_msg = "[#{timestamp}] [#{level.to_s.upcase}] #{message}"
      
      # Utilisation de la méthode d'assignation correcte pour la barre d'état
      if level == :info
        # Dans SketchUp, on assigne une valeur à status_bar
        Sketchup.set_status_text(formatted_msg) rescue (UI.status_bar = formatted_msg)
      end
      
      puts formatted_msg if level == :debug || level == :error
      
      if level == :error
        UI.messagebox(formatted_msg)
      end
    end

    def self.info(message)
      log(message, :info)
    end

    def self.debug(message)
      log(message, :debug)
    end

    def self.error(message)
      log(message, :error)
    end
  end
end
