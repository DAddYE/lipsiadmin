class Serializo
  @@obj = Hash.new
  def initialize(objects)
    return if objects.nil?
    objects.each do |key, value|
      RAILS_DEFAULT_LOGGER.debug "--> Serializo -> #{key} -> #{value}"
      code = <<-CLASS
        def #{key}
          @@obj[:#{key}]
        end

        def #{key}=(val)
          @@obj[:#{key}]=val
        end
      CLASS
      self.class.class_eval code
      @@obj[key.to_sym]=value
    end
  end
  
  def method_missing(name, *args, &block) 
    nil
  end
end