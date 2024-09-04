class User < ApplicationRecord
  enum gender: { male: 'Male', female: 'Female'}
end
