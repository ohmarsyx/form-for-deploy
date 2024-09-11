class User < ApplicationRecord
  enum gender: { male: 'Male', female: 'Female'}

  validates :first_name, presence: true
  validates :first_name, format: { with: /\A[a-zA-Z]+\z/, message: "is not allowed to contain numbers or special characters" }, if: -> { first_name.present? }

  validates :last_name, presence: true
  validates :last_name, format: { with: /\A[a-zA-Z]+\z/, message: "is not allowed to contain numbers or special characters" }, if: -> { first_name.present? }

  validates :birthday, presence: true

  validates :gender, presence: true

  validates :email, presence: true

  validates :phone, presence: true

  validates :subject, presence: true


  
end
