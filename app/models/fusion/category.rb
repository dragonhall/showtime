class Fusion::Category < ApplicationRecord
  establish_connection :dragonhall

  self.table_name = 'fusion_pdp_cats'

  scope :top_categories, -> { where(top_cat: 0) }

  alias_attribute :name, :cat_name
  alias_attribute :description, :cat_desc
  alias_attribute :counter, :count_downloads
  alias_attribute :order, :cat_order
  
  has_many :categories, class_name: 'Fusion::Category', foreign_key: :top_cat

  def parent
    self.top_cat == 0 ? nil : Fusion::Category.find(self.top_cat)
  end

  def top?
    self.top_cat == 0
  end

  def subcategory?
    !top?
  end

  def restricted?
    self.cat_access > 0
  end


end
