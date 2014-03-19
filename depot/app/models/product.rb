class Product < ActiveRecord::Base
  validates :title, :description, :image_url, presence: true
  validates :price, numericality: {greater_than_or_equal_to: 0.01}
  validates :title, uniqueness: true, length: { minimum: 5 }
  validates :image_url, allow_blank: true, format: {
    with: %r{\.(gif|jpg|jpeg|png)\Z}i,
    message: 'must be a URL for a GIF, Jpeg, or PNG image.'
  }
  
  def self.latest
    Product.order(:updated_at).last
  end
end
