class Picture < ApplicationRecord
  validates :url, presence: true, uniqueness: true, format: { with: /\Ahttps:\/\/www.instagram.com/ }, format: { with: /\/\z/ }, length: { minimum: 40, maximum: 40 }
end
