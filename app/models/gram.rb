class Gram < ApplicationRecord
  validates :message, presence: true
  validates :image, presence: true

  mount_uploader :image, GramUploader

  belongs_to :user
  has_many :comments
end
