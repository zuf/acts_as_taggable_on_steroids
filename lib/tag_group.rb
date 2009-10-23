class TagGroup < ActiveRecord::Base
  has_many :tags, :dependent => :nullify
  
  def connected_model
    self.model_type.constantize unless self.model_type.blank?
  end
end
