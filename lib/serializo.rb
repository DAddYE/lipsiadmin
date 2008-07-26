class Serializo
  def self.generate(objects)
    objects ||= {}
    
    ActiveRecord::WithoutTable.columns = []
    objects.each do |key, value|
      ActiveRecord::WithoutTable.column(key, :string, value.to_s)
    end
    
    return ActiveRecord::WithoutTable.new
  end
end