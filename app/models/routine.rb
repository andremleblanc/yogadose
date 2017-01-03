class Routine < ApplicationRecord
  validates :source, presence: true
  validates :title, presence: true
end
