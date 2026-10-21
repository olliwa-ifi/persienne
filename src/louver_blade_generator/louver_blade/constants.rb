module LouverBlade
  VERSION = "1.0.1"
 
  CONFIG = {
    blade: { color: [200, 200, 200], name: "Louver_Material" },
    rail:  { color: [80, 80, 80],   name: "Louver_Rail_Mat" }
  }.freeze

  # Helpers de conversion pour un code plus clair
  def self.cm_to_in(val)
    val.to_f * 0.393701
  end

  def self.in_to_cm(val)
    val.to_f * 2.54
  end
end
