class Todo < ApplicationRecord
  validates :title, presence: true, length: { maximum: 25 }
  validates :details, presence: true, length: { maximum: 250 }
end
