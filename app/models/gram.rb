class Gram < ApplicationRecord
  mount_uploader :image, GramUploader
  validates :message, presence: true

  belongs_to :user
end
