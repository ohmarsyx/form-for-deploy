class User < ApplicationRecord
  enum gender: { male: 'Male', female: 'Female'}

  validates :first_name, presence: true
  validates :last_name, presence: true
end
