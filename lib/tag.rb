class Tag < ActiveRecord::Base
  
  belongs_to :tag_group
  has_many :taggings, :dependent => :destroy

  named_scope :for_tag_group, lambda { |*args| {:conditions => {:tag_group_id => args.first}} }  
  
  validates_presence_of :name
  #validates_uniqueness_of :name

  def to_param
    name
  end

  # Не очень красивое решение
  # Индексируем тег, если установлен ThinkinSphinx
#  if self.respond_to? :define_index
#    define_index do
#      indexes name, :sortable => true
#      #has created_at, updated_at
#    end
#  end

  # Не очень быстрый хак
  # Выбираю связанные с тегом полиморфные объекты
  def taggables
    self.taggings.collect{|tg| tg.taggable}
  end

  def model
    tag_group.model
  end

  

  cattr_accessor :destroy_unused
  self.destroy_unused = false

  def self.destroy_unused_tags
    Tag.all.each do |tag|
      tag.destroy if tag.taggings.count.zero?
    end
  end

  # LIKE is used for cross-database case-insensitivity
  def self.find_or_create_with_like_by_name(name)
    find(:first, :conditions => ["name LIKE ?", name]) || create(:name => name)
  end

  def self.find_or_create_with_like_by_name_and_tag_group_id(name, tag_group_id)
    find(:first, :conditions => ["name LIKE ? AND tag_group_id=?", name, tag_group_id]) || create(:name => name, :tag_group_id => tag_group_id)
  end

  # Метод добавлен специально, чтобы возвращать найденный тег, либо создавать новый объект для тега,
  # который в БД пока не сохранен.
  def self.find_or_new_with_like_by_name_and_tag_group_id(name, tag_group_id)
    find(:first, :conditions => ["name LIKE ? AND tag_group_id=?", name, tag_group_id]) || new(:name => name, :tag_group_id => tag_group_id)
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

private

def validate
  dup_tag = Tag.first(:conditions => {:name => name})
  errors.add(:name, "Тег #{name} уже существует в группе #{dup_tag.tag_group.name}.") if dup_tag
end