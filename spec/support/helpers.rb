module Helpers

  # Undefine methods for a given associate or all
  #
  # @param name [Symbol, String]
  def reset_associate!(name = nil)
    if name
      associate = associates.find { |assoc| assoc.name == name.to_s }
      methods = associate.attribute_names
      associates.reject! { |assoc| assoc.name == name.to_s }
    else
      methods = associates.map(&:attribute_names).flatten
      associates.clear
    end

    methods += methods.map { |method| "#{method}=" }
    methods.each { |method| remove_method(method) }
  end
end
