class Base < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  validates :number, presence: true, uniqueness: true
  validates :attend, presence: true
end
