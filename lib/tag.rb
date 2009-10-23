class Tag < ActiveRecord::Base
  has_many :taggings
  belongs_to :tag_group

  named_scope :for_tag_group, lambda { |*args| {:conditions => {:tag_group_id => args.first}} }  
  
  validates_presence_of :name
  #validates_uniqueness_of :name

  def validate
    dup_tag = Tag.first(:conditions => {:name => name})
    errors.add(:name, "#{name} уже существует в группе #{dup_tag.tag_group.name}.") if dup_tag
  end
  
  cattr_accessor :destroy_unused
  self.destroy_unused = false
  
  # LIKE is used for cross-database case-insensitivity
  def self.find_or_create_with_like_by_name(name)
    find(:first, :conditions => ["name LIKE ?", name]) || create(:name => name)
  end

  def self.find_or_create_with_like_by_name_and_tag_group_id(name, tag_group_id)
    find(:first, :conditions => ["name LIKE ? AND tag_group_id=?", name, tag_group_id]) || create(:name => name, :tag_group_id => tag_group_id)
  end
  
  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end
  
  def to_s
    name
  end
  
  def count
    read_attribute(:count).to_i
  end
end
