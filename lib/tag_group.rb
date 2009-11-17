class TagGroup < ActiveRecord::Base
  has_many :tags, :dependent => :nullify

  validates_presence_of :name
  validates_uniqueness_of :name
  
  def validate    
    errors.add("model_name", "указана несуществующая модель") unless self.class.models_names.include?(model_name.classify)
#    columns_names = model_name.classify.constantize.content_columns.map(&:name)
#    search_by_fields.split(/\s*,\s*/).each do |field|
#      errors.add("search_by_fields", "указано несуществующее поле \"#{field}\" для модели \"#{model_name}\". Доступные поля: #{columns_names.join(', ')}") unless columns_names.include?(field)
#    end
  end

  def self.models
    Dir.glob(RAILS_ROOT + '/app/models/*.rb').each { |file| require file }
    Object.subclasses_of(ActiveRecord::Base).find_all {|model| model.parents == [Object]}
  end

  def self.models_names
    (models - [self, Tag]).collect{|m| m.human_name}
  end

  def model
    model_name.constantize
  end

  def connected_model
    self.model_type.constantize unless self.model_type.blank?
  end
end
