class Order < ActiveRecord::Base
  PAYMENT_TYPES = [ 'Check', 'Credit card', 'Purchase order', 'Bitcoin', 'Extortion' ]
  has_many :line_items, dependent: :destroy
  
  validates :name, :address, :email, :pay_type, presence: true
  validates :pay_type, inclusion: PAYMENT_TYPES

end
